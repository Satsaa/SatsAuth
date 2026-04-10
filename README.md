# SatsAuth

Self-hosted identity provider for `auth.satsaa.dev`. Runs ZITADEL as a native binary on systemd — no Docker.

## Structure

- `infra/zitadel` — setup script, systemd unit, env template
- `infra/caddy` — reverse proxy config with automatic TLS
- `src/log.ts` — app logger (console only)
- sibling `auth-core` repo — OIDC discovery, JWKS verification helpers for apps

## Quick start

```sh
apt install postgresql caddy curl
cp infra/zitadel/.env.example infra/zitadel/.env
$EDITOR infra/zitadel/.env
sudo bash infra/zitadel/setup.sh
sudo cp infra/caddy/Caddyfile /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

## Auth model

- Identity comes from signed JWTs issued by ZITADEL.
- Token signatures are verified against the ZITADEL JWKS endpoint.
- App-side authorization (bans, roles, session versions) stays in each app's own database.

## Next steps

- Create the ZITADEL project and app clients for KesaKunto
- Wire `auth-core` into KesaKunto's backend
- Decide whether user provisioning is just-in-time or synced ahead of time
