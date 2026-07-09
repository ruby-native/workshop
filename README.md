# Penny Pincher ¢

Track expenses the moment they happen, and see at a glance how you're tracking against your weekly and monthly budgets. A Rails app that ships as an iOS app with [Ruby Native](https://rubynative.com).

## What it does

- **Log fast.** Tap +, type a whole-dollar amount (no cents), pick a category, done.
- **See where you stand.** The Home tab shows this week and this month vs. budget, plus a per-category breakdown.
- **Shared budgets.** Invite a partner with a 6-character code so you both log into the same household.
- **History.** The History tab summarizes the last several weeks and months against budget.
- **5pm reminder.** If you haven't logged anything by 5pm, you get a push notification (once the native app is installed and notifications are allowed).

## Stack

- Rails 8.1, Ruby 4.0.1
- SQLite (primary + Solid Queue / Cache / Cable), no external services
- Propshaft + import maps + Hotwire, plain CSS (no build step)
- Rails 8 built-in authentication
- `ruby_native` for the native shell and `action_push_native` for APNs
- Background jobs via Solid Queue; the 5pm reminder is a recurring task

## Run it locally

```bash
bin/setup            # installs gems, prepares the db
bin/rails db:seed    # demo data (development only)
bin/dev              # or: bin/rails server
```

Sign in with the seeded accounts:

- `joe@example.com` / `password`
- `age@example.com` / `password` (shares the same budget)

### Preview on a device

```bash
bundle exec ruby_native preview
```

Scan the QR code with the Ruby Native preview app. Tabs, colors, and the app name come from `config/ruby_native.yml`.

## Tests

```bash
bin/rails test       # 34 tests
bin/ci               # tests + rubocop + brakeman + audits
```

## Deploying

See [DEPLOY.md](DEPLOY.md) for the Hatchbox + Hetzner setup, push notification credentials, and shipping the native build to TestFlight.

## Data model

- `User` belongs to households through `Membership`, and has a `current_household`.
- `Household` has an `invite_code`, `Category` records, and `Expense` records.
- `Category` has an emoji, color, whole-dollar `budget_amount`, and a `period` (`weekly` or `monthly`).
- `Expense` has a whole-dollar `amount`, optional `note`, and `spent_on` date.

`BudgetSummary` powers the Home tab; `SpendingHistory` powers the History tab.
