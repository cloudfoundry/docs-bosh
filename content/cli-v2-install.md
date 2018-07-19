# Installing the CLI

The `bosh` CLI is the command line tool used for interacting with all things BOSH - whether it is deployment operations or software release management.


## Install

Choose your preferred installation method below to get the latest version of `bosh`...


### Using curl

To install the `bosh` binary directly, choose the correct download for your system:

--8<-- "snippets/bosh-cli/latest-versions-table.md"

1. Download the binary (this example is using Linux):

        --8<-- "snippets/bosh-cli/latest-version-curl-linux.md"

1. Make the `bosh` binary executable:

    ```shell
    chmod +x ./bosh
    ```

1. Move the binary to your `PATH`:

    ```shell
    sudo mv ./bosh /usr/local/bin/bosh
    ```

1. You should now be able to use `bosh`, such as asking for its version:

    ```shell
    bosh -v
    ```

### Using Homebrew on macOS

If you are on macOS with [Homebrew](https://brew.sh/), you can install using the [Cloud Foundry tap](https://github.com/cloudfoundry/homebrew-tap).

1. Use `brew` to install `bosh-cli`:

    ```shell
    brew install cloudfoundry/tap/bosh-cli
    ```

1. You should now be able to use `bosh`, such as asking for its version:

    ```shell
    bosh -v
    ```


## Additional Dependencies

When you are using `bosh` to bootstrap BOSH or other standalone VMs, you will need a few extra dependencies installed on your local system.

!!! tip
    If you will not be using `create-env` and `delete-env` commands, you can skip this section.


### Ubuntu Trusty

If you are running on Ubuntu Trusty, ensure the following packages are installed on your system:

```shell
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
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
$ sudo yum install gcc gcc-c++ ruby ruby-devel mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel patch openssl
$ gem install yajl-ruby
```


### Windows

The `create-env` and `destroy-env` commands are not yet supported on native Windows. Feel free to give it a try (and let us know if you have feedback), but we would recommend leveraging the Windows Subsystem for Linux if you need to run either command.


### Other

You should be able to use `bosh` on other systems... we just don't know the exact packages to recommend. In general, use these recommendations (and send us a pull request to update this page once you figure it out!):

 * compilation tools (often a `build-essential`-like package or "Development Tools"-like group)
 * Ruby v2.4+
