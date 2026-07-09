# Deploying Penny Pincher

The web app runs on the usual Hatchbox + Hetzner box. The iOS app is a Ruby Native build shipped to TestFlight. No domain required.

## 1. Web app on Hatchbox

Create the app in Hatchbox pointing at this repo (`apps/penny-pincher` if you keep the umbrella layout, or push this directory as its own repo).

### Database: SQLite on a persistent disk

This app uses SQLite for everything (primary, queue, cache, cable), stored in `storage/`. Each Hatchbox release is a fresh directory, so **add `storage` to the app's persistent directories** in Hatchbox so the database survives deploys. There is no Postgres or Redis to provision.

### Deploy command

The production database is multi-database, so the first deploy needs the schemas loaded, not just migrations. Set the Hatchbox deploy/migrate command to:

```bash
bin/rails db:prepare
```

`db:prepare` creates and migrates the primary database and loads the queue, cache, and cable schemas. It is safe to run on every deploy.

### Environment variables

| Variable | Value | Why |
| --- | --- | --- |
| `RAILS_MASTER_KEY` | contents of `config/master.key` | decrypts credentials |
| `SOLID_QUEUE_IN_PUMA` | `true` | runs jobs and the 5pm reminder inside Puma, so no separate worker process is needed |
| `APP_HOST` | optional, e.g. `penny.example.com` | locks the allowed `Host` header. Leave unset to accept the Hatchbox hostname or IP |

`RAILS_ENV=production` and `SECRET_KEY_BASE` are set by Hatchbox.

The timezone for "today" and the 5pm reminder is set in `config/application.rb`
(`config.time_zone = "America/Los_Angeles"`). Edit that line if it ever moves.

### No domain, no SSL

Without a domain there's no TLS certificate, so SSL is left off and the app is served over HTTP via the Hatchbox hostname or IP. If you later attach a domain, uncomment `config.assume_ssl` and `config.force_ssl` in `config/environments/production.rb`.

## 2. Push notifications (APNs)

The 5pm reminder and any future pushes go through `action_push_native` straight to Apple. You need an APNs auth key (`.p8`) from the Apple Developer portal.

1. Set the team id and bundle id in `config/push.yml`:
   ```yaml
   apple:
     team_id: YOUR_TEAM_ID
     topic: com.yourcompany.pennypincher   # must match the native app's bundle id
   ```
2. Add the key to encrypted credentials with `bin/rails credentials:edit`:
   ```yaml
   action_push_native:
     apns:
       key_id: ABCD1234EF
       encryption_key: |
         -----BEGIN PRIVATE KEY-----
         ...contents of your .p8...
         -----END PRIVATE KEY-----
   ```

Device tokens register automatically: the Home screen renders `native_push_tag`, the native app asks permission, and the token is POSTed to `/native/push/devices` (handled by the gem). Until APNs is configured and the app is installed, the reminder job runs but sends nothing.

## 3. Native build to TestFlight

The app shell is configured in `config/ruby_native.yml` (name "Penny Pincher", green tint, three tabs).

```bash
bundle exec ruby_native login
bundle exec ruby_native deploy
```

This triggers a cloud build and uploads it to TestFlight. On the free tier the build is TestFlight Internal only, which is exactly what you want here.

### Invite Age for internal testing

In App Store Connect, open the app, go to TestFlight, then Internal Testing, and add Age as a user so they can install the build. This is a one-time manual step in the App Store Connect UI.

## Checklist

- [ ] Hatchbox app created, `storage` marked persistent
- [ ] Deploy command set to `bin/rails db:prepare`
- [ ] `RAILS_MASTER_KEY`, `SOLID_QUEUE_IN_PUMA=true`, `TZ` set
- [ ] APNs key id, key, team id, and topic configured
- [ ] `ruby_native deploy` run, build in TestFlight
- [ ] Age invited in App Store Connect → TestFlight → Internal Testing
