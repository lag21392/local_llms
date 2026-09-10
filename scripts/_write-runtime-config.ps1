param(
    [Parameter(Mandatory = $true)][int]$Ctx,
    [Parameter(Mandatory = $true)][string]$HermesHome,
    [string]$BaseUrl = "https://correct-ibex-charmed.ngrok-free.app/v1",
    [string]$ModelName = "local",
    [string]$BackendModel = "",
    [string]$ApiKey = "any",
    [switch]$SkipLiteLLM
)

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

if (-not $BackendModel) {
    try {
        $m = Invoke-RestMethod "http://127.0.0.1:7776/v1/models" -TimeoutSec 3
        if ($m.data -and $m.data.Count -gt 0) { $BackendModel = [string]$m.data[0].id }
    } catch {}
}
if (-not $BackendModel) { $BackendModel = "local" }

if (-not $SkipLiteLLM) {
    $models = @(
        @{ name = $ModelName; backend = $BackendModel }
    )
    if ($BackendModel -and $BackendModel -ne $ModelName) {
        $models += @{ name = $BackendModel; backend = $BackendModel }
    }

    $entries = foreach ($item in $models) {
        @"
  - model_name: $($item.name)
    litellm_params:
      model: openai/$($item.backend)
      api_base: http://127.0.0.1:7776/v1
      api_key: "$ApiKey"
    model_info:
      max_input_tokens: $Ctx
      max_context_length: $Ctx
"@
    }

    $litellm = @"
model_list:
$($entries -join "`n")

litellm_settings:
  drop_params: true
"@
    Write-Utf8NoBom (Join-Path $PSScriptRoot "litellm-config.yaml") $litellm
}

New-Item -ItemType Directory -Force -Path $HermesHome | Out-Null

$ngrokHeaders = ""
if ($BaseUrl -match "ngrok") {
    $ngrokHeaders = @"

  extra_headers:
    ngrok-skip-browser-warning: "true"
  default_headers:
    ngrok-skip-browser-warning: "true"
"@
}

$yaml = @"
model:
  default: "$ModelName"
  provider: custom
  base_url: "$BaseUrl"
  api_key: "$ApiKey"
  context_length: $Ctx$ngrokHeaders

compression:
  enabled: true

platform_toolsets:
  cli: [file, terminal]

agent:
  disabled_toolsets:
    - web
    - browser
    - vision
    - image_gen
    - tts
    - memory
    - delegation
    - cron
    - skills
    - mcp
"@
Write-Utf8NoBom (Join-Path $HermesHome "config.yaml") $yaml

Set-Content -Path (Join-Path $HermesHome ".env") -Value "OPENAI_API_KEY=$ApiKey" -Encoding ASCII

Write-Host "Runtime config: CTX=$Ctx  Hermes=$BaseUrl  model=$ModelName  backend=$BackendModel"
