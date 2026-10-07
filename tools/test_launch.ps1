$exe = "build\Quazerium\Quazerium.exe"
if (-not (Test-Path $exe)) {
    Write-Error "Executable not found: $exe"
    exit 1
}
Write-Output "Starting process: $exe"
$p = Start-Process -FilePath $exe -WorkingDirectory "build\Quazerium" -PassThru
Start-Sleep -Seconds 2
if ($p.HasExited) {
    Write-Output "Process exited prematurely with exit code: $($p.ExitCode)"
    exit 2
} else {
    Write-Output "Process is running successfully! (PID: $($p.Id))"
    Stop-Process -Id $p.Id -Force
    Write-Output "Process stopped cleanly after verification."
    exit 0
}
