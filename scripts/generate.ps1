<#
.SYNOPSIS
    Generates all derived raster (.png, .ico) and Win32 resource (.res) assets
    from the canonical master SVGs in svg/.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Drawing

$BrandRoot = Split-Path -Parent $PSScriptRoot
$SvgDir    = Join-Path $BrandRoot 'svg'
$PngDir    = Join-Path $BrandRoot 'png'
$IcoDir    = Join-Path $BrandRoot 'ico'

New-Item -ItemType Directory -Force -Path $PngDir, $IcoDir | Out-Null

function Get-SvgLayers([string]$Path) {
    $txt = [System.IO.File]::ReadAllText($Path)
    $rx = [regex]'fill="([^"]+)"(?:\s+fill-rule="([^"]+)")?[^>]*d="([^"]+)"'
    $res = @()
    foreach ($m in $rx.Matches($txt)) {
        $rule = if ($m.Groups[2].Success) { $m.Groups[2].Value } else { 'nonzero' }
        $res += ,@( $m.Groups[1].Value, $rule, $m.Groups[3].Value )
    }
    return ,$res
}

function Build-GraphicsPath([string]$D, [string]$Rule, [float]$Ox, [float]$Oy, [float]$Scale) {
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.FillMode = if ($Rule -eq 'evenodd') {
        [System.Drawing.Drawing2D.FillMode]::Alternate
    } else {
        [System.Drawing.Drawing2D.FillMode]::Winding
    }
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    $tokens = [regex]::Matches($D, '[MLCZ]|-?\d+(?:\.\d+)?') | ForEach-Object { $_.Value }
    $i = 0
    $cx = 0.0; $cy = 0.0; $sx = 0.0; $sy = 0.0
    while ($i -lt $tokens.Count) {
        $t = $tokens[$i]; $i++
        if ($t -eq 'M') {
            $gp.StartFigure()
            $cx = $Ox + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $cy = $Oy + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $sx = $cx; $sy = $cy
        } elseif ($t -eq 'L') {
            $nx = $Ox + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $ny = $Oy + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            if ([Math]::Abs($nx - $cx) -gt 0.001 -or [Math]::Abs($ny - $cy) -gt 0.001) {
                $gp.AddLine([float]$cx, [float]$cy, [float]$nx, [float]$ny)
            }
            $cx = $nx; $cy = $ny
        } elseif ($t -eq 'C') {
            $x1 = $Ox + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $y1 = $Oy + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $x2 = $Ox + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $y2 = $Oy + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $x3 = $Ox + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $y3 = $Oy + [float]::Parse($tokens[$i], $inv) * $Scale; $i++
            $gp.AddBezier([float]$cx, [float]$cy, [float]$x1, [float]$y1, [float]$x2, [float]$y2, [float]$x3, [float]$y3)
            $cx = $x3; $cy = $y3
        } elseif ($t -eq 'Z') {
            $gp.CloseFigure()
            $cx = $sx; $cy = $sy
        }
    }
    return $gp
}

$DarkMonoLayers = Get-SvgLayers (Join-Path $SvgDir 'nikrun-icon-dark-mono.svg')

function Render-IconPngBytes([int]$Size, [bool]$SolidBg, [float]$PadRatio) {
    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    if ($SolidBg) {
        $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#0b0e14'))
    } else {
        $g.Clear([System.Drawing.Color]::Transparent)
    }
    # Tight bounds of dark-mono rim in 256x256 space: w=216.6, h=224.1, center=(128, 127.85)
    $avail = $Size * (1.0 - 2.0 * $PadRatio)
    $sc = $avail / 224.1
    $ox = ($Size * 0.5) - 128.0 * $sc
    $oy = ($Size * 0.5) - 127.85 * $sc
    foreach ($layer in $DarkMonoLayers) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($layer[0]))
        $gp = Build-GraphicsPath $layer[2] $layer[1] $ox $oy $sc
        $g.FillPath($brush, $gp)
        $gp.Dispose(); $brush.Dispose()
    }
    $g.Dispose()
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    return ,$ms.ToArray()
}

