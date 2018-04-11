---
title: Vendoring Packages
---

<p class="note">Note: Requires CLI v2.0.36+.</p>

While authoring a release, it is usually necessary to include some commonly used packages:

- languages and/or runtimes such as Ruby, Java JRE or Go
- CLIs such as CF and/or BOSH CLI
- supporting packages for compilation such as Git

It's a recommended practice to make releases be self contained; however, that may force each release author to figure out how to make such common packages on their own. There are several solutions that solve this problem in their distinct way:

- use `bosh vendor-package` command to copy over existing package
- use job colocation (with necessary package dependencies)
- copy over manually package source from a different release

Sections below describe steps, advantages and disadvantages for each approach.

## Using `bosh vendor-package` {: #vendor }

CLI v2 introduces new command for release authors to easily vendor final version of a package from another release. BOSH team has also created [`bosh-packages` Github organization](https://github.com/bosh-packages) for tracking official commonly used packages. First additions to that organization are: `golang-release`, `ruby-release`, `java-release` and `nginx-release`. More may be added if deemed to be useful to a number of release authors.

As an example, if release encapsulates a Go application that needs to be compiled with Go compiler (as most Go apps do), release author, instead of figuring out how to make a `golang-1.x` package on their own, can vendor in one from `https://github.com/bosh-packages/golang-release`. `golang-release` currently contains packages for Golang versions 1.8 and 1.9, and is updated as new minor versions come out.

Such workflow may look like this:

```shell
# Clone golang-release to your system
$ git clone https://github.com/bosh-packages/golang-release ~/workspace/golang-release

$ cd ~/workspace/my-app-release
$ bosh generate-package my-app

# Make sure final blobstore credentials are available
$ vim config/private.yml

# Perform vendoring of golang-1.8-linux package
$ bosh vendor-package golang-1.8-linux ~/workspace/golang-release
```

In the above steps, CLI v2 vendors `golang-1.8-linux` package into your `my-app-release` release, and makes it available just like any other package as a dependency to other packages or jobs:

```yaml
name: my-app

dependencies:
- golang-1.8-linux

files:
- "**/*.go"
- "**/*.s"
```

As a general convention, packages that need non-trivial configuration (via environment variables, or in some other ways) should include `bosh/compile.env` file that can be sourced by consumers to make use of that package much easier. Here is how `my-app` package's packaging may look like:

```bash
set -e -x
source /var/vcap/packages/golang-1.8-linux/bosh/compile.env

mkdir ../src && cp -a * ../src/ && mv ../src ./src
mkdir $BOSH_INSTALL_TARGET/bin

go build -o $BOSH_INSTALL_TARGET/bin/app src/github.com/company/my-app/main/*.go
```

In the above BASH script, `source /var/vcap/packages/golang-1.8-linux/bosh/compile.env` makes available several Go specific environment variables (`GOPATH` and `GOROOT`) and adds `go` binary to the `PATH` so that executing `go build` just works.

Packages may also include `bosh/runtime.env` for loading specific functionality at job runtime instead of during package compilation.

Additional notes about `vendor-package` command:

- command is idempotent hence could be run in the CI continuously tracking source release and automatically vendoring in updates
- command requires access to final blobstore (specified via `config/private.yml`) as it will download source release package blob and upload it into destination release's blobstore
- dependencies of a vendored packaged are vendored as well
- after running the command, the `packages` directory will contain a directory named after the vendored package. That directory will have a `spec.lock` file which references the name and fingerprint of the vendored package. `spec.lock` and updates to the `.final_builds` directory must be saved (checked in).

When to use this approach:

- package is readily available from `bosh-packages` Github organization
- package is an internal implementation detail of your release that cannot or should not be swappable by an operator

When to be cautious with this approach:

- source release is not explicitly stating that included packages are meant to be vendored
- package's purpose or implementation is extremely specific to the source release

---
## Using job colocation {: #colocation }

Job colocation can provide a powerful way to make a release extensible and pluggable where necessary. Unlike vendoring approach, release author choosing job colocation as a way to consume dependent software is explicitly stating that there is not necessarily a single one implementation of a particular dependency but rather it could be chosen by on operator at the time of a deploy.

Here are two examples:

- BOSH CPIs shipped as separate releases and colocated with a Director since Director has a very clear and stable API contract with CPIs

- [BPM release](https://github.com/cloudfoundry-incubator/bpm-release) making `/var/vcap/jobs/bpm/bin/bpm` available to all other releases so that operator can keep BPM release up to date without relying on individual release authors for an update

When to use this approach:

- package does not provide the only way to provide functionality
- release author needs to decouple particular package release cycle from the entire release cycle

When to be cautious with this approach:

- if operators will incur unnecessary burden during a deploy

---
## Copying over package source {: #copy }

Lastly, sometimes it may be necessary to actually copy over (`cp`) software bits from one release to another.

Typically this approach means that release author have to keep very close eye on the upstream software include in this package, hence, it may require more effort to stay up to date.

When to use this approach:

- package is very similar but additional functionality must be added within that package
