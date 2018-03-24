---
title: CLI v2+
---

<p class="note">Note: Applies to CLI v3.0.1+.</p>

The BOSH Command Line Interface (CLI) is what you use to run BOSH commands. CLI v2 is a new major version of CLI.

---
## Install <a id="install"></a>

1. Download the binary for your platform and place it on your `PATH`:

  - [bosh-cli-3.0.1-darwin-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-darwin-amd64) <span class="sha1">sha1: d2fea20210a47b8c8f1f7dbb27ffb5808d47ce87</span>
  - [bosh-cli-3.0.1-linux-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64) <span class="sha1">sha1: ccc893bab8b219e9e4a628ed044ebca6c6de9ca0</span>
  - [bosh-cli-3.0.1-windows-amd64.exe](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-windows-amd64.exe) <span class="sha1">sha1: 41c23c90cab9dc62fa0a1275dcaf64670579ed33</span> (Windows CLI support is partial)

    ```shell
    $ chmod +x ~/Downloads/bosh-cli-*
    $ sudo mv ~/Downloads/bosh-cli-* /usr/local/bin/bosh
    ```

1. Check `bosh` version to make sure it is properly installed:

    ```shell
    $ bosh -v
    version 3.0.1-712bfd7-2018-03-13T23:26:42Z
    ```

    If the output does not begin with `version 2.0...` (or `3.0`) you are probably executing CLI v1 (Ruby based).

1. [Install OS specified dependencies](cli-env-deps.md) for `bosh create-env` command

