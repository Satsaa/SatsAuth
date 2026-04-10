#!/usr/bin/env bash
set -euo pipefail

# Run as root on the Pi.
# Installs ZITADEL as a native binary managed by systemd.
# Requires: postgresql (apt), caddy (apt), curl, tar

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="$SCRIPT_DIR/.env"
UNIT_FILE="$SCRIPT_DIR/zitadel.service"

ZITADEL_USER=zitadel
ZITADEL_DIR=/opt/zitadel
ZITADEL_BIN=/usr/local/bin/zitadel
ZITADEL_ENV=/etc/zitadel/env

# ---------------------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root." >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE — copy .env.example and fill in values." >&2
  exit 1
fi

source "$ENV_FILE"

: "${ZITADEL_DOMAIN:?}"
: "${ZITADEL_MASTERKEY:?}"
: "${POSTGRES_PASSWORD:?}"

# ---------------------------------------------------------------------------
# 1. PostgreSQL

echo "==> Configuring PostgreSQL..."
systemctl enable --now postgresql

sudo -u postgres psql -c "CREATE USER zitadel WITH PASSWORD '$POSTGRES_PASSWORD';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE zitadel OWNER zitadel;" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 2. ZITADEL binary

echo "==> Installing ZITADEL binary..."
ARCH=$(uname -m)
case "$ARCH" in
  aarch64) ARCH_LABEL="arm64" ;;
  armv7l)  ARCH_LABEL="arm"   ;;
  x86_64)  ARCH_LABEL="x86_64" ;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

LATEST=$(curl -fsSL https://api.github.com/repos/zitadel/zitadel/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
TARBALL="zitadel_Linux_${ARCH_LABEL}.tar.gz"
URL="https://github.com/zitadel/zitadel/releases/download/${LATEST}/${TARBALL}"

echo "   Downloading $LATEST ($ARCH_LABEL)..."
curl -fsSL "$URL" -o /tmp/zitadel.tar.gz
tar -xzf /tmp/zitadel.tar.gz -C /tmp
install -m 755 /tmp/zitadel "$ZITADEL_BIN"
rm /tmp/zitadel.tar.gz /tmp/zitadel 2>/dev/null || true

# ---------------------------------------------------------------------------
# 3. System user and directories

echo "==> Creating system user and directories..."
id "$ZITADEL_USER" &>/dev/null || useradd --system --no-create-home --shell /usr/sbin/nologin "$ZITADEL_USER"
mkdir -p "$ZITADEL_DIR" /etc/zitadel
chown "$ZITADEL_USER:$ZITADEL_USER" "$ZITADEL_DIR"

# ---------------------------------------------------------------------------
# 4. Environment file

echo "==> Writing environment file to $ZITADEL_ENV..."
mkdir -p "$(dirname "$ZITADEL_ENV")"
cat > "$ZITADEL_ENV" <<EOF
ZITADEL_EXTERNALDOMAIN=$ZITADEL_DOMAIN
ZITADEL_EXTERNALPORT=443
ZITADEL_EXTERNALSECURE=true
ZITADEL_TLS_ENABLED=false
ZITADEL_MASTERKEY=$ZITADEL_MASTERKEY
ZITADEL_DATABASE_POSTGRES_HOST=localhost
ZITADEL_DATABASE_POSTGRES_PORT=5432
ZITADEL_DATABASE_POSTGRES_DATABASE=zitadel
ZITADEL_DATABASE_POSTGRES_USER_USERNAME=zitadel
ZITADEL_DATABASE_POSTGRES_USER_PASSWORD=$POSTGRES_PASSWORD
ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE=disable
ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME=zitadel
ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD=$POSTGRES_PASSWORD
ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE=disable
EOF
chmod 640 "$ZITADEL_ENV"
chown root:"$ZITADEL_USER" "$ZITADEL_ENV"

# ---------------------------------------------------------------------------
# 5. Systemd unit

echo "==> Installing systemd unit..."
cp "$UNIT_FILE" /etc/systemd/system/zitadel.service
systemctl daemon-reload
systemctl enable zitadel
systemctl restart zitadel

echo ""
echo "==> ZITADEL is running."
echo "    Check status: journalctl -u zitadel -f"
echo "    First-run setup wizard will be available at https://$ZITADEL_DOMAIN"
