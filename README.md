[![CI/CD Badge](https://img.shields.io/github/actions/workflow/status/keepcoding-tech/ctrl_nest/ci.yml?branch=master&style=for-the-badge&logo=github-actions&logoColor=ffffff&label=CI/CD)](https://github.com/keepcoding-tech/ctrl_nest/actions/workflows/ci.yml)

```
  ____            _             _      _   _           _
 / ___|___  _ __ | |_ _ __ ___ | |    | \ | | ___  ___| |_
| |   / _ \| '_ \| __| '__/ _ \| |    |  \| |/ _ \/ __| __|
| |__| (_) | | | | |_| | | (_) | |    | |\  |  __/\__ \ |_
 \____\___/|_| |_|\__|_|  \___/|_|    |_| \_|\___||___/\__|
```

> Your data's cozy nest. Built with ♡ by [keepcoding.tech](https://www.keepcoding.tech)

[![Perl](https://img.shields.io/badge/Perl-5.34+-yellow.svg)](https://www.perl.org)
[![Mojolicious](https://img.shields.io/badge/Mojolicious-9.39+-yellow.svg)](https://mojolicious.org)
[![Node.js](https://img.shields.io/badge/Node.js-LTS-yellow.svg)](https://nodejs.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

## What is CtrlNest?

CtrlNest is a modern, Perl-powered backend admin panel built on top of [Mojolicious](https://mojolicious.org). It gives you a clean, structured way to manage your application's data without jumping through hoops. Think of it as a cozy nest where your data can relax while you keep full control.

No magic black boxes. No framework soup. Just Perl, done right.

## Features

- **Authentication system** — Secure login flow with bcrypt password hashing
- **User management** — Full CRUD for users, searchable from the settings tab
- **Pagination** — Because nobody wants to scroll through 10,000 rows
- **User profiles** — Per-user profile views
- **Access codes** — Role and access control baked in
- **PostgreSQL + DBIx::Class** — Proper ORM, proper migrations, no raw SQL nightmares
- **AdminLTE frontend** — A clean, responsive UI so you don't cry while using it
- **GitHub Actions CI/CD** — Ships with a working pipeline out of the box

## Tech Stack

If you're a Perl dev, you'll feel right at home:

| Layer | What's used |
|---|---|
| Web framework | [Mojolicious](https://mojolicious.org) |
| ORM | [DBIx::Class](https://metacpan.org/pod/DBIx::Class) |
| Database | PostgreSQL via [Mojo::Pg](https://metacpan.org/pod/Mojo::Pg) & [DBD::Pg](https://metacpan.org/pod/DBD::Pg) |
| Migrations | [DBIx::Class::Migration](https://metacpan.org/pod/DBIx::Class::Migration) |
| Crypto | [Crypt::Bcrypt](https://metacpan.org/pod/Crypt::Bcrypt) + [Bytes::Random::Secure](https://metacpan.org/pod/Bytes::Random::Secure) |
| Testing | [Test::DBIx::Class](https://metacpan.org/pod/Test::DBIx::Class) + [Test::Postgresql58](https://metacpan.org/pod/Test::Postgresql58) |
| Code style | [Perl::Tidy](https://metacpan.org/pod/Perl::Tidy) (`.perltidyrc` included) |
| Frontend | [AdminLTE](https://adminlte.io) + Node.js |

## Getting Started

Everything you need to get CtrlNest running — prerequisites, installation, database setup, and running the tests — is covered in detail in the **[project Wiki](https://github.com/keepcoding-tech/ctrl_nest/wiki)**. Head over there and you'll be up and running in no time.

## Project Structure

```
ctrl_nest/
├── db/             # PostgreSQL schema migrations
├── lib/            # All your Perl modules live here
├── public/         # Static assets
├── script/         # App entry point & helper scripts
├── t/              # Test suite
├── templates/      # Mojolicious HTML templates
├── cpanfile        # CPAN dependencies
└── .perltidyrc     # Tidy config — keep your code neat
```

## Contributing

Got an itch to scratch? PRs are welcome. Open an issue first if it's something big, so we can talk it through before you spend time coding it.

Please run `perltidy` before submitting — the `.perltidyrc` in the root has the style settings.

## License

MIT — do whatever you want with it, just don't blame us if something breaks in prod.

---

<p align="center">Built with Perl, PostgreSQL, and a healthy respect for <code>use strict; use warnings;</code></p>
