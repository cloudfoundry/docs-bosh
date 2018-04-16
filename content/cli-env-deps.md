---
title: CLI `create-env` Dependencies
---

!!! note
    Applies to CLI v2.

The `bosh create-env` (and `bosh delete-env`) command has dependencies.

1. Depending on your platform install following packages:

    **Ubuntu Trusty**

    ```shell
    $ sudo apt-get update
    $ sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
    ```

    **CentOS**

    ```shell
    $ sudo yum install gcc gcc-c++ ruby ruby-devel mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel patch openssl
    $ gem install yajl-ruby
    ```

    **Mac OS X**

    Install Apple Command Line Tools:
    ```shell
    $ xcode-select --install
    ```

    Use [Homebrew](http://brew.sh) to install OpenSSL:
    ```shell
    $ brew install openssl
    ```

1. Make sure Ruby is installed (any version is adequate):

    ```shell
    $ ruby -v
    ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
    ```
