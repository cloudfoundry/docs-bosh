A release contains one or more pieces of software that work together.
For example, you could create a release of a service with three pieces:
two MySQL nodes and a dashboard app.

There are four fundamental elements in a release:

* **Jobs** describe pieces of the service or application you are releasing
* **Packages** provide source code and dependencies to jobs
* **Source** provides non-binary files to packages
* **Blobs** provide binary files (other than those checked into a source code repository) to packages

The following instructions use an example release that includes two jobs:
a web UI and a background worker.
The two jobs split up the functionality provided by single Ruby app,
`ardo_app` (you can use simple [gist](https://gist.github.com/antonsoroko/974924e0692aa2171229dafa5f2561b2) as app).

---
## Preparation {: #prep }

This section needs to be completed once.
Next, you iterate through Steps 1 through 6 until your dev release is
satisfactory.
Then you can do a final release.

### Create the release directory {: #release-dir }

To create the release directory, navigate into the workspace where you want the
release to be, and run:

  `bosh init-release --dir <release_name>`

You can add the `--git` option to initialize a git repository.
Use dashes in the release name.
Use underscores for all other filenames in the release.

View the release with `tree`:

```shell
$ tree .
.
├── blobs
├── config
│   └── blobs.yml
├── jobs
├── packages
└── src

5 directories, 1 file
```

When deploying your release, BOSH places compiled code and other resources
in the `/var/vcap/` directory tree, which BOSH creates on the job VMs.
The four directories you just created, `jobs`, `packages`, `src`, and `blobs`,
appear on job VMs as `/var/vcap/jobs`, `/var/vcap/packages`, `/var/vcap/src`,
and `/var/vcap/blobs`, respectively.

### Populate the src directory {: #source }

Copy your source code into the `src` directory.
Alternatively, link your source code to the directory using a mechanism such as
a Git submodule or a Mercurial repo.

### Choose a work strategy {: #strategy }

Choose whether you want to work one step at a time or one job at a time.
For releases with just a few jobs, going one step at a time is probably easiest.
If you have a larger number of jobs, going one job at a time may be more efficient.

---
## Step 1: Create Job Skeletons {: #job-skel }

Navigate into the release directory.

For each job, create a job skeleton:

  `bosh generate-job <job_name>`

In our example, we run `bosh generate-job` twice, once for the `web_ui` job,
and once for the `bg_worker` job.

View the job skeletons with `tree`:

```shell
$ tree .
.
├── blobs
├── config
│   └── blobs.yml
├── jobs
│   ├── bg_worker
│   │   ├── monit
│   │   ├── spec
│   │   └── templates
│   └── web_ui
│       ├── monit
│       ├── spec
│       └── templates
├── packages
└── src

9 directories, 5 files
```

### Create control scripts  {: #control }

Every job needs a way to start and stop.
You provide that by writing a control script and updating the `monit` file.

The control script:

* Includes a start command and a stop command.
* Is an ERB template stored in the `templates` directory for the relevant job.

For each job, create a control script that configures the job to store logs in `/var/vcap/sys/log/JOB_NAME`. Save this script as `ctl.erb` in the `templates` directory for its job.

The control script for the `web_ui` job looks like this:

```bash
#!/bin/bash

RUN_DIR=/var/vcap/sys/run/web_ui
LOG_DIR=/var/vcap/sys/log/web_ui
PIDFILE=${RUN_DIR}/pid

case $1 in

  start)
    mkdir -p $RUN_DIR $LOG_DIR
    chown -R vcap:vcap $RUN_DIR $LOG_DIR

    echo $$ > $PIDFILE

    cd /var/vcap/packages/ardo_app

    export PATH=/var/vcap/packages/ruby_1.9.3/bin:$PATH

    exec /var/vcap/packages/ruby_1.9.3/bin/bundle exec \
      rackup -p <%= properties.web_ui.port %> \
      >>  $LOG_DIR/web_ui.stdout.log \
      2>> $LOG_DIR/web_ui.stderr.log

    ;;

  stop)
    kill -9 `cat $PIDFILE`
    rm -f $PIDFILE

    ;;

  *)
    echo "Usage: ctl {start|stop}" ;;

esac
```

If your release needs templates other than the control script, create them now.

For example if the job can be used to deploy clusters of nodes, especially in
the case of stateful clusters (e.g. a database or distributed data store), you 
will want to write a [drain script](drain.md) for your job to ensure that the
service is not affected by the rolling provisioning/update operations performed
by BOSH.

### Update monit files  {: #monit }

The `monit` file:

* Specifies the process ID (pid) file for the job
* References each command provided by the templates for the job
* Specifies that the job belongs to the `vcap` group

On a deployed release, a BOSH Agent runs on each job VM.
BOSH communicates with the Agent, which in turn executes commands in the
control script.
The Agent does this using open source process monitoring software called
[Monit](http://mmonit.com/monit/).

The `monit` file for the `web_ui` job looks like this:

```
check process web_ui
  with pidfile /var/vcap/sys/run/web_ui/pid
  start program "/var/vcap/jobs/web_ui/bin/ctl start"
  stop program "/var/vcap/jobs/web_ui/bin/ctl stop"
  group vcap
```

Update the `monit` file for each of your jobs.
Use `/var/vcap` paths as shown in the example.

!!! note
    BOSH requires a <code>monit</code> file for each job in a release. When developing a release, you can use an empty <code>monit</code> file to meet this requirement without having to first create a control script.

### Update job specs  {: #job-specs }

At compile time, BOSH transforms templates into files, which it then replicates
on the job VMs.

The template names and file paths are among the metadata for each job that
resides in the job `spec` file.

In the job `spec` file, the `templates` block contains key/value pairs where:

* Each key is template name
* Each value is the path to the corresponding file on a job VM

The file paths that you provide for templates are relative to
the `/var/vcap/jobs/<job_name>` directory on the VM.
For example, `bin/ctl` becomes `/var/vcap/jobs/<job_name>/bin/ctl` on the job VM.
Using `bin` as the directory where these files go is a convention.

The `templates` block of the updated `spec` files for the example jobs look
like this:

```yaml
templates:
  ctl.erb: bin/ctl
```

For each job, update the `spec` file with template names.

### Commit {: #commit-one }

You have now created one or more job skeletons; this is a good time to commit.

If you used the `--git` option with `bosh init-release` (as recommended), the
correct `.gitignore` file has been automatically created for you.

---
## Step 2: Make Dependency Graphs {: #graph }

There are two kinds of dependencies in a BOSH release:

* The **runtime dependency**, where a job depends on a package at runtime.
For example, the `web_ui` job depends on Ruby.
* The **compile-time dependency**, where a package depends on another package at
compile time.
For example, Ruby depends on the YAML library.

Three rules govern these dependencies:

* Jobs never depend on other jobs.
* Jobs can depend on packages.
* Packages can depend on other packages.

### Building the Dependency Graph {: #build-graph }

Create a dependency graph to clarify your understanding of the
dependencies between the jobs and packages in your release.

#### Identify runtime dependencies {: #runtime }

Whenever a control script or other template cites a package name, the job
that the template belongs to depends on the cited package at runtime.

For each job, find all the cases where your control scripts cite packages.
Add these runtime dependencies to your dependency graph.

In our example, this line in both of our `ctl.erb` scripts cites `ardo_app`:

```
cd /var/vcap/packages/ardo_app
```

This line cites Ruby:

```
exec /var/vcap/packages/ruby_1.9.3/bin/bundle exec
```

This means that both the `web-ui` and `bg_worker` jobs have runtime
dependencies on both the `ardo_app` and `ruby_1.9.3` packages.

We add these four runtime dependencies to our example dependency graph.

#### Identify compile-time dependencies {: #compile-time }

Use your knowledge about the runtime dependencies you have already noted.
Consider the packages you have identified as dependencies.
Do any of them depend on other packages in turn?

Whenever a package depends on another package, that is a compile-time
dependency.

For each job, add the compile-time dependencies to your dependency graph.
If you miss a dependency, BOSH lets you know later, when you try to deploy.

In our example, we already noted a runtime dependency on Ruby 1.9.3.
We now ask ourselves whether Ruby 1.9.3 itself has any dependencies.
The answer is yes, it depends on libyaml 0.1.4.

We add this compile-time dependency to our example dependency graph.

#### The complete example dependency graph {: #dep-graph-example }

The complete dependency graph for `ardo-release` looks like this:

![image](images/dep-graph.png)

For a large or complicated release, consider making more than one dependency
graph.

## Step 3: Create Package Skeletons {: #pkg-skeletons }

Packages give BOSH the information needed to prepare the binaries and
dependencies for your jobs.

Create package skeletons starting from the bottom of your dependency graph.

  `bosh generate-package <dependency_name>`

In our example, we run this command three times.
Starting from the bottom of the dependency graph,
we run it for `libyaml_0.1.4`, `ruby_1.9.3`, and `ardo_app`.

View the package skeletons with `tree`:

```shell
$ tree packages
packages
├── ardo_app
│   ├── packaging
│   ├── pre_packaging
│   └── spec
├── libyaml_0.1.4
│   ├── packaging
│   ├── pre_packaging
│   └── spec
└── ruby_1.9.3
    ├── packaging
    ├── pre_packaging
    └── spec

3 directories, 9 files
```

Putting each dependency in a separate package provides maximum reusability
along with a clear, modular structure. This is not mandatory; what packages
to create is a matter of preference. You could even opt to put all the
dependencies together in a single package, though that is not recommended.

!!! note
    Use of the <code>pre_packaging</code> file is not recommended, and is not discussed in this tutorial.

Without using `pre_packaging` for our `ardo_app` we need to pack gems manually for further usage:

```shell
$ cd src/ardo_app/
$ bundle package
```

### Update packaging specs {: #update-pkging-specs }

Within each package directory, there is a `spec` file which states:

* The package name
* The package's dependencies
* The location where BOSH can find the binaries and other files that the package needs at compile time

Use your dependency graph to determine which dependencies belong in each spec.
Developer preferences and style play a role here.
Consider our example: the spec for Ruby lists `rubygems` and `bundler` as dependencies along
with Ruby itself.
Some Ruby developers would do it this way; others would not.

To maximize portability of your release across different versions of stemcells,
never depend on the presence of libraries or other software on stemcells.

To describe binary locations in the `files` block of the spec:

* Find the official site for the binary in question.
For example, Ruby might be at `http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.gz`.

* Download the binary from the official location and make sure the file hash matches.

* Record the binary name including version number, with a slash and the binary
filename concatenated to it.
It's a good idea to cite the official URL in a comment, in the same line.

BOSH interprets the locations you record in the `files` section as being
either in the `src` directory or in the `blobs` directory.
(BOSH looks in `src` first.)
When you add the actual blobs to a blobstore (see the next section),
BOSH populates the `blobs` directory with the correct information.

For packages that depend on their own source code, use the globbing pattern
`<package_name>/**/*` to deep-traverse the directory in `src` where
the source code should reside.

Update the spec for each package.
Refer to the example specs below for guidance.

#### Example libyaml package spec {: #pkg-spec-libyaml }

```yaml
---
name: libyaml_0.1.4

dependencies: []

files:
- libyaml_0.1.4/yaml-0.1.4.tar.gz # From http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
```

#### Example Ruby package spec {: #pkg-spec-ruby }

```yaml
---
name: ruby_1.9.3

dependencies:
- libyaml_0.1.4

files:
- ruby_1.9.3/ruby-1.9.3-p484.tar.gz # http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.gz
- ruby_1.9.3/rubygems-1.8.24.tgz    # http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
- ruby_1.9.3/bundler-1.2.1.gem      # https://rubygems.org/downloads/bundler-1.2.1.gem
```

#### Example ardo_app package spec {: #pkg-spec-ardo }

```yaml
---
name: ardo_app

dependencies:
- ruby_1.9.3

files:
- ardo_app/**/*
```

### Create packaging scripts {: #pkg-scripts }

At compile time, BOSH takes the source files referenced in the package specs,
 and renders them into the executable binaries and scripts that your deployed
jobs need.

You write packaging scripts to instruct BOSH how to do this.
The instructions may involve some combination of copying, compilation, and
related procedures.
For example:

* For a Ruby app like `ardo_app`, BOSH must copy source files and install Ruby
gems.

* For Ruby itself, BOSH must compile source code into a binary.

* For a Python app, BOSH must copy source files and install Python eggs.

BOSH relies on you to write packaging scripts that perform the correct operation.

Adhere to these principles when writing packaging scripts:

* Use your dependency graph to determine which dependencies belong in each
packaging script.

* Begin each script with a `set -e -x` line.
This aids debugging at compile time by causing the script to exit immediately
if a command exits with a non-zero exit code.

* Ensure that any copying, installing or compiling delivers resulting code to
 the install target directory (represented as the `BOSH_INSTALL_TARGET`
environment variable). For `make` commands, use `configure` or its equivalent
to accomplish this.

* Be aware that BOSH ensures that dependencies cited in the `dependencies`
block of package `spec` files are available to the deployed binary.
For example, in the `spec` file for the Ruby package, we cite libyaml as a
dependency.
This ensures that on the compilation VMs, the packaging script for Ruby has
access to the compiled libyaml package.

If the instructions you provide in the packaging scripts fail to deliver compiled
code to `BOSH_INSTALL_TARGET`, the job cannot function because the VM has no
way to find the code to run.
This failure scenario can happen if, for example,
you use a `make` command that delivers compiled code to some standard location
by default.
You can fix the problem by configuring `make` to compile into
`BOSH_INSTALL_TARGET`.
See how this is done in the example packaging scripts.

Like control scripts, writing packaging scripts is one of the heavier tasks
entailed in creating a release.
Write your packaging scripts now.
Refer to the examples below for guidance.

#### Example libyaml packaging script {: #pkg-script-libyaml }

```
set -e -x

tar xzf libyaml_0.1.4/yaml-0.1.4.tar.gz
pushd yaml-0.1.4
  ./configure --prefix=${BOSH_INSTALL_TARGET}

  make
  make install
popd
```

#### Example Ruby packaging script {: #pkg-script-ruby }

```
set -e -x

tar xzf ruby_1.9.3/ruby-1.9.3-p484.tar.gz
pushd ruby-1.9.3-p484
  ./configure \
    --prefix=${BOSH_INSTALL_TARGET} \
    --disable-install-doc \
    --with-opt-dir=/var/vcap/packages/libyaml_0.1.4

  make
  make install
popd

tar zxvf ruby_1.9.3/rubygems-1.8.24.tgz
pushd rubygems-1.8.24
  ${BOSH_INSTALL_TARGET}/bin/ruby setup.rb
popd

${BOSH_INSTALL_TARGET}/bin/gem install ruby_1.9.3/bundler-1.2.1.gem --no-ri --no-rdoc
```

#### Example ardo_app packaging script {: #pkg-script-ardo }

```
set -e -x

cp -a ardo_app/* ${BOSH_INSTALL_TARGET}

cd ${BOSH_INSTALL_TARGET}

/var/vcap/packages/ruby_1.9.3/bin/bundle install \
  --local \
  --deployment \
  --without development test
```

### Update job specs with dependencies {: #update-job-specs-with-deps }

The dependency graph reveals runtime dependencies that
need to be added to the `packages` block of the job spec.

Edit the job specs to include these dependencies.

In our example, the dependency graph shows that `web_ui` job depends on
`ardo_app` and `ruby_1.9.3`:

```yaml
packages:
- ardo_app
- ruby_1.9.3
```

---
## Step 4: Add Blobs {: #blobs }

When creating a release, you will likely use a source code repository.
But releases often use tar files or other binaries, also known as blobs.
Checking blobs into a repository is problematic if your repository
unsuited to dealing with large binaries (as is true of Git, for example).

BOSH lets you avoid checking blobs into a repository by doing the following:

* For dev releases, use local copies of blobs.

* For a final release, upload blobs to a blobstore, and direct BOSH to obtain the blobs from there.

### Configure a blobstore  {: #config-blobstore }

In the `config` directory, you record the information BOSH needs about the
blobstore:

* The `final.yml` file names the blobstore and declares its type, which is either `local`
or one of several other types that specify blobstore providers.

* The `private.yml` file specifies the blobstore path, along with a secret.

`private.yml` contains keys for accessing the blobstore and should not be
checked into a repository.
(If you used the `--git` option when running `bosh init-release` at the beginning
of this tutorial, `private.yml` is automatically `gitignored`.)

The `config` directory also contains two files whose content is automatically
generated: the `blobs.yml` file and the `dev.yml` file.

Adapt the examples below to fit the specifics of your release.
Our example release uses the `local` type blobstore because otherwise it would
be necessary to explain how to configure a public blobstore such as
Amazon S3, which is too large a topic for this context. More information on full
blobstore configuration can be found [here](release-blobstore.md).

The `local` type blobstore is suitable for learning but the resulting release
cannot be shared.
For that reason, you should configure a non-local, publicly available blobstore
for releases that you intend to share.
Normally, the blobstore you choose when you begin working on a release is used
for all subsequent versions of the release.
Changing the blobstore that a release uses is beyond the scope of this tutorial.

Example `final.yml`:

```yaml
---
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/ardo-blobs
final_name: ardo_app
```

Example `private.yml`:

```yaml
---
blobstore_secret: 'does-not-matter'
blobstore:
  local:
    blobstore_path: /tmp/ardo-blobs

```

If you have a `private.yml` file:

* **Required**: Include the `blobstore_path` in the `private.yml` file.
* **Optional**: Include the `blobstore_path` in the `final.yml` file. Doing so allows you to `gitignore` the `private.yml` file but still allow the release to be downloaded and used on other systems.

!!! note
    The `blobstore_secret` is required for the `local` type blobstore. This is true even though the `blobstore_secret` line is deprecated and its content does not matter. There is never a `blobstore_secret` line for blobstores of types other than `local`.

### Inform BOSH where blobs are {: #inform }

In the package `spec` file, the `files` block lists any binaries you downloaded,
along with the URLs from which you downloaded them.
(This assumes that you followed the directions in the [Update package specs](#update-pkging-specs) section.)

Those files are blobs, and now you need the paths to the downloaded blobs on
your local system.

In our example, the `spec` file for the `libyaml_0.1.4` package includes the line:

```yaml
files:
- libyaml_0.1.4/yaml-0.1.4.tar.gz # From http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
```

If you downloaded the blob, its local path might be:

`~/Downloads/yaml-0.1.4.tar.gz`

Go through all your packages and make a list of local paths to the blobs you downloaded.
Now you are ready to inform BOSH about these blobs.

For each blob, run:

`bosh add-blob <path_to_blob_on_local_system> <package_name>`

e.g.

`bosh add-blob ~/Downloads/yaml-0.1.4.tar.gz libyaml_0.1.4`

The `bosh add-blob` command adds a local blob to the collection your release
recognizes as BOSH blobs.

The usage shown above is a blend of requirement and convention.
It works like this:

* For the first argument, you provide the path to the blob on your local system
* For the second argument, you provide a destination within the `blobs` directory
in your release
* BOSH goes into the `blobs` directory and creates a subdirectory with
the name of the package that the local blob represents
* In the new subdirectory, BOSH creates a symbolic link to a copy of the blob
which BOSH makes in a hidden directory

Using the package name as the second argument of the `bosh add-blob` command
is recommended because it produces a cleanly-organized blobs directory.

Later, when you upload blobs for a final release, BOSH uses the hidden directory
as a staging area.

### Do not upload blobs for a dev release {: #no-upload }

Once you have uploaded blobs to a non-local blobstore, those blobs may become
essential to some other developer.
For this reason, uploading a blob and then removing it is considered poor practice.

When creating dev releases, do not run `bosh upload-blobs`.
(You only run it when you do a final release.)

---
## Step 5: Create Job Properties  {: #create-props }

If your service needs to be configurable at deployment time,
you create the desired inputs or controls and specify them in the release.
Each input is a _property_ that belongs to a particular job.

Creating properties requires three steps:

1. Define properties and defaults in the `properties` block of
the job spec.

1. Use the property lookup helper `p()` to reference properties in
relevant templates.

For example, a start command can take a property as an argument,
using the property lookup helper:

       <%= p('<job_name>.<property_name>') %>

1. Specify the property in the [deployment manifest](manifest-v2.md#instance-groups).

Adapt the example below to create any properties your release needs now.

In our example, we want the port that the web UI listens on to be a
configurable property.

We edit the spec for the web UI job to look like this:

```yaml
properties:
   port:
     description: Port that web_ui app listens on
     default: 80
```

---
## Step 6: Create a Dev Release  {: #dev-release }

All the elements needed to create a dev release should now be in place.

### Release  {: #dev-release-release }

For the dev release, use the `--force` option with the `bosh create-release`
command.
This forces BOSH to use the local copies of our blobs.

Without the `--force` option, BOSH requires blobs to be uploaded before you
run `bosh create-release`.
For a final release, we upload blobs, but not for a dev release.

Create the dev release:

`bosh create-release --force`

BOSH prompts for a release name, and assigns a dot-number version to the release.

### Deploy the Dev Release  {: #dev-release-deploy }

Deploying the release requires three or more steps, depending on whether
BOSH is targeting the desired Director, and whether BOSH is already pointing
to a release.

See what director BOSH is targeting:

  `bosh env`

Target a director:

  `bosh -e <director_alias> log-in`

See what releases are available:

  `bosh releases`

If BOSH is already pointing to a release, edit the BOSH deployment manifest.
Otherwise, create a manifest. See [BOSH Deployment Manifest](manifest-v2.md) for more information.
Simple manifest for `ardo_app` can be found [here](https://gist.github.com/antonsoroko/3be4c70b38f846b1d79eca7192a5ab58) (OpenStack) or [here](https://gist.github.com/uzzz/9ad9cad105032fecdbeb223798607a87) (AWS).

Upload the new dev release.

   `bosh upload-release`

Assuming you are in the release directory, no path is needed with the above command.

Deploy:

   `bosh deploy`

### Test the Dev Release  {: #dev-release-test }

What tests to run depends on the software you are releasing.

Start by opening a separate terminal, logging in on the job VM, and observing
logging output as you test your release.

If your release fails tests, follow this pattern.

* Fix the code.
* Do a new dev release.
* Run `bosh deploy` to see whether the new release deploys successfully.

Using `bosh deploy --recreate` can provide a clearer picture because with that option,
BOSH deploys all the VMs from scratch.

---
## Create a Final Release  {: #final-release }

Only proceed to this step if your latest dev release passes all tests.

### Upload blobs {: #upload-blobs }

When you use the `bosh create-release --force` command to create them, dev
releases depend on locally-stored blobs.
To do a final release, you must upload blobs first.

If files that you need to keep private are uploaded to a public blobstore,
there is no satisfactory way to undo the mistake.
To avoid this situation, complete the following steps immediately before
you upload blobs:

1. Run `bosh blobs` to see the list of blobs BOSH is prepared to upload

1. Proofread the list of blobs displayed by the command

1. The list should include only the blobs you need for the final release

1. If the list includes any files that should not be uploaded, find and delete
the symbolic links to them in the `blobs` directory

To upload your blobs, run:

  `bosh upload-blobs`

### Commit {: #final-commit-two }

The `bosh upload-blobs` command has now populated the `blobs.yml` file
in the `config` directory with metadata for uploaded blobs.

This is a good reason to commit.

### Release {: #final-release-release }

Run:

  `bosh create-release --final`

BOSH prompts you for a release name, and assigns a whole-number version to the release.

This is a good time to push your code to a shared repository to give others access to
your final release.

### Commit {: #final-release-commit }

Do one more commit before you deploy!

### Deploy the Final Release  {: #final-release-deploy }

Run:

`bosh deploy`
