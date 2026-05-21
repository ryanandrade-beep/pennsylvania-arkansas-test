#!/usr/bin/env bash
# run.sh — executa os testes localmente (sem Qase)
# Uso:
#   ./run.sh                              # todos os testes (production)
#   ./run.sh staging                      # ambiente staging
#   ./run.sh production @smoke            # smoke em production
#   ./run.sh production @messages
#   ./run.sh production @templates
#   ./run.sh production @negative

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:/usr/bin:$PATH"
MVN="$HOME/.local/bin/mvn"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

ENV="${1:-production}"
TAGS="${2:-}"

# Monta array de flags -D a partir do .env
declare -a ENV_FLAGS=()
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
    fi
  done < "$ENV_FILE"
fi

echo "Ambiente: $ENV"
[ -n "$TAGS" ] && echo "Tags:     $TAGS"
echo ""

if [ -n "$TAGS" ]; then
  "$MVN" test "${ENV_FLAGS[@]}" -Dkarate.env="$ENV" -Dkarate.options="--tags $TAGS"
else
  "$MVN" test "${ENV_FLAGS[@]}" -Dkarate.env="$ENV"
fi
