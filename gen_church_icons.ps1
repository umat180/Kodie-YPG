Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile('C:\Users\hp\Downloads\Kbee.jpeg')
$outDir = 'C:\Users\hp\Desktop\krobo ypg\icons'

$sizes = @(
    @{ Name = 'icon-32.png';   Size = 32;  Pad = 0 },
    @{ Name = 'icon-72.png';   Size = 72;  Pad = 0 },
    @{ Name = 'icon-96.png';   Size = 96;  Pad = 0 },
    @{ Name = 'icon-128.png';  Size = 128; Pad = 0 },
    @{ Name = 'icon-144.png';  Size = 144; Pad = 0 },
    @{ Name = 'icon-152.png';  Size = 152; Pad = 0 },
    @{ Name = 'icon-180.png';  Size = 180; Pad = 0 },
    @{ Name = 'icon-192.png';  Size = 192; Pad = 0 },
    @{ Name = 'icon-384.png';  Size = 384; Pad = 0 },
    @{ Name = 'icon-512.png';  Size = 512; Pad = 0 },
    @{ Name = 'maskable-192.png'; Size = 192; Pad = 0.15 },
    @{ Name = 'maskable-512.png'; Size = 512; Pad = 0.15 }
)

foreach ($cfg in $sizes) {
    $size = $cfg.Size
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $pad = [Math]::Floor($size * $cfg.Pad)
    $drawSize = $size - (2 * $pad)
    $srcRect = New-Object System.Drawing.Rectangle(0, 0, $src.Width, $src.Height)
    $dstRect = New-Object System.Drawing.Rectangle($pad, $pad, $drawSize, $drawSize)
    $g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $bmp.Save((Join-Path $outDir $cfg.Name), [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host ("  OK {0} ({1}x{1})" -f $cfg.Name, $size)
    $g.Dispose(); $bmp.Dispose()
}

# favicon.ico
$fb = New-Object System.Drawing.Bitmap(48, 48)
$fg = [System.Drawing.Graphics]::FromImage($fb)
$fg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$fg.Clear([System.Drawing.Color]::Transparent)
$fr = New-Object System.Drawing.Rectangle(0, 0, 48, 48)
$fg.DrawImage($src, $fr, (New-Object System.Drawing.Rectangle(0, 0, $src.Width, $src.Height)), [System.Drawing.GraphicsUnit]::Pixel)
$hIcon = $fb.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = [System.IO.File]::Create((Join-Path $outDir 'favicon.ico'))
$icon.Save($fs); $fs.Close()
Write-Host "  OK favicon.ico"
$src.Dispose()
Write-Host "All icons done"