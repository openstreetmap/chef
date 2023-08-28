# Contribution Guidelines

## Workflow

We operate the "Fork & Pull" model explained at

https://help.github.com/articles/using-pull-requests

You should fork the project into your own repo, create a topic branch
there and then make one or more pull requests back to the openstreetmap/chef repository.
Your pull requests will then be reviewed and discussed.

## Running the Infrastructure Tests locally

- **[Cookstyle](https://docs.chef.io/workstation/cookstyle/)** is used for linting, ensuring that our Chef recipes follow style guidelines and best practices.
- **[Test Kitchen](https://kitchen.ci/)** combined with **InSpec** and [Dokken](https://github.com/test-kitchen/kitchen-dokken) is used to verify the functionality of our Chef code, ensuring it behaves as expected.

The following guidelines are to help set up and run these checks locally:

#### **1. Install Docker**
- Visit [Docker's official site](https://www.docker.com/products/docker-desktop) to download and install Docker.

#### **2. Install Homebrew (Apple MacOS only)**
- Install Homebrew by following the instructions [here](https://brew.sh/).

#### **3. Install rbenv (recommended)**
- Install rbenv by following the instructions [here](https://github.com/rbenv/rbenv#installation).

rbenv is a ruby version manager. rbenv allows projects to use a different version of ruby than the version of install with your operating system.

> *Note on rbenv: While we recommend using rbenv for managing Ruby versions, it's not strictly necessary. If you have Ruby already installed feel free to use that. If you're not using rbenv, simply omit the `rbenv exec` prefix from the commands below.*

#### **4. Increase File Limit (Important for MacOS)**

To avoid errors when running tests on MacOS, you might need to increase the number of files your system can open at once. Here's how:

1. Run the command:
```bash
ulimit -n 1024
```
2. To make the change permanent, add the above line to either `~/.zshrc` or `~/.bash_profile`, depending on your shell.

**Note:** MacOS has a low default limit of just 256 open files. If you exceed this while testing, you'll see an error like: `Too many open files - getcwd (Errno::EMFILE)`. This step helps prevent that.

#### **5. Install Required Ruby Version (recommended)**
Navigate to the git checkout of the OpenStreetMap chef repo and run:
```bash
rbenv install
```
This will install the recommended version of ruby for running the tests. The recommended version of ruby is defined in the [.ruby-version](.ruby-version) file.

#### **6. Install Dependencies with Bundler**
```bash
rbenv exec gem install bundler
rbenv exec bundler install
```
This will install the [bundler](https://bundler.io/), the ruby gem packages manager, and then uses `bundler`` to install the required gem packages for the tests.

#### **7. Run Cookstyle for Linting and Style Checks**
```bash
rbenv exec bundle exec cookstyle
```
This will run [cookstyle](https://docs.chef.io/workstation/cookstyle/) a linting tool which reports on any linting issues.

> *Automatically run cookstyle lint: We have a sample [git pre-commit hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) in the `hooks/pre-commit` file which can be copied to the local checkout of this repo to the file `.git/hooks/pre-commit`  to ensure the lint passes when running a git commit.*

#### **8. List Available Tests**
```bash
rbenv exec bundler exec kitchen list
```
This lists the [Test Kitchen](https://kitchen.ci/) tests which are available. The list of tests is generated from the definitions in the [.kitchen.yml](.kitchen.yml) file. The individual tests are written in [InSpec](https://docs.chef.io/inspec/) and are stored in the `test/integration/` directory.

#### **9. Run an Example Test**
```bash
rbenv exec bundler exec kitchen test dns-ubuntu-2204
```
This runs the [Test Kitchen](https://kitchen.ci/) [InSpec](https://docs.chef.io/inspec/) `dns` tests using the `Ubuntu 22.04` platform. The tests are run inside a Docker container using the Test Kitchen [Dokken driver](https://github.com/test-kitchen/kitchen-dokken).