# 1. Multi-resolution nikrun.ico (16, 24, 32, 48, 256 px PNG-encoded frames)
#    Used for nik.exe Windows application icon AND browser favicon.ico!
$IcoSizes = @(16, 24, 32, 48, 256)
$IcoFrames = @()
foreach ($sz in $IcoSizes) {
    $IcoFrames += ,@( $sz, (Render-IconPngBytes $sz $false 0.02) )
}

$icoMs = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter($icoMs)
$bw.Write([uint16]0)
$bw.Write([uint16]1)
$bw.Write([uint16]$IcoFrames.Count)
$offset = 6 + 16 * $IcoFrames.Count
foreach ($fr in $IcoFrames) {
    $sz = $fr[0]; $bytes = $fr[1]
    $wByte = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
    $bw.Write($wByte)
    $bw.Write($wByte)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([uint16]1)
    $bw.Write([uint16]32)
    $bw.Write([uint32]$bytes.Length)
    $bw.Write([uint32]$offset)
    $offset += $bytes.Length
}
foreach ($fr in $IcoFrames) {
    $bw.Write([byte[]]$fr[1])
}
$bw.Flush()
$IcoPath = Join-Path $IcoDir 'nikrun.ico'
[System.IO.File]::WriteAllBytes($IcoPath, $icoMs.ToArray())
$bw.Dispose(); $icoMs.Dispose()
Write-Host "Generated $IcoPath (16, 24, 32, 48, 256 px)"

# 2. Standard PNG exports
[System.IO.File]::WriteAllBytes((Join-Path $PngDir 'nikrun-icon-256.png'), (Render-IconPngBytes 256 $false 0.04))
[System.IO.File]::WriteAllBytes((Join-Path $PngDir 'apple-touch-icon-180.png'), (Render-IconPngBytes 180 $true 0.14))
[System.IO.File]::WriteAllBytes((Join-Path $PngDir 'nikrun-avatar-512.png'), (Render-IconPngBytes 512 $true 0.14))

# Transparent 2x Retina Lockup PNGs (for VS Code Marketplace README, which restricts external SVGs)
function Render-LockupPng([string]$SvgFile, [string]$OutPngFile) {
    $layers = Get-SvgLayers $SvgFile
    # ViewBox is 841 x 256 -> render at 2x height = 160px (526 x 160 px)
    $h = 160
    $sc = [float]$h / 256.0
    $w = [int][Math]::Round(841.0 * $sc)
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gl = [System.Drawing.Graphics]::FromImage($bmp)
    $gl.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gl.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gl.Clear([System.Drawing.Color]::Transparent)
    foreach ($layer in $layers) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($layer[0]))
        $gp = Build-GraphicsPath $layer[2] $layer[1] 0 0 $sc
        $gl.FillPath($brush, $gp)
        $gp.Dispose(); $brush.Dispose()
    }
    $gl.Dispose()
    $bmp.Save($OutPngFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}
Render-LockupPng (Join-Path $SvgDir 'nikrun-lockup-light.svg') (Join-Path $PngDir 'nikrun-lockup-light.png')
Render-LockupPng (Join-Path $SvgDir 'nikrun-lockup-dark-mono.svg') (Join-Path $PngDir 'nikrun-lockup-dark-mono.png')
Write-Host "Generated PNG assets in $PngDir"

# 4. OpenGraph / Social Preview Card (1200x630)
$ogW = 1200; $ogH = 630
$bmpOg = New-Object System.Drawing.Bitmap($ogW, $ogH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmpOg)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#0b0e14'))

$penBorder = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#1e2736'), 2.0)
$g.DrawRectangle($penBorder, 48, 48, 1104, 534)
$accentBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#38bdf8'))
$g.FillRectangle($accentBrush, 48, 48, 1104, 4)

$lockupLayers = Get-SvgLayers (Join-Path $SvgDir 'nikrun-lockup-dark-mono.svg')
foreach ($layer in $lockupLayers) {
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($layer[0]))
    $gp = Build-GraphicsPath $layer[2] $layer[1] 104 115 0.68
    $g.FillPath($brush, $gp)
    $gp.Dispose(); $brush.Dispose()
}