Alternatively, refer to [cloudfoundry/homebrew-tap](https://github.com/cloudfoundry/homebrew-tap) to install CLI via Homebrew on OS X. We currently do not publish CLI via apt or yum repositories.

---
## Global Flags <a id="global-flags"></a>

See [Global flags](cli-global-flags.md) for more details on how to enable different output formats, debug logging, etc.

---
## Commands <a id="cmds"></a>

### Environments <a id="env-mgmt"></a>

See [Environments](cli-envs.md).

- <a id="environments"></a> `bosh environments` (Alias: `envs`)

    Lists aliased environments known to the CLI. Aliasing is done via `alias-env` command.

    ```shell
    $ bosh envs
    URL              Alias
    104.154.171.255  gcp
    192.168.56.6     vbox

    2 environments

    Succeeded
    ```

- <a id="create-env"></a> `bosh create-env manifest.yml [--state path] [-v ...] [-o ...] [--vars-store path]`

    Creates single VM based on the manifest. Typically used to create a Director environment. [Operation files](https://bosh.io/docs/cli-ops-files.html) and [variables](https://bosh.io/docs/cli-int.html) can be provided to adjust and fill in manifest before doing a deploy.

    `create-env` command replaces `bosh-init deploy` CLI command.

    ```shell
    $ bosh create-env ~/workspace/bosh-deployment/bosh.yml \
      --state state.json \
      --vars-store ./creds.yml \
      -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
      -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
      -o ~/workspace/bosh-deployment/bosh-lite.yml \
      -o ~/workspace/bosh-deployment/jumpbox-user.yml \
      -v director_name=vbox \
      -v internal_ip=192.168.56.6 \
      -v internal_gw=192.168.56.1 \
      -v internal_cidr=192.168.56.0/24 \
      -v network_name=vboxnet0 \
      -v outbound_network_name=NatNetwork
    ```

- <a id="alias-env"></a> `bosh alias-env name -e location [--ca-cert=path]`

    Assigns a name to the created environment for easier access in subsequent CLI commands. Instead of specifying Director location and possibly a CA certificate, subsequent commands can just take given name via `--environment` flag (`-e`).

    ```shell
    $ bosh alias-env gcp -e bosh.corp.com
    $ bosh alias-env gcp -e 10.0.0.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca)
    ```

- <a id="environment"></a> `bosh -e location environment` (Alias: `env`)

    Shows Director information in the deployment environment.

    ```shell
    $ bosh -e vbox env
    Using environment '192.168.56.6' as '?'

    Name      vbox
    UUID      eeb27cc6-467e-4c1d-a8f9-f1a8de759f52
    Version   260.5.0 (00000000)
    CPI       warden_cpi
    Features  compiled_package_cache: disabled
              dns: disabled
              snapshots: disabled
    User      admin

    Succeeded
    ```

- <a id="delete-env"></a> `bosh delete-env manifest.yml [--state path] [-v ...] [-o ...] [--vars-store path]`

    Deletes previously created VM based on the manifest. Same flags provided to `create-env` command should be given to the `delete-env` command.

    `delete-env` command replaces `bosh-init delete` CLI command.

    ```shell
    $ bosh delete-env ~/workspace/bosh-deployment/bosh.yml \
      --state state.json \
      --vars-store ./creds.yml \
      -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
      -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
      -o ~/workspace/bosh-deployment/bosh-lite.yml \
      -o ~/workspace/bosh-deployment/jumpbox-user.yml \
      -v director_name=vbox \
      -v internal_ip=192.168.56.6 \
      -v internal_gw=192.168.56.1 \
      -v internal_cidr=192.168.56.0/24 \
      -v network_name=vboxnet0 \
      -v outbound_network_name=NatNetwork
    ```

---
### Session <a id="session-mgmt"></a>

- <a id="log-in"></a> `bosh log-in` (Alias: `l`, `login`)

    Logs in given user into the Director.

    This command can only be used interactively. If non-interactive use is necessary (for example in scripts) please set `BOSH_CLIENT` and `BOSH_CLIENT_SECRET` environment variables instead of using this command. Note that if the Director is configured with UAA authentication you cannot use UAA users with BOSH_* environment variables but rather have to use UAA clients.

    ```shell
    $ bosh -e my-env l
    User (): admin
    Password ():
    ```

- <a id="log-out"></a> `bosh log-out` (Alias: `logout`)

    Logs out currently logged in user.

---
### Stemcells <a id="stemcell-mgmt"></a>

See [Uploading Stemcells](uploading-stemcells.md).

- <a id="stemcells"></a> `bosh -e my-env stemcells` (Alias: `ss`)

    Lists stemcells previously uploaded into the Director. Shows their names, versions and CIDs.

    ```shell
    $ bosh -e my-env ss
    Using environment '192.168.56.6' as '?'

    Name                                         Version  OS             CPI  CID
    bosh-warden-boshlite-ubuntu-trusty-go_agent  3363*    ubuntu-trusty  -    6cbb176a-6a43-42...
    ~                                            3312     ubuntu-trusty  -    43r3496a-4rt3-52...
    bosh-warden-boshlite-centos-7-go_agent       3363*    centos-7       -    38yr83gg-349r-94...

    (*) Currently deployed

    3 stemcells

    Succeeded
    ```

- <a id="upload-stemcell"></a> `bosh -e my-env upload-stemcell location [--sha1=digest] [--fix]` (Alias: `us`)

    Uploads stemcell to the Director. Succeeds even if stemcell is already imported.

    Stemcell location may be local file system path or an HTTP/HTTPS URL.

    `--fix` flag allows operator to replace previously uploaded stemcell with the same name and version to repair stemcells that might have been corrupted in the cloud.

    ```shell
    $ bosh -e my-env us ~/Downloads/bosh-stemcell-3468.17-warden-boshlite-ubuntu-trusty-go_agent.tgz
    $ bosh -e my-env us https://bosh.io/d/stemcells/bosh-stemcell-warden-boshlite-ubuntu-trusty-go_agent?v=3468.17
    ```

- <a id="delete-stemcell"></a> `bosh -e my-env delete-stemcell name/version`

    Deletes uploaded stemcell from the Director. Succeeds even if stemcell is not found.

    ```shell
    $ bosh -e my-env delete-stemcell bosh-warden-boshlite-ubuntu-trusty-go_agent/3468.17
    ```

- <a id="repack-stemcell"></a> `bosh repack-stemcell src.tgz dst.tgz [--name=name] [--version=ver] [--cloud-properties=json-string]`

    Produces new stemcell tarball with updated properties such as name, version, and cloud properties.

    See [Repacking stemcells](repack-stemcell.md) for details.

---
### Release creation <a id="release-creation"></a>

- <a id="init-release"></a> `bosh init-release [--git] [--dir=dir]`

    Creates an empty release skeleton for a release in `dir`. By default `dir` is the current directory.

    `--git` flag initializes release skeleton as a Git repository, adding appropriate `.gitignore` file.

    ```shell
    $ bosh init-release --git --dir release-dir
    $ cd release-dir
    ```

- <a id="generate-job"></a> `bosh generate-job name [--dir=dir]`

    Creates an empty job skeleton for a release in `dir`. Includes bare `spec` and an empty `monit` file.

- <a id="generate-package"></a> `bosh generate-package name [--dir=dir]`

    Creates an empty package skeleton for a release in `dir`. Includes bare `spec` and an empty `packaging` file.

- <a id="vendor-package"></a> `bosh vendor-package name src-dir [--dir=dir]` (v2.0.36+)

    Vendors a package from a different release into a release in `dir`. It includes `spec.lock` in the package directory so that CLI will reference specific package by its fingerprint when creating releases.

    See [Package vendoring](package-vendoring.md) for details.

- <a id="create-release"></a> `bosh create-release [--force] [--version=ver] [--timestamp-version] [--final] [--tarball=path] [--dir=dir]` (Alias: `cr`)

    Creates new version of a release stored in `dir`

    - `--force` flag specifies to ignore uncommitted changes in the release directory; it should only be used when building dev releases
    - `--version` flag allows operator to provide custom release version
    - `--timestamp-version` flag will produce timestamp based dev release version
    - `--tarball` flag specifies destination of a release tarball; if not specified, release tarball will not be produced
    - `--sha2` flag to use SHA256 checksum

    While iterating on a release it's common to run `bosh create-release --force && bosh -e my-env upload-release && bosh -e my-env -d my-dep deploy manifest.yml` command sequence.

    In a CI pipeline it's common to use this command to create a release tarball and pass it into acceptance or end-to-end tests. Once release tarball goes through appropriate tests it can be finalized with a `finalize-release` command and shared with release consumers.

    ```shell
    $ cd release-dir
    $ bosh create-release --force
    $ bosh create-release --timestamp-version
    $ bosh create-release --version 9+dev.10
    $ bosh create-release --tarball /tmp/my-release.tgz
    $ bosh create-release --final
    $ bosh create-release --version 20 --final
    $ bosh create-release releases/zookeeper/zookeeper-3.yml --tarball /tmp/my-release.tgz
    ```

- <a id="finalize-release"></a> `bosh finalize-release release.tgz [--force] [--version=ver] [--dir=dir]`

    Records contents of a release tarball as a final release with an optionally given version. Once `.final_builds` and `releases` directories are updated, it's strongly recommended to commit your changes to version control.

    Typically this command is used as a final step in the CI pipeline to save the final artifact once it passed appropriate tests.

    ```shell
    $ cd release-dir
    $ bosh finalize-release /tmp/my-release.tgz
    $ bosh finalize-release /tmp/my-release.tgz --version 20
    $ git commit -am 'Final release 20'
    $ git push origin master
    ```

- <a id="reset-release"></a> `bosh reset-release [--dir=dir]`

    Removes temporary artifacts such as dev releases, blobs, etc. kept in the release directory `dir`.

---
### Release blobs <a id="blob-mgmt"></a>

See [Release Blobs](release-blobs.md) for a detailed workflow.

- <a id="blobs"></a> `bosh blobs`

    Lists tracked blobs from `config/blobs.yml`. Shows uploaded and not-yet-uploaded blobs.

    ```shell
    $ cd release-dir
    $ bosh blobs
    Path                               Size     Blobstore ID         Digest
    golang/go1.6.2.linux-amd64.tar.gz  81 MiB   f1833f76-ad8b-4b...  b8318b0...
    stress/stress-1.0.4.tar.gz         187 KiB  (local)              e1533bc...

    2 blobs

    Succeeded
    ```

- <a id="add-blob"></a> `bosh add-blob src-path dst-path`

    Sarts tracking blob in `config/blobs.yml` for inclusion in packages.

    ```shell
    $ cd release-dir
    $ bosh add-blob ~/Downloads/stress-1.0.4.tar.gz stress/stress-1.0.4.tar.gz
    ```

- <a id="remove-blob"></a> `bosh remove-blob blob-path`

    Stops tracking blob in `config/blobs.yml`. Does not remove previously uploaded copies from the blobstore as older release versions may still want to reference it.

    ```shell
    $ cd release-dir
    $ bosh remove-blob stress/stress-1.0.4.tar.gz
    ```

- <a id="upload-blob"></a> `bosh upload-blobs`

    Uploads previously added blobs that were not yet uploaded to the blobstore. Updates `config/blobs.yml` with returned blobstore IDs. Before creating a final release it's strongly recommended to upload blobs so that other release contributors can rebuild a release from scratch.

    ```shell
    $ cd release-dir
    $ bosh upload-blobs
    ```

- <a id="sync-blob"></a> `bosh sync-blobs`

    Downloads blobs into `blobs/` based on `config/blobs.yml`.

    ```shell
    $ cd release-dir
    $ bosh sync-blobs
    ```

---
### Releases <a id="release-mgmt"></a>

See [Uploading Releases](uploading-releases.md).

- <a id="releases"></a> `bosh -e my-env releases` (Alias: `rs`)

    Lists releases previously uploaded into the Director. Shows their names and versions.

    ```shell
    $ bosh -e my-env rs
    Using environment '192.168.56.6' as client 'admin'

    Name               Version   Commit Hash
    capi               1.21.0*   716aa812
    cf-mysql           34*       e0508b5
    cf-smoke-tests     11*       a6dad6e
    cflinuxfs2-rootfs  1.52.0*   4827ef51+
    consul             155*      22515a98+
    diego              1.8.1*    0cca668e
    dns                3*        57e27da
    etcd               94*       57c81e16
    garden-runc        1.2.0*    2b3dedc5
    loggregator        78*       773a3ba
    nats               15*       d4dfc4c1+
    routing            0.145.0*  dfb44c41+
    statsd-injector    1.0.20*   552926d
    syslog             9         ac2172f
    uaa                25*       86ec7568

    (*) Currently deployed
    (+) Uncommitted changes

    15 releases

    Succeeded
    ```

- <a id="upload-release"></a> `bosh -e my-env upload-release [location] [--version=ver] [--sha1=digest] [--fix]` (Alias: `ur`)

    Uploads release to the Director. Succeeds even if release is already imported.

    Release location may be local file system path, HTTP/HTTPS URL or a git URL.

    `--fix` flag allows replacement of previously uploaded release with the same name and version to repair releases that might have been corrupted.

    ```shell
    $ bosh -e my-env ur
    $ bosh -e my-env ur https://bosh.io/d/github.com/concourse/concourse?v=2.7.3
    $ bosh -e my-env ur git+https://github.com/concourse/concourse --version 2.7.3
    ```

- <a id="delete-release"></a> `bosh -e my-env delete-release name/version`

    Deletes uploaded release from the Director. Succeeds even if release is not found.

    ```shell
    $ bosh -e my-env delete-release cf-smoke-tests/94
    ```

- <a id="export-release"></a> `bosh -e my-env -d my-dep export-release name/version os/version [--dir=dir]`

    Compiles and exports a release against a particular stemcell version.

    Requires to operate with a deployment so that compilation resources (VMs) are properly tracked.

    Destination directory default to the current directory.

    ```shell
    $ bosh -e my-env -d my-dep export-release cf-smoke-tests/94 ubuntu-trusty/3369
    ```

- <a id="inspect-release"></a> `bosh -e my-env inspect-release name/version`

    Lists all jobs, job metadata (such as links), packages, and compiled packages associated with a release version.

    ```shell
    $ bosh -e gcp-test inspect-release consul/155
    Using environment '192.168.56.6' as client 'admin'

    Job                                                                    Blobstore ID       Digest       Links Consumed    Links Provided
    acceptance-tests/943c6083581e623dc66c7d9126d8e5989c4c2b31              0f3cd013-1d3d-...  17e5e4fc...  -                 -
    consul-test-consumer-windows/6748c0675da2292c680da03e89b738a9d5818370  7461c74c-745d-...  9809861c...  -                 -
    consul-test-consumer/7263db87ba85eaf0dd41bd198359c8597e961839          8bde4572-8e8b-...  7b08b059...  -                 -
    consul_agent/b4872109282347700eaa884dcfe93f3a03dc22dd                  e41f705e-2cb7-...  a8db2c76...  - name: consul    - name: consul
                                                                                                             type: consul      type: consul
                                                                                                             optional: true
    consul_agent_windows/a0b91cb0aa1029734d77fcf064dafdb67f14ada6          3a8755d0-7a39-...  17f07ec0...  - name: consul    - name: consul
                                                                                                             type: consul      type: consul
                                                                                                             optional: true
    fake-dns-server/a1ea5f64de0860512470ace7ce2376aa9470f9b1               5bb53f17-eba9-...  0565f9af...  -                 -

    6 jobs

    Package                                                            Compiled for          Blobstore ID            Digest
    acceptance-tests-windows/e36cef763e5cfd4e28738ad314807e6d1e13b960  (source)              03589024-2596-49fc-...  96eaaf4ba...
    acceptance-tests/9d56ac03d7410dcdfd96a8c96bbc79eb4b53c864          (source)              79fb9ba7-cd23-4b93-...  e08ee88f5...
    confab-windows/52b117effcd95138eca94c789530bcd6499cff9d            (source)              53d4b206-b064-462d-...  43f92c8d0...
    confab/b2ff0bbd68b7d600ecb1ffaf41f59af073e894fd                    (source)              b93214eb-a816-4029-...  4b627d264...
    ~                                                                  ubuntu-trusty/3363.9  f66fe541-8c21-4fe3-...  8e662c2e2...
    consul-windows/2a8e0b7ce1424d1d5efe5c7184791481a0c26424            (source)              9516870b-801e-42ea-...  19db18127...
    consul/6049d3016cd34ac64ccbf7837b06b6db81942102                    (source)              04aa38af-e883-4842-...  c42cacfc7...
    ~                                                                  ubuntu-trusty/3363.9  ab4afda6-881e-46b1-...  27c1390fa...
    golang1.7-windows/1a80382e081cd429cf518f0c783f4e4172cac79e         (source)              d7670210-7038-4749-...  b91caa06a...
    golang1.7/181f7537c2ec17ac2406d9f2eb3322fd80fa2a1c                 (source)              ac8aa36a-8965-46e9-...  ca440d716...
    ~                                                                  ubuntu-trusty/3363.9  9d40794f-0c50-4d0c-...  9d6e29221...

    11 packages

    Succeeded
    ```

---
### Configs <a id="configs-mgmt"></a>

See [Configs](configs.md).

- <a id="configs"></a> `bosh -e my-env configs [--type=my-type] [--name=my-name]`

    Lists all the configs on the Director.

    ```shell
    $ bosh -e my-env configs
    Using environment '192.168.50.6' as client 'admin'

    Type     Name
    cloud    default
    ~        custom-vm-types
    cpi      default
    runtime  default

    3 configs

    Succeeded
    ```

- <a id="config"></a> `bosh -e my-env config [id] [--type=my-type] [--name=my-name]`

    Either show config by `id` or by `name` and `type` on the Director.

    ```shell
    $ bosh -e my-env config --type=my-type --name=my-name
    $ bosh -e my-env config 5
    ```

- <a id="update-config"></a> `bosh -e my-env update-config config.yml --type=my-type [--name=my-name]`

    Update config on the Director.

    - `--type` (required) flag allows to specify config type
    - `--name` flag allows to specify custom config name

    ```shell
    $ bosh -e my-env update-config config.yml --type=cloud
    $ bosh -e my-env update-config config.yml --type=cloud --name=network1
    ```

- <a id="delete-config"></a> `bosh -e my-env delete-config --type=my-type [--name=my-name]`

    Delete config on the Director.

    - `--type` (required) flag allows to specify config type
    - `--name` flag allows to specify custom config name

    ```shell
    $ bosh -e my-env delete-config --type=my-type
    $ bosh -e my-env delete-config --type=my-type --name=my-name
    ```

---
### Cloud config <a id="cloud-config-mgmt"></a>

See [Cloud config](cloud-config.md).

- <a id="cloud-config"></a> `bosh -e my-env cloud-config` (Alias: `cc`)

    Show current cloud config on the Director.

- <a id="update-cloud-config"></a> `bosh -e my-env update-cloud-config config.yml [-v ...] [-o ...]` (Alias: `ucc`)

    Update current cloud config on the Director.

    ```shell
    $ bosh -e my-env ucc cc.yml
    ```

---
### Runtime config <a id="runtime-config-mgmt"></a>

See [Runtime config](runtime-config.md).

- <a id="runtime-config"></a> `bosh -e my-env runtime-config` (Alias: `rc`)

    Show current runtime config on the Director.

- <a id="update-runtime-config"></a> `bosh -e my-env update-runtime-config config.yml [-v ...] [-o ...]` (Alias: `urc`)

    Update current runtime config on the Director.

    ```shell
    $ bosh -e my-env urc runtime.yml
    ```

---
### CPI config <a id="cpi-config-mgmt"></a>

See [CPI config](cpi-config.md).

- <a id="cpi-config"></a> `bosh -e my-env cpi-config`

    Show current CPI config on the Director.

- <a id="update-cpi-config"></a> `bosh -e my-env update-cpi-config config.yml [-v ...] [-o ...]`

    Update current CPI config on the Director.

    ```shell
    $ bosh -e my-env update-cpi-config cpis.yml
    ```

---
### Deployments <a id="deployment-mgmt"></a>

- <a id="deployments"></a> `bosh -e my-env deployments` (Alias: `ds`)

    Lists deployments tracked by the Director. Shows their names, used releases and stemcells.

    ```shell
    $ bosh -e my-env ds
    Using environment '192.168.56.6' as client 'admin'

    Name                                Release(s)                Stemcell(s)                                         Team(s)  Cloud Config
    cf                                  binary-buildpack/1.0.9    bosh-warden-boshlite-ubuntu-trusty-go_agent/3363.9  -        latest
                                        capi/1.21.0
                                        cf-mysql/34
                                        cf-smoke-tests/11
                                        cflinuxfs2-rootfs/1.52.0
                                        consul/155
                                        diego/1.8.1
                                        etcd/94
                                        garden-runc/1.2.0
                                        loggregator/78
                                        nats/15
                                        routing/0.145.0
                                        statsd-injector/1.0.20
                                        uaa/25
    service-instance_0d4140a0-42b7-...  mysql/0.6.0               bosh-warden-boshlite-ubuntu-trusty-go_agent/3363.9  -        latest

    2 deployments

    Succeeded
    ```

- <a id="deployment"></a> `bosh -e my-env -d my-dep deployment` (Alias: `dep`)

    Shows general deployment information for a given deployment.

    Can be used to determine if Director has a deployment with a given name.

    ```shell
    $ bosh -e vbox -d cf dep
    Using environment '192.168.56.6' as client 'admin'

    Name  Release(s)              Stemcell(s)                                         Team(s)  Cloud Config
    cf    binary-buildpack/1.0.9  bosh-warden-boshlite-ubuntu-trusty-go_agent/3363.9  -        latest
          capi/1.21.0
          cf-mysql/34
          cf-smoke-tests/11
          uaa/25
          dns/3
          ...

    1 deployments

    Succeeded
    ```

- <a id="deploy"></a> `bosh -e my-env -d my-dep deploy manifest.yml [-v ...] [-o ...]`

    Create or update specified deployment according to the provided manifest. Operation files and variables can be provided to adjust and fill in manifest before deploy begins.

    Currently name provided via `--deployment` (`-d`) flag must match name specified in the manifest.

    ```shell
    $ bosh -e vbox -d cf deploy cf.yml -v system_domain=sys.example.com -o large-footprint.yml
    ```

- <a id="delete-deployment"></a> `bosh -e my-env -d my-dep delete-deployment [--force]` (Alias: `deld`)

    Deletes specified deployment. If `--force` is provided, ignores variety of errors (from IaaS, blobstore, database) when deleting.

    Note that if you've deleted your deployment, not all resources may have been freed. For example "deleted" persistent disks will be deleted after a few days to avoid accidental data loss. See [Persistent and Orphaned Disks](persistent-disks.md) for more details.

    Succeeds even if deployment is not found.

    ```shell
    $ bosh -e vbox -d cf deld
    $ bosh -e vbox -d cf deld --force
    ```

- <a id="instances"></a> `bosh -e my-env [-d my-dep] instances [--ps] [--details] [--vitals] [--failing]` (Alias: `is`)

    Lists all instances managed by the Director or in a single deployment. Show instance names, IPs, and VM and process health.

    - `--details` (`-i`) flag includes VM CID, persistent disk CIDs, and other instance level details
    - `--ps` flag includes per process health information
    - `--vitals` flag shows basic VM and process usage such RAM, CPU and disk.
    - `--failing` flag hides all healthy instances and processes leaving only non-healthy ones; useful for scripting

    ```shell
    $ bosh -e vbox is -i
    $ bosh -e vbox is --ps --vitals
    $ bosh -e vbox -d cf is
    $ bosh -e vbox -d cf is --ps
    $ bosh -e vbox -d cf is --ps --vitals
    ```

- <a id="manifest"></a> `bosh -e my-env -d my-dep manifest` (Alias: `man`)

    Prints deployment manifest to `stdout`.

    ```shell
    $ bosh -e vbox -d cf man > /tmp/manifest.yml
    ```

- <a id="recreate"></a> `bosh -e my-env -d my-dep recreate [group[/instance-id]] [--skip-drain] [--fix] [--canaries=] [--max-in-flight=] [--dry-run]`

    Recreates VMs for specified instances. Follows typical instance lifecycle.

    - `--skip-drain` flag skips running drain scripts
    - `--fix` flag replaces unresponsive VMs
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`
    - `--dry-run` flag runs through as many operations without altering deployment

    ```shell
    $ bosh -e vbox -d cf recreate
    $ bosh -e vbox -d cf recreate --fix
    $ bosh -e vbox -d cf recreate diego-cell
    $ bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    $ bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --skip-drain
    $ bosh -e vbox -d cf recreate diego-cell --canaries=0 --max-in-flight=100%
    ```

- <a id="restart"></a> `bosh -e my-env -d my-dep restart [group[/instance-id]] [--skip-drain] [--canaries=] [--max-in-flight=]`

    Restarts jobs (processes) on specified instances. Does not affect VM state.

    - `--skip-drain` flag skips running drain scripts
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

- <a id="start"></a> `bosh -e my-env -d my-dep start [group[/instance-id]] [--canaries=] [--max-in-flight=]`

    Starts jobs (processes) on specified instances. Does not affect VM state.

    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

- <a id="stop"></a> `bosh -e my-env -d my-dep stop [group[/instance-id]] [--skip-drain] [--canaries=] [--max-in-flight=]`

    Stops jobs (processes) on specified instances. Does not affect VM state unless `--hard` flag is specified.

    - `--hard` flag forces VM deletion (keeping persistent disk)
    - `--skip-drain` flag skips running drain scripts
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

- <a id="ignore"></a> `bosh -e my-env -d my-dep ignore group/instance-id`

    Ignores instance from being affected by other commands such as `bosh deploy`.

- <a id="unignore"></a> `bosh -e my-env -d my-dep unignore group/instance-id`

    Unignores instance from being affected by other commands such as `bosh deploy`.

- <a id="logs"></a> `bosh -e my-env -d my-dep logs [group[/instance-id]] [--follow] ...`

    Downloads logs from one or more instances.

    - `--dir=` flag specifies destination directory
    - `--job=` flag includes only specific jobs logs
    - `--only=` flag filters logs (comma-separated)
    - `--agent` flag includes only BOSH Agent logs

    Additional flags for following logs via SSH:

    - `--follow` (`-f`) flag to turn on log following
    - `--num` flag shows last number of lines immediately
    - `--quiet` (`-q`) flag suppresses printing of headers when multiple files are examined
    - `--gw-*` flags allow to configure SSH gateway configuration

    See [Location and use of logs](job-logs.md) for details.

    ```shell
    $ bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    $ bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --job=rep --job=silkd
    $ bosh -e vbox -d cf logs -f
    $ bosh -e vbox -d cf logs -f --num=1000
    ```

- <a id="events"></a> `bosh -e my-env [-d my-dep] events [--* ...]`

    Lists events.

    See [Events](events.md) for details.

    - `--before-id=` flag shows events with ID less than the given ID
    - `--before=` flag shows events before the given timestamp (ex: 2016-05-08 17:26:32)
    - `--after=` flag shows events after the given timestamp (ex: 2016-05-08 17:26:32)
    - `--task=` flag shows events with the given task ID
    - `--instance=` flag shows events with given instance
    - `--event-user=` flag shows events with given user
    - `--action=` flag shows events with given action
    - `--object-type=` flag shows events with given object type
    - `--object-id=` flag shows events with given object ID

    ```shell
    $ bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    $ bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --task 281
    $ bosh -e vbox events -d my-dep
    $ bosh -e vbox events --before-id=1298284
    $ bosh -e vbox events --before="2016-05-08 17:26:32 UTC" --after="2016-05-07 UTC"
    ```

- <a id="event"></a> `bosh -e my-env event id`

    Shows single event details.

- <a id="variables"></a> `bosh -e my-env -d my-dep variables` (Alias: `vars`)

    List variables referenced by the deployment.

---
### VMs <a id="vm-mgmt"></a>

- <a id="vms"></a> `bosh -e my-env [-d my-dep] vms [--vitals]`

    Lists all VMs managed by the Director or VMs in a single deployment. Show instance names, IPs and VM CIDs.

    `--vitals` flag shows basic VM usage such RAM, CPU and disk.

    ```shell
    $ bosh -e vbox vms
    $ bosh -e vbox -d cf vms
    $ bosh -e vbox -d cf vms --vitals
    ```

- <a id="delete-vm"></a> `bosh -e my-env -d my-dep delete-vm cid`

    Deletes VM without going through typical instance lifecycle. Clears out VM reference from a Director database if referenced by any instance.

    ```shell
    $ bosh -e vbox -d cf delete-vm i-fs384238fjwjf8
    ```

---
### Disks <a id="disk-mgmt"></a>

- <a id="disks"></a> `bosh -e my-env -d my-dep disks [--orphaned]`

    Lists disks. Currently only supports `--orphaned` flag.

- <a id="attach-disk"></a> `bosh -e my-env -d my-dep attach-disk group/instance-id disk-cid`

    Attaches disk to an instance, replacing currently attached disk (if any).

    ```shell
    $ bosh -e vbox -d cf attach-disk postgres/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 vol-shw8f293f2f2
    ```

- <a id="delete-disk"></a> `bosh -e my-env -d my-dep delete-disk cid`

    Deletes orphaned disk.

    ```shell
    $ bosh -e vbox -d cf delete-disk vol-shw8f293f2f2
    ```

---
### SSH <a id="ssh-mgmt"></a>

- <a id="ssh"></a> `bosh -e my-env -d my-dep ssh [destination] [-r] [-c=cmd] [--opts=opts] [--gw-* ...]`

    SSH into one or more instances.

    - `--opts` flag allows operator to pass through options to `ssh`; useful for port forwarding
    - `--gw-*` flags allows configuration of SSH gateway

    ```shell
    # execute command on all instances in a deployment
    $ bosh -e vbox -d cf ssh -c 'uptime'

    # execute command on one instance group
    $ bosh -e vbox -d cf ssh diego-cell -c 'uptime'

    # execute command on a single instance
    $ bosh -e vbox -d cf ssh diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 -c 'uptime'

    # execute command with passwordless sudo
    $ bosh -e vbox -d cf ssh diego-cell -c 'sudo lsof -i|grep LISTEN'

    # present output in a table by instance
    $ bosh -e vbox -d cf ssh -c 'uptime' -r

    # port forward UAA port locally
    $ bosh -e vbox -d cf ssh uaa/0 --opts ' -L 8080:localhost:8080'
    ```

- <a id="scp"></a> `bosh -e my-env -d my-dep scp src/dst:[file] src/dst:[file] [-r] [--gw-* ...]`

    SCP to/from one or more instances.

    - `--recursive` (`-r`) flag allow to copy directory recursively
    - `--gw-*` flags allow to configure gateway configuration

    ```shell
    # copy file from this machine to machines a deployment
    $ bosh -e vbox -d cf scp ~/Downloads/script.sh :/tmp/script.sh
    $ bosh -e vbox -d cf scp ~/Downloads/script.sh diego-cell:/tmp/script.sh
    $ bosh -e vbox -d cf scp ~/Downloads/script.sh diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0:/tmp/script.sh
    $ bosh -e vbox -d cf scp ~/Downloads/script.ps1 windows_diego_cell:c:/temp/script/script.ps1

    # copy file from remote machines in a deployment to this machine
    $ bosh -e vbox -d cf scp :/tmp/script.sh ~/Downloads/script.sh
    $ bosh -e vbox -d cf scp diego-cell:/tmp/script.sh ~/Downloads/script.sh
    $ bosh -e vbox -d cf scp diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0:/tmp/script.sh ~/Downloads/script.sh
    $ bosh -e vbox -d cf scp windows_diego_cell:c:/temp/script/script.ps1:~/Downloads/script.ps1

    # copy files from each instance into instance specific local directory
    $ bosh -e vbox -d cf scp diego-cell:/tmp/logs/ /tmp/logs/((instance_id))
    ```

---
### Errands <a id="errand-mgmt"></a>

- <a id="errands"></a> `bosh -e my-env -d my-dep errands` (Alias: `es`)

    Lists all errands defined by the deployment.

    ```shell
    $ bosh -e vbox -d cf es
    Using environment '192.168.56.6' as '?'

    Using deployment 'cf'

    Name
    smoke-tests

    1 errands

    Succeeded
    ```

- <a id="run-errand"></a> `bosh -e my-env -d my-dep run-errand name [--keep-alive] [--when-changed] [--download-logs] [--logs-dir=dir] [--instance=instance-group/instance-id]`

    Runs errand job by name.

    - `--keep-alive` flag keeps VM around where errand was executing
    - `--when-changed` flag indicates whether to skip running an errand if it previously ran (successfully finished) and errand job configuration did not change
    - `--download-logs` flag indicates whether to download full errand logs to a directory specified by `--logs-dir` (defaults to the current directory)
    - `--instance=` flag select which instances to use for errand execution (v2.0.31+)

    See [Errands](errands.md) for details.

    ```shell
    $ bosh -e vbox -d cf run-errand smoke-tests
    $ bosh -e vbox -d cf run-errand smoke-tests --keep-alive
    $ bosh -e vbox -d cf run-errand smoke-tests --when-changed

    # execute errand on all instances that have colocated status errand
    $ bosh -e vbox -d zookeeper run-errand status

    # execute errand on one instance
    $ bosh -e vbox -d zookeeper run-errand status --instance zookeeper/3e977542-d53e-4630-bc40-72011f853cb5

    # execute errand on one instance within an instance group
    # (note that select instance may not necessarily be first based on its index)
    $ bosh -e vbox -d zookeeper run-errand status --instance zookeeper/first

    # execute errand on all instance in an instance group
    $ bosh -e vbox -d zookeeper run-errand status --instance zookeeper

    # execute errand on two instances
    $ bosh -e vbox -d zookeeper run-errand status \
      --instance zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc \
      --instance zookeeper/3e977542-d53e-4630-bc40-72011f853cb5
    ```

---
### Tasks <a id="task-mgmt"></a>

- <a id="tasks"></a> `bosh -e my-env tasks [--recent[=num]] [--all]` (Alias: `ts`)

    Lists active and previously ran tasks.

    - `--deployment` (`-d`) flag filters tasks by a deployment

    ```shell
    # currently active tasks
    $ bosh -e vbox ts

    # currently active tasks for my-dep deployment
    $ bosh -e vbox -d my-dep ts
    Using environment '192.168.56.6' as '?'

    #   State  Started At                    Last Activity At              User   Deployment   Description                   Result

    27  done   Thu Feb 16 19:16:15 UTC 2017  Thu Feb 16 19:20:33 UTC 2017  admin  cockroachdb  create deployment             /deployments/cockroachdb
    26  done   Thu Feb 16 18:54:32 UTC 2017  Thu Feb 16 18:55:27 UTC 2017  admin  cockroachdb  delete deployment cockroachd  /deployments/cockroachdb
    ...

    110 tasks

    Succeeded

    # show last 30 tasks
    $ bosh -e vbox ts -r --all

    # show last 1000 tasks
    $ bosh -e vbox ts -r=1000
    ```

- <a id="task"></a> `bosh -e my-env task id [--debug] [--result] [--event] [--cpi]` (Alias: `t`)

    Shows single task details. Continues to follow task if it did not finish. `Ctrl^C` does not cancel task.

    ```shell
    $ bosh -e vbox t 281
    $ bosh -e vbox t 281 --debug
    ```

- <a id="cancel-task"></a> `bosh -e my-env cancel-task id` (Alias: `ct`)

    Cancel task at its next checkpoint. Does not wait until task is cancelled.

    ```shell
    $ bosh -e vbox ct 281
    ```

---
### Snapshots <a id="snapshot-mgmt"></a>

- <a id="snapshots"></a> `bosh -e my-env -d my-dep snapshots`

    Lists disk snapshots for given deployment.

- <a id="take-snapshot"></a> `bosh -e my-env -d my-dep take-snapshot [group/instance-id]`

    Takes snapshot for an instance or an entire deployment.

- <a id="delete-snapshot"></a> `bosh -e my-env -d my-dep delete-snapshot cid`

    Deletes snapshot.

    ```shell
    $ bosh -e vbox -d cf delete-snapshot snap-shw38ty83f2f2
    ```

- <a id="delete-snapshots"></a> `bosh -e my-env -d my-dep delete-snapshots`

    Deletes snapshots for an entire deployment.

---
### Deployment recovery <a id="deployment-recovery"></a>

- <a id="update-resurrection"></a> `bosh -e my-env update-resurrection on/off`

    Enables or disables resurrection globally. This state is not reflected in the `bosh instances` command's `Resurrection` column.

    See [Automatic repair with Resurrector](resurrector.md) for details.

- <a id="cloud-check"></a> `bosh -e my-env -d my-dep cloud-check [--report] [--auto]` (Alias: `cck`)

    Checks for resource consistency and allows interactive repair.

    See [Manual repair with Cloud Check](cck.md) for details.

- <a id="locks"></a> `bosh -e my-env locks`

    Lists current locks.

---
### Misc <a id="misc"></a>

- <a id="clean-up"></a> `bosh -e my-env clean-up [--all]`

    Cleans up releases, stemcells, orphaned disks, and other unused resources.

    - `--all` flag forces cleanup for orphaned disks

- <a id="help"></a> `bosh help`

    Shows list of available commands and global options. Consider using `-h` flag for individual commands.

- <a id="interpolate"></a> `bosh interpolate manifest.yml [-v ...] [-o ...] [--vars-store path] [--path op-path]` (Alias: `int`)

    Interpolates variables into a manifest sending result to stdout. [Operation files](cli-ops-files.md) and [variables](cli-int.md) can be provided to adjust and fill in manifest before doing a deploy.

    `--path` flag can be used to extract portion of a YAML document.

    ```shell
    $ bosh int bosh-deployment/bosh.yml \
      --vars-store ./creds.yml \
      -o bosh-deployment/virtualbox/cpi.yml \
      -o bosh-deployment/virtualbox/outbound-network.yml \
      -o bosh-deployment/bosh-lite.yml \
      -o bosh-deployment/jumpbox-user.yml \
      -v director_name=vbox \
      -v internal_ip=192.168.56.6 \
      -v internal_gw=192.168.56.1 \
      -v internal_cidr=192.168.56.0/24 \
      -v network_name=vboxnet0 \
      -v outbound_network_name=NatNetwork

    $ bosh int creds.yml --path /admin_password
    skh32i7rdfji4387hg

    $ bosh int creds.yml --path /director_ssl/ca
    -----BEGIN CERTIFICATE-----
    ...
    ```

    Command can be used in a generic way to generate CA and leaf certificates.

    ```yaml
    variables:
    - name: default_ca
      type: certificate
      options:
        common_name: ca
    - name: service_ssl
      type: certificate
      options:
        ca: default_ca
        common_name: ((internal_ip))
        alternative_names: [((internal_ip))]
    ```

    ```shell
    $ bosh interpolate certs-tpl.yml -v internal_ip=1.2.3.4 --vars-store certs.yml --var-errs
    $ bosh interpolate certs.yml --path /service_ssl/ca
    $ bosh interpolate certs.yml --path /service_ssl/certificate
    $ bosh interpolate certs.yml --path /service_ssl/private_key
    ```

---
Next: [Differences between CLI v2 vs v1](cli-v2-diff.md)
