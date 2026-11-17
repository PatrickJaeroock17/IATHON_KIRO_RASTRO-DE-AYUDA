# Despliega el stack con AWS SAM. Requiere AWS CLI y SAM CLI instalados y credenciales en variables de entorno.
# Antes: $env:TEAM_ID = "T009" (tu id publico del portal), $env:AWS_DEFAULT_REGION = "us-east-1"  y, si usas Bedrock, $env:BEDROCK_MODEL_ID = "<id del modelo>"
# Si PowerShell bloquea el script: powershell -ExecutionPolicy Bypass -File .\deploy.ps1
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$stack = "rastro-ayuda"
$team = $env:TEAM_ID
if (-not $team) { Write-Host 'Define primero $env:TEAM_ID con tu id publico del portal, por ejemplo T009'; exit 1 }
$model = ""
if ($env:BEDROCK_MODEL_ID) { $model = $env:BEDROCK_MODEL_ID }

sam build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

sam deploy --stack-name $stack --resolve-s3 --capabilities CAPABILITY_IAM --no-confirm-changeset --no-fail-on-empty-changeset --parameter-overrides "BedrockModelId=$model" "TeamId=$team"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

aws cloudformation describe-stacks --stack-name $stack --query "Stacks[0].Outputs" --output table
