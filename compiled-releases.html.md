---
title: Compiled Releases
---

<p class="note">Note: This feature is available with bosh-release v210+.</p>

<p class="note">Note: CLI v2 is used in the examples.</p>

Typically release tarballs are distributed with source packages; however, there may be a requirement to use compiled packages in an environment (for example a production environment) where:

- compilation is not permitted for security reasons
- access to source packages is not permitted for legal reasons
- exact existing audited binary assets are expected to be used

Any release can be exported as a compiled release by using the Director and [bosh export-release](cli-v2.html#export-release) command.

---
## <a id="export"></a> Using export-release command

To export a release:

1. Create an empty deployment (or use an existing one). This deployment will hold compilation VMs if compilation is necessary.

    ```yaml
    name: compilation-workspace

    releases:
    - name: uaa
      version: "45"

    stemcells:
    - alias: default
      os: ubuntu-trusty
      version: latest

    instance_groups: []

    update:
      canaries: 1
      max_in_flight: 1
      canary_watch_time: 1000-90000
      update_watch_time: 1000-90000
    ```

    <p class="note">Note: This example assumes you are using <a href="./cloud-config.html">cloud config</a>, hence no compilation, networks and other sections were defined. If you are not using cloud config you will have to define them.</p>

1. Reference desired release versions you want to export.

1. Deploy. Example manifest above does not allocate any resources when deployed.

1. Run `bosh export-release` command. In our example: `bosh export-release uaa/45 ubuntu-trusty/3197`. If release is not already compiled it will create necessary compilation VMs and compile all packages.

1. Find exported release tarball in the current directory. Compiled release tarball can be now imported into any other Director via `bosh upload-release` command.

1. Optionally use `bosh inspect-release` command to view associated compiled packages on the Director. In our example: `bosh inspect-release uaa/45`.

---
## <a id="floating"></a> Floating stemcells

Compiled releases are built against a particular stemcell version. Director allows compiled releases to be installed on any minor version of the major stemcell version that the compiled release was exported against. `bosh create-env` command requires exact stemcell match unlike the Director.

For example UAA release 27 compiled against stemcell version 3233.10 will work on any 3233 stemcell, but the Director will refuse to install it on 3234.
