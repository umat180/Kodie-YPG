$html = Get-Content -Raw 'C:\Users\hp\Desktop\krobo ypg\index.html'
$m = [regex]::Match($html, '(?s)<script>(.*?)</script>')
$out = 'C:\Users\hp\AppData\Local\Temp\opencode\krobo_check.js'
Set-Content -Path $out -Value $m.Groups[1].Value -Encoding UTF8 -NoNewline
Write-Host ('JS extracted: ' + $m.Groups[1].Value.Length + ' chars')

# Verify file structure
$files = @('index.html','manifest.json','sw.js','serve.js','START SITE.bat','logo.png')
$folders = @('icons')
foreach ($f in $files) {
    $p = Join-Path 'C:\Users\hp\Desktop\krobo ypg' $f
    Write-Host ("  $f -> " + $(if(Test-Path $p){(Get-Item $p).Length} else {'MISSING'}))
}
$icons = Get-ChildItem 'C:\Users\hp\Desktop\krobo ypg\icons' | Select-Object Name
Write-Host ("  icons: " + $icons.Count + " files")

# Verify manifest
$man = Get-Content 'C:\Users\hp\Desktop\krobo ypg\manifest.json' -Raw
Write-Host ("manifest name: " + ($man | ConvertFrom-Json).short_name)