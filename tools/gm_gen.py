"""
Quazerium GameMaker project generator.

Rebuilds GameMaker metadata (.yyp / .yy) from:
  - scripts/<name>/<name>.gml
  - objects/<name>/<Event>.gml
  - tools/manifest.json  (folders, object meta, rooms, room order)

GML code is the source of truth; metadata is derived. Safe to re-run.
Usage:  python tools/gm_gen.py [project_root]
"""
import json, os, sys, re

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
PROJECT = "Quazerium"
IDE_VERSION = "2026.0.0.16"

# event filename -> (eventType, eventNum)
EVENT_MAP = {
    "Create_0": (0, 0), "Destroy_0": (1, 0), "CleanUp_0": (12, 0),
    "Step_0": (3, 0), "Step_1": (3, 1), "Step_2": (3, 2),
    "Draw_0": (8, 0), "Draw_64": (8, 64), "Draw_72": (8, 72), "Draw_73": (8, 73),
    "Draw_74": (8, 74), "Draw_75": (8, 75), "Draw_76": (8, 76), "Draw_77": (8, 77),
    "Other_2": (7, 2), "Other_3": (7, 3), "Other_4": (7, 4), "Other_5": (7, 5),
}


def gm_json(obj, indent=0):
    """GameMaker-style JSON: trailing commas, 2-space indent, inline leaf dicts."""
    pad = "  " * indent
    if isinstance(obj, dict):
        if not obj:
            return "{}"
        if indent > 0 and all(not isinstance(v, (dict, list)) or (isinstance(v, dict) and all(not isinstance(x, (dict, list)) for x in v.values())) for v in obj.values()) and len(obj) > 0 and indent >= 2:
            return "{" + "".join(f"{json.dumps(k)}:{gm_json(v, indent + 1)}," for k, v in obj.items()) + "}"
        out = "{\n"
        for k, v in obj.items():
            out += f"{pad}  {json.dumps(k)}:{gm_json(v, indent + 1)},\n"
        return out + pad + "}"
    if isinstance(obj, list):
        if not obj:
            return "[]"
        out = "[\n"
        for v in obj:
            out += f"{pad}  {gm_json(v, indent + 2)},\n"
        return out + pad + "]"
    if isinstance(obj, bool):
        return "true" if obj else "false"
    if obj is None:
        return "null"
    if isinstance(obj, float):
        return repr(obj)
    return json.dumps(obj)


