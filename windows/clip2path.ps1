param(
    $hostname = 'devbox.tailf9563c.ts.net',
    $user = 'syzom',
    $remoteDir = '/tmp/wezterm-clip'
)

$ErrorActionPreference = 'Stop'

$image = Get-Clipboard -Format Image -ErrorAction SilentlyContinue
if (-not $image) {
    exit 1
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$localFile = Join-Path $env:TEMP "clip_$timestamp.png"
$remoteFile = "$remoteDir/clip_$timestamp.png"

try {
    $image.Save($localFile, [System.Drawing.Imaging.ImageFormat]::Png)

    ssh -o StrictHostKeyChecking=accept-new "${user}@${hostname}" "mkdir -p '$remoteDir'"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    scp -o StrictHostKeyChecking=accept-new $localFile "${user}@${hostname}:${remoteFile}"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Set-Clipboard -Value $remoteFile
    exit 0
}
finally {
    if (Test-Path -LiteralPath $localFile) {
        Remove-Item -LiteralPath $localFile -Force
    }

    if ($image) {
        $image.Dispose()
    }
}