$fontKw   = New-Object System.Drawing.Font('Cascadia Code', 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontCode = New-Object System.Drawing.Font('Cascadia Code', 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontHero = New-Object System.Drawing.Font('Cascadia Code', 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bComment = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#8294ab'))
$bCyan    = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#38bdf8'))
$bWhite   = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#f1f5f9'))
$bMuted   = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#7c8b9e'))
$bYellow  = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#facc15'))
$bPurple  = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#c084fc'))

$g.DrawString('// Modern, zero-config toolchain for Free Pascal.', $fontHero, $bComment, 112, 336)
$g.DrawString("// Portable multi-arch SDKs $([char]0x00B7) nik.yaml $([char]0x00B7) built-in LSP $([char]0x00B7) VS Code", $fontCode, $bMuted, 112, 378)

$yBot = 486
$sf = [System.Drawing.StringFormat]::GenericTypographic
$charW = $g.MeasureString('MM', $fontCode, 2000, $sf).Width - $g.MeasureString('M', $fontCode, 2000, $sf).Width
function Draw-Token([string]$Txt, $Font, $Brush, [float]$X, [float]$Y) {
    $trimmed = $Txt.TrimEnd(' ')
    if ($trimmed.Length -gt 0) {
        $g.DrawString($trimmed, $Font, $Brush, $X, $Y, $sf)
    }
    return $X + ($Txt.Length * $charW)
}
$cx = 112.0
$cx = Draw-Token 'uses ' $fontKw $bCyan $cx $yBot
$cx = Draw-Token 'cli' $fontKw $bWhite $cx $yBot
$cx = Draw-Token ', ' $fontCode $bMuted $cx $yBot
$cx = Draw-Token 'sdk' $fontKw $bWhite $cx $yBot
$cx = Draw-Token ', ' $fontCode $bMuted $cx $yBot
$cx = Draw-Token 'vscode' $fontKw $bWhite $cx $yBot
$cx = Draw-Token ';    ' $fontCode $bMuted $cx $yBot
$cx = Draw-Token '{$mode objfpc}{$H+}' $fontCode $bPurple $cx $yBot

$domainTxt = 'nikrun.dev'
$domW = $g.MeasureString($domainTxt, $fontKw, 2000, $sf).Width
$g.DrawString($domainTxt, $fontKw, $bYellow, (1088.0 - $domW), $yBot, $sf)

$g.Dispose()
$OgPath = Join-Path $PngDir 'og-image-1200x630.png'
$bmpOg.Save($OgPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmpOg.Dispose()
Write-Host "Generated $OgPath"

# 4. GitHub Repository Social Preview Cards (1280x640, exact 2:1 GitHub Settings -> Social preview size)
$ghCards = @(
    @{
        file   = 'github-social-nikrun.png'
        suffix = ''
        line1  = '// Modern, zero-config toolchain for Free Pascal.'
        line2  = "// Portable multi-arch SDKs $([char]0x00B7) nik.yaml $([char]0x00B7) built-in LSP $([char]0x00B7) VS Code"
        kw     = 'uses '
        ident  = 'cli, sdk, vscode'
        right  = 'github.com/nikrun'
    },
    @{
        file   = 'github-social-cli.png'
        suffix = '/cli'
        line1  = '// Standalone zero-dependency toolchain CLI for Free Pascal.'
        line2  = "// SDK manager $([char]0x00B7) nik.yaml builder $([char]0x00B7) packages $([char]0x00B7) built-in LSP"
        kw     = 'program '
        ident  = 'nik'
        right  = 'github.com/nikrun/cli'
    },
    @{
        file   = 'github-social-sdk.png'
        suffix = '/sdk'
        line1  = '// Portable, SHA-256 verified Free Pascal compiler SDKs.'
        line2  = "// Multi-version (3.2.2..3.3.1) $([char]0x00B7) win64, linux & darwin (x86_64 & aarch64)"
        kw     = 'unit '
        ident  = 'nikrun.sdk'
        right  = 'github.com/nikrun/sdk'
    },
    @{
        file   = 'github-social-vscode.png'
        suffix = '/vscode'
        line1  = '// Zero-config Free Pascal & Object Pascal support for VS Code.'
        line2  = "// Built-in nik lsp $([char]0x00B7) SDK & profile switchers $([char]0x00B7) nik.yaml schema"
        kw     = 'unit '
        ident  = 'nikrun.vscode'
        right  = 'github.com/nikrun/vscode'
    },
    @{
        file   = 'github-social-web.png'
        suffix = '/web'
        line1  = '// Official nikrun.dev landing page, docs & installer endpoints.'
        line2  = "// VitePress docs $([char]0x00B7) install.ps1 & install.sh $([char]0x00B7) user-scope setup"
        kw     = 'unit '
        ident  = 'nikrun.web'
        right  = 'github.com/nikrun/web'
    },
    @{
        file   = 'github-social-brand.png'
        suffix = '/brand'
        line1  = '// Official logos, icons, favicons & social preview cards.'
        line2  = "// Canonical SVG masters $([char]0x00B7) multi-frame ICO $([char]0x00B7) deterministic PNGs"
        kw     = 'unit '
        ident  = 'nikrun.brand'
        right  = 'github.com/nikrun/brand'
    },
    @{
        file   = 'github-social-build-lib.png'
        suffix = '/build-lib'
        line1  = '// Shared PowerShell build, SBOM & release automation library.'
        line2  = "// Versioning $([char]0x00B7) changelog specs $([char]0x00B7) CycloneDX SBOM $([char]0x00B7) GitHub Actions"
        kw     = 'unit '
        ident  = 'nikrun.build'
        right  = 'github.com/nikrun/build-lib'
    }
)

$fontBadge = New-Object System.Drawing.Font('Cascadia Code', 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

foreach ($card in $ghCards) {
    $cw = 1280; $ch = 640
    $bmpCard = New-Object System.Drawing.Bitmap($cw, $ch, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gc = [System.Drawing.Graphics]::FromImage($bmpCard)
    $gc.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gc.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $gc.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gc.Clear([System.Drawing.ColorTranslator]::FromHtml('#0b0e14'))

    # Safe-zone editor frame (64px margin around 1280x640 so mobile/social crops never clip)
    $gc.DrawRectangle($penBorder, 64, 56, 1152, 528)
    $gc.FillRectangle($accentBrush, 64, 56, 1152, 4)

    foreach ($layer in $lockupLayers) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($layer[0]))
        $gp = Build-GraphicsPath $layer[2] $layer[1] 120 120 0.68
        $gc.FillPath($brush, $gp)
        $gp.Dispose(); $brush.Dispose()
    }

    if ($card.suffix.Length -gt 0) {
        # Lockup width at scale 0.68 is 841 * 0.68 = 571.9 -> starts right after "nikrun" at x=702
        $gc.DrawString($card.suffix, $fontBadge, $bCyan, 700, 173, $sf)
    }

    $gc.DrawString($card.line1, $fontHero, $bComment, 128, 342)
    $gc.DrawString($card.line2, $fontCode, $bMuted, 128, 384)

    $cyBot = 492
    $charWCard = $gc.MeasureString('MM', $fontCode, 2000, $sf).Width - $gc.MeasureString('M', $fontCode, 2000, $sf).Width
    $xPos = 128.0
    $gc.DrawString($card.kw.TrimEnd(' '), $fontKw, $bCyan, $xPos, $cyBot, $sf)
    $xPos += $card.kw.Length * $charWCard
    $gc.DrawString($card.ident, $fontKw, $bWhite, $xPos, $cyBot, $sf)
    $xPos += $card.ident.Length * $charWCard
    $gc.DrawString(';', $fontCode, $bMuted, $xPos, $cyBot, $sf)
    $xPos += 5 * $charWCard
    $gc.DrawString('{$mode objfpc}{$H+}', $fontCode, $bPurple, $xPos, $cyBot, $sf)

    $rwTxt = $card.right
    $rwW = $gc.MeasureString($rwTxt, $fontKw, 2000, $sf).Width
    $gc.DrawString($rwTxt, $fontKw, $bYellow, (1152.0 - $rwW), $cyBot, $sf)

    $gc.Dispose()
    $cardPath = Join-Path $PngDir $card.file
    $bmpCard.Save($cardPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmpCard.Dispose()
    Write-Host "Generated $cardPath"
}
