[CmdletBinding()]
param(
    [switch]$SkipFontInstall
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$configSource = Join-Path $repoRoot 'wezterm.lua'
$uploaderSource = Join-Path $repoRoot 'windows\clip2path.ps1'
$autoHotkeySource = Join-Path $repoRoot 'windows\autohotkey\switch-same-app.ahk'
$configDirectory = Join-Path $HOME '.config\wezterm'
$configDestination = Join-Path $configDirectory 'wezterm.lua'
$uploaderDirectory = Join-Path $env:APPDATA 'wezterm'
$uploaderDestination = Join-Path $uploaderDirectory 'clip2path.ps1'
$autoHotkeyDirectory = Join-Path $HOME 'scripts'
$autoHotkeyDestination = Join-Path $autoHotkeyDirectory 'switch-same-app.ahk'
$autoHotkeyExecutable = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'
$autoHotkeyShortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\switch-same-app.ahk - Shortcut.lnk'
$legacyConfig = Join-Path $HOME '.wezterm.lua'
$legacyAhk = Join-Path $uploaderDirectory 'clip2path.ahk'
$legacyShortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\clip2path.ahk - Shortcut.lnk'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDirectory = Join-Path $HOME ".wezterm-backup\$timestamp"

function Backup-File {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    $safeName = $Path.Replace(':', '').Replace('\', '_')
    Copy-Item -LiteralPath $Path -Destination (Join-Path $backupDirectory $safeName) -Force
}

function Test-HackNerdFont {
    $fontLocations = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'),
        (Join-Path $env:WINDIR 'Fonts')
    )

    return [bool]($fontLocations | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object {
        Get-ChildItem -LiteralPath $_ -Filter 'HackNerdFontMono-Regular.ttf' -ErrorAction SilentlyContinue
    } | Select-Object -First 1)
}

function Install-HackNerdFont {
    if (Test-HackNerdFont) {
        Write-Host 'Hack Nerd Font Mono is already installed.'
        return
    }

    $tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "wezterm-font-$([guid]::NewGuid())"
    $archive = Join-Path $tempDirectory 'Hack.zip'
    $expanded = Join-Path $tempDirectory 'Hack'
    $fontDirectory = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    $fontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

    try {
        New-Item -ItemType Directory -Path $tempDirectory, $fontDirectory -Force | Out-Null
        Invoke-WebRequest -Uri 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip' -OutFile $archive
        Expand-Archive -LiteralPath $archive -DestinationPath $expanded -Force

        $fontFiles = Get-ChildItem -LiteralPath $expanded -Filter 'HackNerdFontMono-*.ttf'
        if (-not $fontFiles) {
            throw 'The Hack Nerd Font archive did not contain the expected mono font files.'
        }

        foreach ($font in $fontFiles) {
            $destination = Join-Path $fontDirectory $font.Name
            Copy-Item -LiteralPath $font.FullName -Destination $destination -Force
            New-ItemProperty -Path $fontRegistry -Name "$($font.BaseName) (TrueType)" -Value $destination -PropertyType String -Force | Out-Null
        }

        Write-Host 'Installed Hack Nerd Font Mono for the current Windows user.'
    }
    finally {
        if (Test-Path -LiteralPath $tempDirectory) {
            Remove-Item -LiteralPath $tempDirectory -Recurse -Force
        }
    }
}

foreach ($source in @($configSource, $uploaderSource, $autoHotkeySource)) {
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required repository file not found: $source"
    }
}

foreach ($file in @($legacyConfig, $configDestination, $uploaderDestination, $autoHotkeyDestination, $autoHotkeyShortcut, $legacyAhk, $legacyShortcut)) {
    Backup-File -Path $file
}

if (-not $SkipFontInstall) {
    Install-HackNerdFont
}

New-Item -ItemType Directory -Path $configDirectory, $uploaderDirectory, $autoHotkeyDirectory -Force | Out-Null
Copy-Item -LiteralPath $configSource -Destination $configDestination -Force
Copy-Item -LiteralPath $uploaderSource -Destination $uploaderDestination -Force
Copy-Item -LiteralPath $autoHotkeySource -Destination $autoHotkeyDestination -Force

if (Test-Path -LiteralPath $autoHotkeyExecutable) {
    $shortcutShell = New-Object -ComObject WScript.Shell
    $shortcut = $shortcutShell.CreateShortcut($autoHotkeyShortcut)
    $shortcut.TargetPath = $autoHotkeyDestination
    $shortcut.WorkingDirectory = $autoHotkeyDirectory
    $shortcut.Save()

    Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*switch-same-app.ahk*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    Start-Process -FilePath $autoHotkeyExecutable -ArgumentList $autoHotkeyDestination -WindowStyle Hidden
}
else {
    Write-Warning 'AutoHotkey v2 is not installed; the script was copied but not added to Startup.'
}

# The native WezTerm binding supersedes the Windows Terminal AutoHotkey hook.
Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*AppData\Roaming\wezterm\clip2path.ahk*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Remove-Item -LiteralPath $legacyAhk, $legacyShortcut -Force -ErrorAction SilentlyContinue

Write-Host "Installed WezTerm config: $configDestination"
Write-Host "Installed clipboard uploader: $uploaderDestination"
Write-Host "Installed AutoHotkey script: $autoHotkeyDestination"
if (Test-Path -LiteralPath $backupDirectory) {
    Write-Host "Backed up previous local files to: $backupDirectory"
}
Write-Host 'Start a new WezTerm window to ensure the newly installed font is loaded.'
