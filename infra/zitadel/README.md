# ZITADEL

Runs as a native binary managed by systemd. No Docker.

## Prerequisites

```sh
apt install postgresql caddy curl
```

## Setup

```sh
cp infra/zitadel/.env.example infra/zitadel/.env
$EDITOR infra/zitadel/.env
sudo bash infra/zitadel/setup.sh
```

The script will:
1. Create a `zitadel` system user
2. Create the PostgreSQL database and user
3. Download the latest ZITADEL binary for your architecture (arm64, arm, x86_64)
4. Write `/etc/zitadel/env` with runtime config
5. Install and start `zitadel.service`

## Reverse proxy

Copy `infra/caddy/Caddyfile` to `/etc/caddy/Caddyfile` and reload:

```sh
sudo cp infra/caddy/Caddyfile /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

Caddy handles Let's Encrypt automatically. Make sure ports 80 and 443 are open.

## Useful commands

```sh
journalctl -u zitadel -f      # tail logs
systemctl status zitadel
systemctl restart zitadel
```

## Upgrading

```sh
sudo systemctl stop zitadel
sudo bash infra/zitadel/setup.sh   # re-runs, downloads latest binary
```
