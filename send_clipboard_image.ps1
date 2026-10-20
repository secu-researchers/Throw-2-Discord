param(
  [string]$Session = "",   # session id: YYYYMMDD_HHMMSS_<first 8 of sha256>
  [string]$Note = "",      # defang IOCs in the note
  [switch]$Keep            # keep the temp file after sending
)
$ErrorActionPreference = "Stop"

# First run only: put the real Webhook URL here in the local copy, never in documents or repositories.
# After the environment variable is registered, set this to "".
$WebhookUrl = "https://discord.com/api/webhooks/XXXXX" # Fix Here!

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne "STA") {
  throw "Run in STA mode (powershell.exe -STA) to read the clipboard."
}

$url = [Environment]::GetEnvironmentVariable("DISCORD_WEBHOOK_URL", "User")
if (-not $url -and $WebhookUrl -match '^https://discord(app)?\.com/api/webhooks/') {
  [Environment]::SetEnvironmentVariable("DISCORD_WEBHOOK_URL", $WebhookUrl, "User")   # register on first run
  $url = $WebhookUrl
}
if (-not $url) { throw 'No Webhook URL. Set $WebhookUrl at the top of this script and run again.' }

if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
  throw "No image in the clipboard. Capture with Win+Shift+S first."
}
$img = [System.Windows.Forms.Clipboard]::GetImage()

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$name  = if ($Session) { "${Session}_$stamp" } else { $stamp }
$dir   = Join-Path $env:TEMP "report_send"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$path  = Join-Path $dir "$name.png"

try {
  $img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)   # re-encode as PNG
  $img.Dispose()
  if ((Get-Item -LiteralPath $path).Length -gt 8MB) { throw "File is larger than 8MB." }   # temporary limit

  $content = ("$name $Note").Trim()
  curl.exe -sS --fail -F "content=$content" -F "file=@$path;type=image/png" $url
  if ($LASTEXITCODE -ne 0) { throw "Upload failed: curl exit code $LASTEXITCODE" }
  Write-Host "Sent: $name.png"
}
finally {
  if (-not $Keep -and (Test-Path -LiteralPath $path)) { Remove-Item -LiteralPath $path -Force }
}