#!/bin/bash
# run-tests-qase.sh — executa os testes e envia resultados ao Qase TMS
# Uso:
#   ./run-tests-qase.sh                              # @regression em production
#   ./run-tests-qase.sh @smoke                       # smoke
#   ./run-tests-qase.sh @barling                     # so barling
#   ./run-tests-qase.sh @messages production "Titulo"

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:/usr/bin:$PATH"
MVN="$HOME/.local/bin/mvn"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

TAGS="${1:-@regression}"
ENV="${2:-production}"
TITLE_PREFIX="${3:-Automated test - API}"

# Monta array de flags -D e le variaveis especificas do .env
declare -a ENV_FLAGS=()
QASE_TOKEN=""
QASE_PROJECT="PA"

if [ -f "$ENV_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue
    if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="${BASH_REMATCH[2]}"
      val="${val%\"}"
      val="${val#\"}"
      ENV_FLAGS+=("-D${key}=${val}")
      [[ "$key" == "QASE_TESTOPS_API_TOKEN" ]] && QASE_TOKEN="$val"
      [[ "$key" == "QASE_TESTOPS_PROJECT" ]] && QASE_PROJECT="$val"
    fi
  done < "$ENV_FILE"
fi

# Monta titulo com data
PROJECT_DEV_LABEL=${PROJECT_DEV:+[$PROJECT_DEV] }
BRANCH_NAME_LABEL=${BRANCH_NAME:+[$BRANCH_NAME] }
RUN_TITLE="${BRANCH_NAME_LABEL}${PROJECT_DEV_LABEL}${TITLE_PREFIX} - run $(date '+%d-%m-%Y %H:%M:%S')"

echo "Rodando testes Karate..."
echo "Tags:     $TAGS"
echo "Ambiente: $ENV"
echo "Titulo:   $RUN_TITLE"
echo ""

# ── 1. Cria o run no Qase ──────────────────────────────────────────────────────
echo "Criando run no Qase (projeto $QASE_PROJECT)..."
CREATE_RESPONSE=$(curl -sS --request POST \
  --url "https://api.qase.io/v1/run/$QASE_PROJECT" \
  --header "Token: $QASE_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{\"title\":\"$RUN_TITLE\",\"is_autotest\":true}")

RUN_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')

if [ -z "$RUN_ID" ]; then
  echo "ERRO: nao foi possivel criar o run no Qase."
  echo "Resposta: $CREATE_RESPONSE"
  exit 1
fi

echo "Run criado — ID: $RUN_ID"
echo ""

# ── 2. Executa os testes ───────────────────────────────────────────────────────
"$MVN" test \
  "${ENV_FLAGS[@]}" \
  -Dkarate.env="$ENV" \
  -Dkarate.options="--tags $TAGS" \
  -DQASE_MODE=testops \
  -DQASE_TESTOPS_API_TOKEN="$QASE_TOKEN" \
  -DQASE_TESTOPS_PROJECT="$QASE_PROJECT" \
  -DQASE_TESTOPS_RUN_ID="$RUN_ID"

TEST_EXIT_CODE=$?

# ── 3. Fecha o run ─────────────────────────────────────────────────────────────
echo ""
echo "Fechando run no Qase..."
curl -sS --request POST \
  --url "https://api.qase.io/v1/run/$QASE_PROJECT/$RUN_ID/complete" \
  --header "Token: $QASE_TOKEN" \
  --header "accept: application/json" > /dev/null

echo "Concluido."
echo ""
echo "Relatorio HTML: target/karate-reports/karate-summary.html"
echo "Ver no Qase:    https://app.qase.io/run/$QASE_PROJECT/dashboard/$RUN_ID"

exit $TEST_EXIT_CODE
