Copy-Item 'C:\Users\hp\Downloads\Kbee.jpeg' 'C:\Users\hp\Desktop\krobo ypg\logo.png' -Force
Write-Host ('logo.png -> ' + (Get-Item 'C:\Users\hp\Desktop\krobo ypg\logo.png').Length + ' bytes')