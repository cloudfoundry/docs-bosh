---
title: Install bosh-init
---

<p class="note">Note: See [CLI v2](cli-v2.html) for an updated CLI.</p>

`bosh-init` is used for creating and updating a Director VM (and its persistent disk) in an environment.

Here are the latest binaries:

<div class="well">
  <h4>0.0.103</h4>
  <ul>
    <li><a href="https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.103-linux-amd64">bosh-init for Linux (amd64)</a> <span class="sha1">a005ce759231e6715b872f228984cc6583935892</span></li>
    <li><a href="https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.103-darwin-amd64">bosh-init for Mac OS X (amd64)</a> <span class="sha1">0e9e039949ee8ffeccfe3a684918646f6a2f2f0a</span></li>
  </ul>
</div>

1. Download the binary for your platform and place it on your `PATH`. For example on UNIX machines:

	<pre class="terminal">
	$ chmod +x ~/Downloads/bosh-init-*
	$ sudo mv ~/Downloads/bosh-init-* /usr/local/bin/bosh-init
	</pre>

1. Check `bosh-init` version to make sure it is properly installed:

	<pre class="terminal">
	$ bosh-init -v
	</pre>

1. Depending on your platform install following packages:

	**Ubuntu Trusty**

	<pre class="terminal">
	$ sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
	</pre>

	**CentOS**

	<pre class="terminal">
	$ sudo yum install gcc gcc-c++ ruby ruby-devel mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel patch openssl
	$ gem install yajl-ruby
	</pre>

	**Mac OS X**

	Install Apple Command Line Tools:
	<pre class="terminal">
	$ xcode-select --install
	</pre>

	Use [Homebrew](http://brew.sh) to install OpenSSL:
	<pre class="terminal">
	$ brew install openssl
	</pre>

1. Make sure Ruby 2+ is installed:

	<pre class="terminal">
	$ ruby -v
	ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
	</pre>

---
See [Using bosh-init](using-bosh-init.html) for details on how to use it.
