param(
    [Parameter(Mandatory = $true)][int]$Ctx,
    [Parameter(Mandatory = $true)][string]$HermesHome,
    [string]$BaseUrl = "http://127.0.0.1:7777/v1",
    [string]$ModelName = "local",
    [string]$BackendModel = "",
    [string]$ApiKey = "any",
    [switch]$SkipLiteLLM
)

$ErrorActionPreference = "Stop"

if (-not $BackendModel) {
    try {
        $m = Invoke-RestMethod "http://127.0.0.1:7776/v1/models" -TimeoutSec 3
        if ($m.data -and $m.data.Count -gt 0) { $BackendModel = [string]$m.data[0].id }
    } catch {}
}
if (-not $BackendModel) { $BackendModel = "local" }

if (-not $SkipLiteLLM) {
    $litellm = @"
model_list:
  - model_name: local
    litellm_params:
      model: openai/$BackendModel
      api_base: http://127.0.0.1:7776/v1
      api_key: "$ApiKey"
    model_info:
      max_input_tokens: $Ctx
      max_context_length: $Ctx
  - model_name: $BackendModel
    litellm_params:
      model: openai/$BackendModel
      api_base: http://127.0.0.1:7776/v1
      api_key: "$ApiKey"
    model_info:
      max_input_tokens: $Ctx
      max_context_length: $Ctx

litellm_settings:
  drop_params: true
"@
    Set-Content -Path (Join-Path $PSScriptRoot "litellm-config.yaml") -Value $litellm -Encoding UTF8
}

New-Item -ItemType Directory -Force -Path $HermesHome | Out-Null

$hermesUrl = "http://127.0.0.1:7776/v1"
$hermesModel = $BackendModel

$yaml = @"
model:
  default: "$hermesModel"
  provider: custom
  base_url: "$hermesUrl"
  api_key: "$ApiKey"
  context_length: $Ctx

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
Set-Content -Path (Join-Path $HermesHome "config.yaml") -Value $yaml -Encoding UTF8

Set-Content -Path (Join-Path $HermesHome ".env") -Value "OPENAI_API_KEY=$ApiKey" -Encoding ASCII

Write-Host "Runtime config: CTX=$Ctx  Hermes=$hermesUrl  model=$hermesModel"
