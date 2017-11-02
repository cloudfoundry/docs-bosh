---
title: Uploading Releases
---

<p class="note">Note: Document uses CLI v2.</p>

(See [What is a Release?](release.html) for an introduction to releases.)

Each deployment can reference one or many releases. For a deploy to succeed, all necessary releases must be uploaded to the Director.

## <a id='find'></a> Finding Releases

Releases are distributed in two ways: as a release tarball or through a source code repository. The [releases section of bosh.io](http://bosh.io/releases) provides a good list of available releases and their tarballs.

Here are a few popular releases:

- [cf-release](http://bosh.io/releases/github.com/cloudfoundry/cf-release) provides CloudFoundry
- [concourse](http://bosh.io/releases/github.com/concourse/concourse) provides a Continious Integration system called Concourse CI
- [cf-rabbitmq-release](http://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-release) provides RabbitMQ

---
## <a id='upload'></a> Uploading to the Director

CLI provides [`bosh upload-release` command](cli-v2.html#upload-release).

- If you have a URL to a release tarball (for example a URL provided by bosh.io):

	<pre class="terminal">
	$ bosh -e vbox upload-release https://bosh.io/d/github.com/cppforlife/zookeeper-release?v=0.0.5 --sha1 65a07b7526f108b0863d76aada7fc29e2c9e2095
	</pre>

	Alternatively, if you have a release tarball on your local machine:

	<pre class="terminal">
	$ bosh -e vbox upload-release ~/Downloads/zookeeper-0.0.5.tgz
	</pre>

- If you cloned release Git repository:

    Note that all release repositories have a `releases/` folder that contains release YAML files. These files have all the required information about how to assemble a specific version of a release (provided that the release maintainers produce and commit that version to the repository). You can use the YAML files to either directly upload a release, or to create a release tarball locally and then upload it.

    <pre class="terminal">
  $ git clone https://github.com/cppforlife/zookeeper-release
	$ cd zookeeper-release/
	$ bosh -e vbox upload-release
	</pre>

	Alternatively, to build a release tarball locally from a release YAML file:

	<pre class="terminal">
	$ cd zookeeper-release/
	$ bosh create-release releases/zookeeper/zookeeper-0.0.5.yml --tarball x.tgz
	$ bosh -e vbox upload-release x.tgz
	</pre>

Once the command succeeds, you can view all uploaded releases in the Director:

<pre class="terminal">
$ bosh -e vbox releases
Using environment '192.168.50.6' as client 'admin'

Name       Version            Commit Hash
dns        0+dev.1496791266*  65f3b30+
zookeeper  0.0.5*             b434447

(*) Currently deployed
(+) Uncommitted changes

3 releases

Succeeded
</pre>

---
## <a id='using'></a> Deployment Manifest Usage

To use an uploaded release in your deployment, update the `releases` section in your deployment manifest:

```yaml
releases:
- name: zookeeper
  version: 0.0.5
```

---
Next: [Deploy](deploying.html)

Previous: [Uploading Stemcells](uploading-stemcells.html)
