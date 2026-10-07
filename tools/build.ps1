# Quazerium build / run / self-test via GameMaker Igor (CLI). No IDE required.
#   powershell -ExecutionPolicy Bypass -File tools/build.ps1            -> compile + package standalone Windows .exe
#   powershell -ExecutionPolicy Bypass -File tools/build.ps1 -Run       -> compile + package + launch game
#   powershell -ExecutionPolicy Bypass -File tools/build.ps1 -SelfTest  -> build + run automated tests, exit code = failures
param(
    [switch]$SelfTest,
    [switch]$Run,
    [int]$Timeout = 180,
    [string]$Runtime = "2026.0.0.23"
)
$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$rt = "C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-$Runtime"
$igor = Join-Path $rt "bin\igor\windows\x64\Igor.exe"
$runnerSource = Join-Path $rt "windows\x64\Runner.exe"
$user = Get-ChildItem "$env:APPDATA\GameMakerStudio2-LTS2026" -Directory | Where-Object { $_.Name -match '_' } | Select-Object -First 1
$work = Join-Path $env:TEMP "qz_build"
New-Item -ItemType Directory -Force "$work\cache", "$work\temp", "$work\out" | Out-Null

python (Join-Path $root "tools\gm_gen.py") $root
if ($LASTEXITCODE -ne 0) { throw "gm_gen failed" }

$buildDir = Join-Path $root "build\Quazerium"
New-Item -ItemType Directory -Force $buildDir | Out-Null

function Package-Game {
    if (Test-Path "$work\out\Quazerium.win") {
        Copy-Item $runnerSource -Destination (Join-Path $buildDir "Quazerium.exe") -Force
        Copy-Item "$work\out\Quazerium.win" -Destination (Join-Path $buildDir "data.win") -Force
        Copy-Item "$work\out\Quazerium.win" -Destination (Join-Path $buildDir "Quazerium.win") -Force
        Copy-Item $runnerSource -Destination (Join-Path "$work\out" "Quazerium.exe") -Force
        Copy-Item "$work\out\Quazerium.win" -Destination (Join-Path "$work\out" "data.win") -Force
        if (Test-Path "$work\out\options.ini") {
            Copy-Item "$work\out\options.ini" -Destination (Join-Path $buildDir "options.ini") -Force
        }
    }
}

if ($SelfTest) {
    $env:QZ_SELFTEST = "1"
    $log = Join-Path $work "igor.log"
    $igorArgs = @("-j=8", "--project=$root\Quazerium.yyp", "--user=$($user.FullName)", "--runtimePath=$rt",
              "--runtime=VM", "--cache=$work\cache", "--temp=$work\temp", "--of=$work\out\Quazerium.win",
              "-t=$Timeout", "--", "Windows", "Run")
    & $igor @igorArgs 2>&1 | Tee-Object -FilePath $log | ForEach-Object {
        if ($_ -match 'QZ|ERROR|Error|error|WARN|FATAL|failed|###') { $_ }
    }
    Package-Game
    $text = Get-Content $log -Raw
    if ($text -match 'QZ_SELFTEST_RESULT pass=(\d+) fail=(\d+)') {
        Write-Output "SELFTEST pass=$($Matches[1]) fail=$($Matches[2])"
        exit [int]$Matches[2]
    }
    Write-Output "SELFTEST did not report a result (see $log)"
    exit 99
} else {
    Remove-Item Env:QZ_SELFTEST -ErrorAction SilentlyContinue
    $log = Join-Path $work "igor.log"
    $igorArgs = @("-j=8", "--project=$root\Quazerium.yyp", "--user=$($user.FullName)", "--runtimePath=$rt",
              "--runtime=VM", "--cache=$work\cache", "--temp=$work\temp", "--of=$work\out\Quazerium.win",
              "--", "Windows", "Compile")
    & $igor @igorArgs 2>&1 | Tee-Object -FilePath $log | ForEach-Object {
        if ($_ -match 'ERROR|Error|error|FATAL|failed') { $_ }
    }
    Package-Game
    $targetExe = Join-Path $buildDir "Quazerium.exe"
    Write-Output "BUILD SUCCESSFUL"
    Write-Output "Executable: $targetExe"
    if ($Run) {
        Write-Output "Launching $targetExe..."
        Start-Process -FilePath $targetExe -WorkingDirectory $buildDir
    }
}
