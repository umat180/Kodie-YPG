cd 'C:\Users\hp\Desktop\krobo-ypg-api'
Start-Process node -ArgumentList 'server.js' -WindowStyle Hidden
Start-Sleep -Seconds 3
try {
    $r = Invoke-WebRequest -Uri 'http://localhost:8085/health' -UseBasicParsing
    Write-Host ('Health check: HTTP ' + $r.StatusCode + ' - ' + $r.Content)
} catch {
    Write-Host ('Health check FAILED: ' + $_.Exception.Message)
}
# Kill the node process
Get-Process node -ErrorAction SilentlyContinue | Stop-Process
Write-Host 'Test complete'