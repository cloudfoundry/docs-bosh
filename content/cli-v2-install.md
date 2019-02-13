# Installing the CLI

The `bosh` CLI is the command line tool used for interacting with all things BOSH, from deployment operations to software release management.


## Install

Choose your preferred installation method below to get the latest version of `bosh`.


### Using the binary directly

To install the `bosh` binary directly:

1. Navigate to the [BOSH CLI GitHub release page](https://github.com/cloudfoundry/bosh-cli/releases) and choose the correct download for your operating system.

1. Make the `bosh` binary executable and move the binary to your `PATH`:

    ```shell
    chmod +x ./bosh
    sudo mv ./bosh /usr/local/bin/bosh
    ```

1. You should now be able to use `bosh`. Verify by querying the CLI for its version:

    ```shell
    bosh -v
    # version 5.3.1-8366c6fd-2018-09-25T18:25:51Z
    # Succeeded
    ```

### Using Homebrew on macOS

If you are on macOS with [Homebrew](https://brew.sh/), you can install using the [Cloud Foundry tap](https://github.com/cloudfoundry/homebrew-tap).

1. Use `brew` to install `bosh-cli`:

    ```shell
    brew install cloudfoundry/tap/bosh-cli
    ```

1. You should now be able to use `bosh`. Verify by querying the CLI for its version:

    ```shell
    bosh -v
    # version 5.3.1-8366c6fd-2018-09-25T18:25:51Z
    # Succeeded
    ```

!!! note
    We currently do not publish BOSH CLI via apt or yum repositories.

## Additional Dependencies

When you are using `bosh` to bootstrap BOSH or other standalone VMs, you will need a few extra dependencies installed on your local system.

!!! tip
    If you will not be using `create-env` and `delete-env` commands, you can skip this section.


### Ubuntu

If you are running on Ubuntu xenial or trusty, ensure the following packages are installed on your system:

```shell
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
```

For ubuntu bionic (18.04), ensure the following packages are installed on your system:
```shell
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libreadline7 libreadline-dev libyaml-dev libsqlite3-dev sqlite3
```

### macOS

1. Install the [Apple Command Line Tools](https://developer.apple.com/download/more/):

    ```shell
    xcode-select --install
    ```

2. Use [Homebrew](https://brew.sh/) to additionally install OpenSSL:

    ```shell
    brew install openssl
    ```


### CentOS

If you are running on CentOS, ensure the following packages are installed on your system:

```shell
sudo yum install gcc gcc-c++ ruby ruby-devel mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel patch openssl
gem install yajl-ruby
```


### Windows

The `create-env` and `destroy-env` commands are not yet supported on native Windows. Feel free to give it a try (and let us know if you have feedback), but we would recommend leveraging the Windows Subsystem for Linux if you need to run either command.

### Other

You should be able to use `bosh` on other systems... we just don't know the exact packages to recommend. In general, use these recommendations (and send us a pull request to update this page once you figure it out!):

 * compilation tools (often a `build-essential`-like package or "Development Tools"-like group)
 * Ruby v2.4+
