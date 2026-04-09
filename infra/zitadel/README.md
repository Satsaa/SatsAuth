# ZITADEL Bootstrap

This folder does not vendor a custom copy of the ZITADEL stack. Instead it downloads the current official compose files into `stack/` so the deployment stays easy to transfer and update.

## Files

- `.env.example`: local variables you should copy to `.env`
- `bootstrap.sh`: downloads the official compose files from the ZITADEL repository

## Linux usage

```sh
cp infra/zitadel/.env.example infra/zitadel/.env
$EDITOR infra/zitadel/.env
./infra/zitadel/bootstrap.sh
cd infra/zitadel/stack
docker compose up -d
```

## Notes

- Put the service behind `auth.satsaa.dev`.
- Use HTTPS in front of it.
- Keep `ZITADEL_MASTERKEY` outside git.
- Review the downloaded compose files before first deploy.
