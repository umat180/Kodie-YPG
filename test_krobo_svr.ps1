Start-Process node -ArgumentList 'serve.js' -WorkingDirectory 'C:\Users\hp\Desktop\krobo ypg' -WindowStyle Hidden
Start-Sleep -Seconds 2
$tests = @(
  'http://localhost:8083/index.html',
  'http://localhost:8083/manifest.json',
  'http://localhost:8083/sw.js',
  'http://localhost:8083/logo.png',
  'http://localhost:8083/icons/icon-192.png'
)
foreach ($u in $tests) {
  try {
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing
    Write-Host ($u + ' -> HTTP ' + $r.StatusCode)
  } catch {
    Write-Host ($u + ' -> ERROR: ' + $_.Exception.Message)
  }
}
# verify manifest content-type
try { $m = Invoke-WebRequest -Uri 'http://localhost:8083/manifest.json' -UseBasicParsing; Write-Host ('manifest Content-Type: ' + $m.Headers['Content-Type']) } catch {}
# verify sw.js content-type
try { $s = Invoke-WebRequest -Uri 'http://localhost:8083/sw.js' -UseBasicParsing; Write-Host ('sw Content-Type: ' + $s.Headers['Content-Type']) } catch {}