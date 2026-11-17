#!/usr/bin/env bash
# Despliega el stack con AWS SAM. Requiere AWS CLI y SAM CLI y credenciales en variables de entorno.
set -euo pipefail
cd "$(dirname "$0")"

STACK="rastro-ayuda"
MODEL="${BEDROCK_MODEL_ID:-}"
TEAM="${TEAM_ID:?Define TEAM_ID con tu id publico del portal, por ejemplo T009}"

sam build
sam deploy --stack-name "$STACK" --resolve-s3 --capabilities CAPABILITY_IAM \
  --no-confirm-changeset --no-fail-on-empty-changeset \
  --parameter-overrides "BedrockModelId=$MODEL" "TeamId=$TEAM"
aws cloudformation describe-stacks --stack-name "$STACK" --query "Stacks[0].Outputs" --output table
