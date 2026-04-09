#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
STACK_DIR="$SCRIPT_DIR/stack"
BASE_URL="https://raw.githubusercontent.com/zitadel/zitadel/main/deploy/compose"

mkdir -p "$STACK_DIR"

for file in docker-compose.yml .env.example docker-compose.yaml; do
  url="$BASE_URL/$file"

  if curl -fsSL "$url" -o "$STACK_DIR/$file"; then
    echo "Downloaded $file"
  fi
done

if [ ! -f "$SCRIPT_DIR/.env" ]; then
  cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
  echo "Created $SCRIPT_DIR/.env from template"
fi

cat <<EOF
Downloaded the current official compose files into:
  $STACK_DIR

Next:
  1. Review the downloaded files.
  2. Merge values from $SCRIPT_DIR/.env into the compose env file you use.
  3. Start the stack with docker compose from $STACK_DIR.
EOF