def write_if_changed(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            if f.read() == text:
                return False
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return True


def folder_ref(folder):
    return {"name": folder.split("/")[-1], "path": f"folders/{folder}.yy"}


def main():
    with open(os.path.join(ROOT, "tools", "manifest.json"), "r", encoding="utf-8") as f:
        man = json.load(f)

    changed = []
    resources = []
    folders = set()

    def add_folder(path):
        parts = path.split("/")
        for i in range(1, len(parts) + 1):
            folders.add("/".join(parts[:i]))

    # ---------------- scripts ----------------
    script_folders = man.get("script_folders", {})
    sdir = os.path.join(ROOT, "scripts")
    for name in sorted(os.listdir(sdir)) if os.path.isdir(sdir) else []:
        if not os.path.isfile(os.path.join(sdir, name, name + ".gml")):
            continue
        folder = next((fo for prefix, fo in script_folders.items() if name.startswith(prefix)), "Scripts")
        add_folder(folder)
        yy = {
            "$GMScript": "v1", "%Name": name, "isCompatibility": False, "isDnD": False,
            "name": name, "parent": folder_ref(folder),
            "resourceType": "GMScript", "resourceVersion": "2.0",
        }
        if write_if_changed(os.path.join(sdir, name, name + ".yy"), gm_json(yy)):
            changed.append(f"scripts/{name}")
        resources.append((name, f"scripts/{name}/{name}.yy"))

    # ---------------- objects ----------------
    obj_meta = man.get("objects", {})
    odir = os.path.join(ROOT, "objects")
    for name in sorted(os.listdir(odir)) if os.path.isdir(odir) else []:
        p = os.path.join(odir, name)
        if not os.path.isdir(p):
            continue
        meta = obj_meta.get(name, {})
        folder = meta.get("folder", "Objects")
        add_folder(folder)
        events = []
        for fn in sorted(os.listdir(p)):
            base, ext = os.path.splitext(fn)
            if ext != ".gml":
                continue
            if base not in EVENT_MAP:
                raise SystemExit(f"Unknown event file {name}/{fn}")
            et, en = EVENT_MAP[base]
            events.append({"$GMEvent": "v1", "%Name": "", "collisionObjectId": None, "eventNum": en,
                           "eventType": et, "isDnD": False, "name": "", "resourceType": "GMEvent",
                           "resourceVersion": "2.0"})
        parent = meta.get("parent")
        yy = {
            "$GMObject": "", "%Name": name, "eventList": events, "managed": True, "name": name,
            "overriddenProperties": [], "parent": folder_ref(folder),
            "parentObjectId": {"name": parent, "path": f"objects/{parent}/{parent}.yy"} if parent else None,
            "persistent": bool(meta.get("persistent", False)),
            "physicsAngularDamping": 0.1, "physicsDensity": 0.5, "physicsFriction": 0.2, "physicsGroup": 1,
            "physicsKinematic": False, "physicsLinearDamping": 0.1, "physicsObject": False,
            "physicsRestitution": 0.1, "physicsSensor": False, "physicsShape": 1, "physicsShapePoints": [],
            "physicsStartAwake": True, "properties": [], "resourceType": "GMObject", "resourceVersion": "2.0",
            "solid": False, "spriteId": None, "spriteMaskId": None, "visible": bool(meta.get("visible", True)),
        }
        if write_if_changed(os.path.join(p, name + ".yy"), gm_json(yy)):
            changed.append(f"objects/{name}")
        resources.append((name, f"objects/{name}/{name}.yy"))

    # ---------------- rooms ----------------
    view = {"hborder": 32, "hport": 720, "hspeed": -1, "hview": 720, "inherit": False, "objectId": None,
            "vborder": 32, "visible": False, "vspeed": -1, "wport": 1280, "wview": 1280, "xport": 0,
            "xview": 0, "yport": 0, "yview": 0}
    for room in man.get("rooms", []):
        rname = room["name"]
        add_folder("Rooms")
        insts = []
        order = []
        for i, inst in enumerate(room.get("instances", [])):
            iname = f"inst_{rname}_{i}"
            o = inst["object"]
            insts.append({"$GMRInstance": "v1", "%Name": iname, "colour": 4294967295, "frozen": False,
                          "hasCreationCode": False, "ignore": False, "imageIndex": 0, "imageSpeed": 1.0,
                          "inheritCode": False, "inheritedItemId": None, "inheritItemSettings": False,
                          "isDnd": False, "name": iname,
                          "objectId": {"name": o, "path": f"objects/{o}/{o}.yy"}, "properties": [],
                          "resourceType": "GMRInstance", "resourceVersion": "2.0", "rotation": 0.0,
                          "scaleX": float(inst.get("scaleX", 1.0)), "scaleY": float(inst.get("scaleY", 1.0)), "x": float(inst.get("x", 0)), "y": float(inst.get("y", 0))})
            order.append({"name": iname, "path": f"rooms/{rname}/{rname}.yy"})
        yy = {
            "$GMRoom": "v1", "%Name": rname, "creationCodeFile": "", "inheritCode": False,
            "inheritCreationOrder": False, "inheritLayers": False, "instanceCreationOrder": order,
            "isDnd": False,
            "layers": [
                {"$GMRInstanceLayer": "", "%Name": "Instances", "depth": 0, "effectEnabled": True,
                 "effectType": None, "gridX": 32, "gridY": 32, "hierarchyFrozen": False,
                 "inheritLayerDepth": False, "inheritLayerSettings": False, "inheritSubLayers": True,
                 "inheritVisibility": True, "instances": insts, "layers": [], "name": "Instances",
                 "properties": [], "resourceType": "GMRInstanceLayer", "resourceVersion": "2.0",
                 "userdefinedDepth": False, "visible": True},
                {"$GMRBackgroundLayer": "", "%Name": "Background", "animationFPS": 15.0,
                 "animationSpeedType": 0, "colour": int(room.get("bg", 4280295456)), "depth": 100,
                 "effectEnabled": True, "effectType": None, "gridX": 32, "gridY": 32,
                 "hierarchyFrozen": False, "hspeed": 0.0, "htiled": False, "inheritLayerDepth": False,
                 "inheritLayerSettings": False, "inheritSubLayers": True, "inheritVisibility": True,
                 "layers": [], "name": "Background", "properties": [], "resourceType": "GMRBackgroundLayer",
                 "resourceVersion": "2.0", "spriteId": None, "stretch": False, "userdefinedAnimFPS": False,
                 "userdefinedDepth": False, "visible": True, "vspeed": 0.0, "vtiled": False, "x": 0, "y": 0},
            ],
            "name": rname, "parent": folder_ref("Rooms"), "parentRoom": None,
            "physicsSettings": {"inheritPhysicsSettings": False, "PhysicsWorld": False,
                                "PhysicsWorldGravityX": 0.0, "PhysicsWorldGravityY": 10.0,
                                "PhysicsWorldPixToMetres": 0.1},
            "resourceType": "GMRoom", "resourceVersion": "2.0",
            "roomSettings": {"Height": room.get("height", 720), "inheritRoomSettings": False,
                             "persistent": False, "Width": room.get("width", 1280)},
            "sequenceId": None, "views": [dict(view) for _ in range(8)],
            "viewSettings": {"clearDisplayBuffer": True, "clearViewBackground": False,
                             "enableViews": False, "inheritViewSettings": False},
            "volume": 1.0,
        }
        if write_if_changed(os.path.join(ROOT, "rooms", rname, rname + ".yy"), gm_json(yy)):
            changed.append(f"rooms/{rname}")
        resources.append((rname, f"rooms/{rname}/{rname}.yy"))

    # ---------------- project ----------------
    folder_list = [{"$GMFolder": "", "%Name": fo.split("/")[-1], "folderPath": f"folders/{fo}.yy",
                    "name": fo.split("/")[-1], "resourceType": "GMFolder", "resourceVersion": "2.0"}
                   for fo in sorted(folders)]
    yyp = {
        "$GMProject": "v1", "%Name": PROJECT,
        "AudioGroups": [{"$GMAudioGroup": "v1", "%Name": "audiogroup_default", "exportDir": "",
                         "name": "audiogroup_default", "resourceType": "GMAudioGroup",
                         "resourceVersion": "2.0", "targets": -1}],
        "configs": {"children": [], "name": "Default"},
        "defaultScriptType": 1, "Folders": folder_list, "ForcedPrefabProjectReferences": [],
        "IncludedFiles": [], "isEcma": False, "LibraryEmitters": [],
        "MetaData": {"IDEVersion": IDE_VERSION}, "name": PROJECT,
        "resources": [{"id": {"name": n, "path": pth}} for n, pth in sorted(resources, key=lambda r: r[0].lower())],
        "resourceType": "GMProject", "resourceVersion": "2.0",
        "RoomOrderNodes": [{"roomId": {"name": r, "path": f"rooms/{r}/{r}.yy"}} for r in man.get("room_order", [])],
        "templateType": None,
        "TextureGroups": [{"$GMTextureGroup": "", "%Name": "Default", "autocrop": True, "border": 2,
                           "compressFormat": "bz2", "customOptions": "", "directory": "", "groupParent": None,
                           "isScaled": True, "loadType": "default", "mipsToGenerate": 0, "name": "Default",
                           "resourceType": "GMTextureGroup", "resourceVersion": "2.0", "targets": -1}],
    }
    if write_if_changed(os.path.join(ROOT, PROJECT + ".yyp"), gm_json(yyp)):
        changed.append(PROJECT + ".yyp")

    print(f"[gm_gen] resources={len(resources)} folders={len(folders)} changed={len(changed)}")
    for c in changed:
        print("  ~", c)


if __name__ == "__main__":
    main()

