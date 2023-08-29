!!! note
    Requires CLI v2.0.36+.

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

CLI v2 introduces new command for release authors to easily vendor final version of a package from another release. BOSH team has also created several package release repositories. Current releases are: [golang-release](https://github.com/cloudfoundry/bosh-package-golang-release), [ruby-release](https://github.com/cloudfoundry/bosh-package-ruby-release), [nginx-release](https://github.com/cloudfoundry/bosh-package-nginx-release), [cf-cli-release](https://github.com/cloudfoundry/bosh-package-cf-cli-release), [java-release](https://github.com/cloudfoundry/bosh-package-java-release), and [python-release](https://github.com/cloudfoundry/bosh-package-python-release). More may be added if deemed to be useful to a number of release authors.

As an example, if release encapsulates a Go application that needs to be compiled with Go compiler (as most Go apps do), release author, instead of figuring out how to make a `golang-1.x` package on their own, can vendor in one from `https://github.com/cloudfoundry/bosh-package-golang-release`.

### Vendoring by example
Here an example how package vendoring could work from scratch. A local blobstore is used for simplicity.
I a productive scenario may use blobstores like Amazon S3 as documented [here](release-blobstore.md).

```shell
# Create a release skeleton
bosh init-release --dir ~/workspace/my-app-release

# Clone golang-release to your system
git clone https://github.com/cloudfoundry/bosh-package-golang-release ~/workspace/bosh-package-golang-release

cd ~/workspace/my-app-release
# Configure local blobstore
echo "
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/local-blobstore" >> config/final.yml

# Perform vendoring of golang-1.18-linux package
bosh vendor-package golang-1.18-linux ~/workspace/bosh-package-golang-release
```

After running the `vendor-package` command
- The local blobstore in `/tmp/local-blobstore` contains the vendored package
- The uploaded package is referenced in `.final_builds/packages/golang-1.18-linux/index.yml`
- A new package `golang-1.18-linux` is added. That package references the vendored package in `.final_builds` by the `spec.lock` file.

The `spec.lock` file and the updates to `.final_builds` have to be checked in.

During development be aware of caching:
- The existence of `.final_builds/packages/golang-1.18-linux/index.yml` prohibits further uploads of the package to the local blobstore.
- Downloaded releases are cached in `~/.bosh/cache`

### Referencing vendored package
In the above steps, CLI v2 vendors the `golang-1.18-linux` package into your `my-app-release` release.
Other packages of `my-app-release` could now reference `golang-1.18-linux` as a dependency just like any other package in the spec file.

Here an example:
```yaml
name: a-depending-package

dependencies:
- golang-1.18-linux

files:
- "**/*.go"
- "**/*.s"
```

As a general convention, packages that need non-trivial configuration (via environment variables, or in some other ways) should include `bosh/compile.env` file that can be sourced by consumers to make use of that package much easier. Here is how `my-app` package's packaging may look like:

```shell
set -e -x
source /var/vcap/packages/golang-1.18-linux/bosh/compile.env

mkdir ../src && cp -a * ../src/ && mv ../src ./src
mkdir $BOSH_INSTALL_TARGET/bin

go build -o $BOSH_INSTALL_TARGET/bin/app src/github.com/company/my-app/main/*.go
```

In the above BASH script, `source /var/vcap/packages/golang-1.18-linux/bosh/compile.env` makes available several Go specific environment variables (`GOPATH` and `GOROOT`) and adds `go` binary to the `PATH` so that executing `go build` just works.

Packages may also include `bosh/runtime.env` for loading specific functionality at job runtime instead of during package compilation.

### Additional notes about `vendor-package` command:

- The command is idempotent, hence could be run in the CI continuously tracking source release and automatically vendoring in updates.
- The command requires [access to the final blobstore](release-blobstore.md) as it will download the source release package blob and upload it into destination release's blobstore.
- The dependencies of a vendored package are vendored as well.

When to use this approach:

- package is readily available from `bosh-packages` Github organization
- package is an internal implementation detail of your release that cannot or should not be swappable by an operator

When to be cautious with this approach:

- source release is not explicitly stating that included packages are meant to be vendored
- package's purpose or implementation is extremely specific to the source release

---
## Using job colocation {: #colocation }

Job colocation can provide a powerful way to make a release extensible and pluggable where necessary. Unlike vendoring approach, release author choosing job colocation as a way to consume dependent software is explicitly stating that there is not necessarily a single one implementation of a particular dependency but rather it could be chosen by an operator at the time of a deploy.

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
