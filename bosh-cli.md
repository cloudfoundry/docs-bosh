---
title: BOSH Command Line Interface
---

BOSH Command Line Interface (CLI) is used to interact with the Director. The CLI is written in Ruby and is distributed via `bosh_cli` gem.

```shell
$ gem install bosh_cli --no-ri --no-rdoc
```

<p class="note">Note: BOSH CLI requires Ruby 2+</p>

If gem installation does not succeed, make sure pre-requisites for your OS are met.

### Prerequisites on Ubuntu Trusty

Make sure following packages are installed:

```shell
$ sudo apt-get install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev
```

Make sure `ruby` and `gem` binaries are on your path before continuing.

### Prerequisites on CentOS

Make sure following packages are installed:

```shell
$ sudo yum install gcc ruby ruby-devel mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel yajl-ruby
```

### Prerequisites on Mac OS X

You may see an error like this:

    ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /Library/Ruby/Gems/2.0.0 directory.

Instead of using the system Ruby, install a separate Ruby for your own use, and switch to that one using a package like RVM, rbenv, or chruby.

You may see an error like this:

    The compiler failed to generate an executable file. (RuntimeError). You have to install development tools first.

Make sure you have installed Xcode and the command-line developer tools, and agreed to the license.

```shell
$ xcode-select --install
xcode-select: note: install requested for command line developer tools
```

A window will pop up saying:

    The "xcode-select" command requires the command line developer tools. Would you like to install the tools now?

Choose Install to continue. Choose Get Xcode to install Xcode and the command line developer tools from the App Store. If you have already installed Xcode from the App Store, you can choose Install and it will install the cli tools.

If you have successfully installed them, you will see this:

```shell
$ xcode-select --install
xcode-select: error: command line tools are already installed, use "Software Update" to install updates
```

To agree to the license:

```shell
$ sudo xcodebuild -license
```
