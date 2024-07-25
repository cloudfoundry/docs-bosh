!!! note
    This feature is available with bosh-release v210+.

!!! note
    CLI v2 is used in the examples.

Typically release tarballs are distributed with source packages; however, there may be a requirement to use compiled packages in an environment (for example a production environment) where:

- compilation is not permitted for security reasons
- access to source packages is not permitted for legal reasons
- exact existing audited binary assets are expected to be used

Any release can be exported as a compiled release by using the Director and [bosh export-release](cli-v2.md#export-release) command.

---
## Using export-release command {: #export }

To export a release:

1. Create an empty deployment (or use an existing one). This deployment will hold compilation VMs if compilation is necessary.

    ```yaml
    name: compilation-workspace

    releases:
    - name: uaa
      version: "45"

    stemcells:
    - alias: default
      os: ubuntu-xenial
      version: latest

    instance_groups: []

    update:
      canaries: 1
      max_in_flight: 1
      canary_watch_time: 1000-90000
      update_watch_time: 1000-90000
    ```

    !!! note
        This example assumes you are using [cloud config](cloud-config.md), hence no compilation, networks and other sections were defined. If you are not using cloud config you will have to define them.

1. Reference desired release versions you want to export.

1. Deploy. Example manifest above does not allocate any resources when deployed.

1. Run `bosh export-release` command. In our example: `bosh -d compilation-workspace export-release uaa/45 ubuntu-xenial/621.74`. If release is not already compiled it will create necessary compilation VMs and compile all packages.

1. Find exported release tarball in the current directory. Compiled release tarball can be now imported into any other Director via `bosh upload-release` command.

1. Optionally use `bosh inspect-release` command to view associated compiled packages on the Director. In our example: `bosh inspect-release uaa/45`.

---
## Floating stemcells {: #floating }

Compiled releases are built against a particular stemcell version. Director allows compiled releases to be installed on any minor version of the major stemcell version that the compiled release was exported against. `bosh create-env` command requires exact stemcell match unlike the Director.

For example UAA release 27 compiled against stemcell version 3233.10 will work on any 3233 stemcell, but the Director will refuse to install it on 3234.

## Using the bosh-agent compile command {: #bosh-agent-compile }

The `bosh export-release` command requires a BOSH Director and deployed compiler VMs.
You can get a BOSH Release tarball with compiled packages by running the `bosh-agent compile` in a container.

BOSH Stemcells are published as container images to the [Github Container Registry](https://github.com/orgs/cloudfoundry/packages?repo_name=bosh-linux-stemcell-builder).

Create a directory with your release tarball(s):

```shell
mkdir -p releases
curl -L "https://bosh.io/d/github.com/cloudfoundry/bpm-release?v=1.2.17" --output releases/bpm-1.2.17.tgz
```

Compile the release(s):

```shell
docker run --rm -it -v ./releases:/releases GITHUB_CONTAINER_REGISTRY_IMAGE_PATH /var/vcap/bosh/bin/bosh-agent compile --output-directory=/releases '/releases/bpm-1.2.17.tgz'
```

Now your directory "./releases" should contain both tarballs with compiled and non-compiled packages. Like this:

- releases/bpm-1.2.17-ubuntu-jammy-1.406.tgz
- releases/bpm-release-1.2.17.tgz

A shared Concourse Task is maintained in the [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/master/ci/tasks/shared/bosh-agent-compile.yml) repo that can be used for compiling releases on Concourse workers
