Add-Type -AssemblyName System.Drawing

$srcPath = 'C:\Users\hp\Downloads\Kbee.jpeg'
$bud      = 'C:\Users\hp\Documents\Default Project\public'
$iconDir  = Join-Path $bud 'icons'
New-Item -ItemType Directory -Path $iconDir -Force | Out-Null

$src = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "Source WxH: $($src.Width)x$($src.Height)"

function New-Draw([int]$size, [double]$padFraction, [string]$outPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $pad = [Math]::Floor($size * $padFraction)
    $tile = (Get-TileSize $size)
    $srcRect = New-Object System.Drawing.Rectangle($tile.X, $tile.Y, $tile.W, $tile.H)
    $dstRect = New-Object System.Drawing.Rectangle($pad, $pad, ($size - 2*$pad), ($size - 2*$pad))
    $g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "  OK $outPath ($size x $size)"
    $g.Dispose(); $bmp.Dispose()
}

function Get-TileSize([int]$size) {
    $sw = $src.Width; $sh = $src.Height
    $min = [Math]::Min($sw, $sh)
    $x = [Math]::Floor(($sw - $min) / 2)
    $y = [Math]::Floor(($sh - $min) / 2)
    New-Object System.Drawing.Rectangle($x, $y, $min, $min)
}

New-Draw 512 0.0 (Join-Path $bud 'logo.png')
New-Draw 180 0.0 (Join-Path $bud 'apple-touch-icon.png')
New-Draw 192 0.0 (Join-Path $iconDir 'icon-192.png')
New-Draw 512 0.0 (Join-Path $iconDir 'icon-512.png')
New-Draw 192 0.12 (Join-Path $iconDir 'maskable-192.png')
New-Draw 512 0.12 (Join-Path $iconDir 'maskable-512.png')

$fb = New-Object System.Drawing.Bitmap(48, 48)
$fg = [System.Drawing.Graphics]::FromImage($fb)
$fg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$fg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$fg.Clear([System.Drawing.Color]::Transparent)
$t = (Get-TileSize 48)
$fg.DrawImage($src, (New-Object System.Drawing.Rectangle(0,0,48,48)), (New-Object System.Drawing.Rectangle($t.X,$t.Y,$t.W,$t.H)), [System.Drawing.GraphicsUnit]::Pixel)
$hIcon = $fb.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = [System.IO.File]::Create((Join-Path $bud 'favicon.ico'))
$icon.Save($fs); $fs.Close()
Write-Host "  OK favicon.ico"
$src.Dispose()
Write-Host "All done"