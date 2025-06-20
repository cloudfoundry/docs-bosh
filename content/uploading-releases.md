!!! note
    Document uses CLI v2.

(See [What is a Release?](release.md) for an introduction to releases.)

Each deployment can reference one or many releases. For a `bosh deploy`
operation to succeed, all necessary releases must be uploaded to the Director.

## Finding Releases {: #find }

Releases are distributed in two ways: as a release tarball or through a source
code repository. The [releases section of bosh.io](https://bosh.io/releases)
provides a good list of available releases and their tarballs.

Here are a few popular releases:

- [concourse](https://bosh.io/releases/github.com/concourse/concourse-bosh-release)
  provides a Continuous Integration system called “Concourse CI”, see
  [concourse-ci.org](https://concourse-ci.org/)
- [cf-rabbitmq-release](https://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-release)
  provides RabbitMQ

!!! note
    [cf-release](https://bosh.io/releases/github.com/cloudfoundry/cf-release)
    was popular when it used to provide all software components for Cloud
    Foundry. Then
    [cf-deployment]](https://github.com/cloudfoundry/cf-deployment) emerged
    with modularized sources of software components, now provided by 30+ Bosh
    releases.)

---
## Uploading to the Director {: #upload }

CLI provides [`bosh upload-release` command](cli-v2.md#upload-release).

- If you have a URL to a release tarball (for example a URL provided by bosh.io):

    ```shell
    bosh -e vbox upload-release https://bosh.io/d/github.com/cppforlife/zookeeper-release?v=0.0.5 --sha1 65a07b7526f108b0863d76aada7fc29e2c9e2095
    ```

    Alternatively, if you have a release tarball on your local machine:

    ```shell
    bosh -e vbox upload-release ~/Downloads/zookeeper-0.0.5.tgz
    ```

- If you cloned release Git repository:

    Note that all release repositories have a `releases/` folder that contains
    release YAML files. These files have all the required information about
    how to assemble a specific version of a release (provided that the release
    maintainers produce and commit that version to the repository). You can
    use the YAML files to either directly upload a release, or to create a
    release tarball locally and then upload it.

    ```shell
    git clone https://github.com/cppforlife/zookeeper-release
    cd zookeeper-release/
    bosh -e vbox upload-release
    ```

    Alternatively, to build a release tarball locally from a release YAML file:

    ```shell
    cd zookeeper-release/
    bosh create-release releases/zookeeper/zookeeper-0.0.5.yml --tarball x.tgz
    bosh -e vbox upload-release x.tgz
    ```

Once the command succeeds, you can view all uploaded releases in the Director:

```shell
bosh -e vbox releases
```

```text
Using environment '192.168.56.6' as client 'admin'

Name       Version            Commit Hash
dns        0+dev.1496791266*  65f3b30+
zookeeper  0.0.5*             b434447

(*) Currently deployed
(+) Uncommitted changes

3 releases

Succeeded
```

See [Release URLs](release-urls.md) for more details on the URLs accepted by
`bosh upload-release`.

---
## Deployment Manifest Usage {: #using }

To use an uploaded release in your deployment, update the `releases` section
in your deployment manifest:

```yaml
releases:
  - name: zookeeper
    version: 0.0.5
```
