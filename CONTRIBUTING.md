# Contributing

This repository contains the Chef code used to configure OpenStreetMap's infrastructure.
This guide walks you through running the same checks as CI locally before opening a pull request.

## What you should run before a pull request

At a minimum, please run:

- **Cookstyle** (lint/style): `bundle exec cookstyle`
- **Test Kitchen** for the cookbooks/roles you changed or added (integration): `bundle exec kitchen test <suite>-<platform>`

CI runs a large matrix; contributors are not expected to run every Kitchen instance locally.

## Quick start (if you already have Ruby + Docker)

From the repository root:

```bash
bundle install
bundle exec cookstyle
bundle exec kitchen list
bundle exec kitchen test dns-ubuntu-2204
```

Replace `dns-ubuntu-2204` with a Kitchen instance relevant to the cookbooks/roles you changed.

## Workflow

We use the "fork and pull request" workflow:

- Fork the repository
- Create a topic branch
- Open a pull request back to `openstreetmap/chef`

GitHub has an overview at https://help.github.com/articles/using-pull-requests

## Local test setup

### Prerequisites

- **Docker**
	- macOS: Docker Desktop
	- Linux: Docker Engine
	- Windows: WSL2 + Docker may work, but is not used by the operations team and may not work in your environment (see below).
- **Ruby** (see [.ruby-version](.ruby-version)) and **Bundler**
- `git`

We recommend using `rbenv` to manage Ruby versions. On macOS, Homebrew is often the easiest way to install it.

### Recommended setup (rbenv + Bundler)

The steps below work on macOS and Linux. The macOS-only steps are called out explicitly.

1) Install Docker

- macOS: Docker Desktop - https://www.docker.com/products/docker-desktop
- Linux: Docker Engine - https://docs.docker.com/engine/install/

2) macOS only: install Homebrew (if you do not already have it)

- https://brew.sh/

3) Install `rbenv`

- https://github.com/rbenv/rbenv#installation

`rbenv` is a Ruby version manager. It lets you use the Ruby version this repository expects without changing your system Ruby.

If you do not use `rbenv`, omit the `rbenv exec` prefix in the commands below.

4) macOS only: increase the open file limit (often needed)

If you see errors like `Too many open files (Errno::EMFILE)` while running tests:

```bash
ulimit -n 1024
```

To make it permanent, add the line above to your shell profile (for example `~/.zshrc`).

5) Install the Ruby version for this repo

From the repository root:

```bash
rbenv install --skip-existing
```

6) Install Ruby gems

```bash
rbenv exec gem install bundler
rbenv exec bundle install
```

## Running the checks

### 1) Cookstyle (lint and style)

Cookstyle checks Chef/Ruby style and common issues.

```bash
rbenv exec bundle exec cookstyle
```

If you prefer not to install Ruby locally, you can run Cookstyle via Docker:

```bash
docker compose run --rm cookstyle
```

If you only want to lint the files you are committing, there is a sample pre-commit hook at [hooks/pre-commit](hooks/pre-commit).
Copy it to `.git/hooks/pre-commit` and make it executable.

### 2) Test Kitchen (integration tests)

We use Test Kitchen with InSpec and the Dokken driver to converge recipes and verify behaviour inside containers.

1) List available instances:

```bash
rbenv exec bundle exec kitchen list
```

Kitchen instances are named `<suite>-<platform>`.
The suite is usually the cookbook/role under test (see [.kitchen.yml](.kitchen.yml)), and the platform is the OS image.

The available Kitchen suites and platforms are defined in [.kitchen.yml](.kitchen.yml).
The InSpec integration tests themselves live under [test/integration/](test/integration/).
If your change adds a new cookbook, please add a corresponding suite to [.kitchen.yml](.kitchen.yml) and include appropriate integration tests.

2) Run a specific instance:

```bash
rbenv exec bundle exec kitchen test dns-ubuntu-2204
```

`kitchen test` will create the container, converge, verify, then destroy it.

For faster iteration, you can split the steps:

```bash
rbenv exec bundle exec kitchen converge dns-ubuntu-2204
rbenv exec bundle exec kitchen verify dns-ubuntu-2204
rbenv exec bundle exec kitchen destroy dns-ubuntu-2204
```

#### Debugging a failed converge

If `kitchen converge` fails, it can be useful to inspect the running test container.

1) Find the container name by running `docker ps` (example output):

```text
CONTAINER ID   IMAGE                               COMMAND          CREATED          STATUS          PORTS     NAMES
3b83c7f96575   9a7e6edc5b-dns-ubuntu-2204:latest   "/bin/systemd"   14 minutes ago   Up 14 minutes             9a7e6edc5b-dns-ubuntu-2204
```

2) Enter the container:

```bash
docker exec -it 9a7e6edc5b-dns-ubuntu-2204 bash -l
```

Once you are finished debugging, remember to clean up the instance:

```bash
rbenv exec bundle exec kitchen destroy dns-ubuntu-2204
```

## Windows (WSL2)

It may be possible to run the toolchain under WSL2 (for example Ubuntu on WSL2) with Docker.
However, the operations team do not use WSL2, and we cannot guarantee it will work or be able to troubleshoot WSL2-specific issues.

If you try this route, aim to match the Linux instructions as closely as possible and ensure Docker is reachable from within WSL2.

## Troubleshooting

- **Docker is not running**: start Docker Desktop (macOS) or the Docker service (Linux).
- **Open file limit errors on macOS**: increase `ulimit -n` as described above.
- **Kitchen networking issues**: if Docker has IPv6 disabled, Dokken may fail to create its network; enabling IPv6 in Docker's settings can help.

## Pull request checklist

- Run `bundle exec cookstyle` locally
- Run relevant `kitchen test <suite>-<platform>` instances for the cookbooks/roles you changed or added
- Keep changes focused and include context in the pull request description

## Need help?

If you get stuck, the operations team are available in `#osmf-operations` on `irc.oftc.net`.
You can access `#osmf-operations` via https://irc.openstreetmap.org/ or via the Matrix IRC bridge in [#\_oftc_#osmf-operations](https://matrix.to/#/#_oftc_#osmf-operations:matrix.org).
