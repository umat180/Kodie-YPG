$conns = Get-NetTCPConnection -LocalPort 8083 -State Listen -ErrorAction SilentlyContinue
if ($conns) {
  $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($p in $pids) { Stop-Process -Id $p -Force; Write-Host "Stopped PID $p (8083)" }
} else { Write-Host "No server on 8083" }