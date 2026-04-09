# SatsAuth

Self-hosted identity provider setup for `auth.satsaa.dev` and a small TypeScript package for verifying OIDC/JWT tokens via JWKS in your apps.

## Structure

- `infra/zitadel`: bootstrap scripts and env template for a Linux-friendly ZITADEL deployment
- sibling `auth-core` repo: app-side OIDC discovery, JWKS verification, and local account enforcement helpers

## Why this layout

- ZITADEL gives you a standard OIDC provider with JWTs and JWKS.
- Your apps verify identity claims statelessly.
- Your app database still controls bans, forced logout, and app-specific roles.

## Quick start

1. Copy `infra/zitadel/.env.example` to `infra/zitadel/.env`.
2. Set your real domain, passwords, and master key.
3. Run `./infra/zitadel/bootstrap.sh` on Linux to fetch the current official compose files.
4. Start the provider from `infra/zitadel/stack`.
5. Use the sibling `auth-core` package in your apps to verify tokens from `auth.satsaa.dev`.

## Auth model

- Identity comes from signed JWTs issued by the provider.
- Token signatures are verified against the provider's JWKS.
- App-side authorization still comes from your own database.

That means a request should pass both checks:

1. token is valid for your issuer and audience
2. local account is not banned and its session version still matches

## Next steps

- create the ZITADEL project and app clients for `KesaKunto`
- wire `packages/auth-core` into your backend
- decide whether user provisioning is just-in-time or synced ahead of time
