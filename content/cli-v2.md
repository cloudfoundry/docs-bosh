!!! note
    Applies to CLI v3.0.1+.

Installation of the BOSH CLI is required as a prerequisite, see [Installing the CLI](cli-v2-install.md).
Release notes can be found [on Github](https://github.com/cloudfoundry/bosh-cli/releases).

---
### Environments {: #env-mgmt }

See [Environments](cli-envs.md).

#### Environments {: #environments }

- `bosh environments` (Alias: `envs`)

    Lists aliased environments known to the CLI. Aliasing is done via `alias-env` command.

    ```shell
    bosh envs
    ```

    Should result in:

    ```text
    URL              Alias
    104.154.171.255  gcp
    192.168.56.6     vbox

    2 environments

    Succeeded
    ```

#### Create-Env {: #create-env }

- `bosh create-env manifest.yml [--state path] [-v ...] [-o ...] [--vars-store path]`

    Creates single VM based on the manifest. Typically used to create a Director environment. [Operation files](cli-ops-files.md) and [variables](cli-int.md) can be provided to adjust and fill in manifest before doing a deploy.

    `create-env` command replaces `bosh-init deploy` CLI command.

    ```shell
    bosh create-env ~/workspace/bosh-deployment/bosh.yml \
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

#### Alias-Env {: #alias-env }

- `bosh alias-env name -e location [--ca-cert=path]`

    Assigns a name to the created environment for easier access in subsequent CLI commands. Instead of specifying Director location and possibly a CA certificate, subsequent commands can just take given name via `--environment` flag (`-e`).

    ```shell
    bosh alias-env gcp -e bosh.corp.com
    bosh alias-env gcp -e 10.0.0.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca)
    ```

#### Unalias-Env {: #unalias-env }

- `bosh unalias-env ENV-NAME`

    Remove an aliased environment. You can get list of aliases from `bosh envs`

    ```shell
    bosh unalias-env vbox
    ```

#### Environment {: #environment }

- `bosh -e location environment` (Alias: `env`)

    Shows Director information in the deployment environment.

    ```shell
    bosh -e vbox env
    ```

    Should result in:

    ```text
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

#### Delete-Env {: #delete-env }

- `bosh delete-env manifest.yml [--state path] [-v ...] [-o ...] [--vars-store path]`

    Deletes previously created VM based on the manifest. Same flags provided to `create-env` command should be given to the `delete-env` command.

    `delete-env` command replaces `bosh-init delete` CLI command.

    ```shell
    bosh delete-env ~/workspace/bosh-deployment/bosh.yml \
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
### Session {: #session-mgmt }

#### Log-In {: #log-in }

- `bosh log-in` (Alias: `l`, `login`)

    Logs in given user into the Director.

    This command can only be used interactively. If non-interactive use is necessary (for example in scripts) please set `BOSH_CLIENT` and `BOSH_CLIENT_SECRET` environment variables instead of using this command.

    ```shell
    bosh -e my-env l
    # User (): admin
    # Password ():
    ```

    !!! warning
        For **UAA users**, the flags `--client`, `--client-secret` and the environment variables `BOSH_CLIENT` and `BOSH_CLIENT_SECRET` are not supported, and will not be forwarded to UAA. The only supported login flow for UAA is by using an interactive login. Alternatively UAA users can use UAA clients to login.

#### Log-Out {: #log-out }

- `bosh log-out` (Alias: `logout`)

    Logs out currently logged in user.

---
### Director Environment {: #director-env}

- `bosh -e location environment` (Alias: `env`)

    Shows Director information in the deployment environment.

    ```shell
    bosh -e vbox env
    ```

    Should result in:

    ```text
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

- `bosh -e location environment --details`

    Shows Director information in the deployment environment, including information on the Director's certificates expiry dates.

    ```shell
    bosh -e vbox env --details
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    Name      vbox
    UUID      eeb27cc6-467e-4c1d-a8f9-f1a8de759f52
    Version   260.5.0 (00000000)
    CPI       warden_cpi
    Features  compiled_package_cache: disabled
              dns: disabled
              snapshots: disabled
    User      admin


    CERTIFICATE EXPIRY DATE INFORMATION

    Certificate                     Expiry Date (UTC)     Days Left
    director.ssl.cert               2018-12-04T21:43:57Z  0
    blobstore.tls.cert.ca           2019-11-21T21:44:03Z  352
    nats.tls.ca                     2019-11-21T21:43:58Z  352
    nats.tls.client_ca.certificate  2018-12-21T21:43:58Z  17
    nats.tls.director.certificate   2018-11-21T21:43:59Z  -13

    Succeeded
    ```
    The `Days left` column is has a visual shortcut that lists certificates with less than 30 full days of validity in _red_, and all others in _green_.

---
### Stemcells {: #stemcell-mgmt }

See [Uploading Stemcells](uploading-stemcells.md).

#### Stemcells {: #stemcells }

- `bosh -e my-env stemcells` (Alias: `ss`)

    Lists stemcells previously uploaded into the Director. Shows their names, versions and CIDs.

    ```shell
    bosh -e my-env ss
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    Name                                         Version  OS             CPI  CID
    bosh-warden-boshlite-ubuntu-trusty-go_agent  3363*    ubuntu-trusty  -    6cbb176a-6a43-42...
    ~                                            3312     ubuntu-trusty  -    43r3496a-4rt3-52...
    bosh-warden-boshlite-centos-7-go_agent       3363*    centos-7       -    38yr83gg-349r-94...

    (*) Currently deployed

    3 stemcells

    Succeeded
    ```

#### Upload-Stemcell {: #upload-stemcell }

- `bosh -e my-env upload-stemcell location [--sha1=digest] [--fix]` (Alias: `us`)

    Uploads stemcell to the Director. Succeeds even if stemcell is already imported.

    Stemcell location may be local file system path or an HTTP/HTTPS URL.

    `--fix` flag allows operator to replace previously uploaded stemcell with the same name and version to repair stemcells that might have been corrupted in the cloud.

    ```shell
    bosh -e my-env us ~/Downloads/bosh-stemcell-3468.17-warden-boshlite-ubuntu-trusty-go_agent.tgz
    bosh -e my-env us https://bosh.io/d/stemcells/bosh-stemcell-warden-boshlite-ubuntu-trusty-go_agent?v=3468.17
    ```

#### Delete-Stemcell {: #delete-stemcell }

- `bosh -e my-env delete-stemcell name/version`

    Deletes uploaded stemcell from the Director. Succeeds even if stemcell is not found.

    ```shell
    bosh -e my-env delete-stemcell bosh-warden-boshlite-ubuntu-trusty-go_agent/3468.17
    ```

#### Repack-Stemcell {: #repack-stemcell }

- `bosh repack-stemcell src.tgz dst.tgz [--name=name] [--version=ver] [--cloud-properties=json-string]`

    !!! warning
        Starting in version CLI v5.4.0, repacking a stemcell will preserve a new field `api_version` in the manifest. Repacking any stemcells with `api_version` in their manifest with CLI v5.3.1 and lower will omit the field.

    Produces new stemcell tarball with updated properties such as name, version, and cloud properties.

    See [Repacking stemcells](repack-stemcell.md) for details.

#### Inspect-Local-Stemcell {: #inspect-local-stemcell}

- `bosh inspect-local-stemcell PATH`

    Display information from stemcell metadata.

    ```shell
    bosh inspect-local-stemcell /path/to/bosh-stemcell-170.5-aws-xen-hvm-ubuntu-xenial-go_agent.tgz
    ```

---
### Release creation {: #release-creation }

#### Init-Release {: #init-release }

- `bosh init-release [--git] [--dir=dir]`

    Creates an empty release skeleton for a release in `dir`. By default `dir` is the current directory.

    `--git` flag initializes release skeleton as a Git repository, adding appropriate `.gitignore` file.

    ```shell
    bosh init-release --git --dir release-dir
    cd release-dir
    ```

#### Generate-Job {: #generate-job }

- `bosh generate-job name [--dir=dir]`

    Creates an empty job skeleton for a release in `dir`. Includes bare `spec` and an empty `monit` file.

#### Generate-Package {: #generate-package }

- `bosh generate-package name [--dir=dir]`

    Creates an empty package skeleton for a release in `dir`. Includes bare `spec` and an empty `packaging` file.

#### Vendor-Package {: #vendor-package }

- `bosh vendor-package name src-dir [--dir=dir]` (v2.0.36+)

    Vendors a package from a different release into a release in `dir`. It includes `spec.lock` in the package directory so that CLI will reference specific package by its fingerprint when creating releases.

    See [Package vendoring](package-vendoring.md) for details.

#### Create-Release {: #create-release }

- `bosh create-release [--force] [--version=ver] [--timestamp-version] [--final] [--tarball=path] [--dir=dir]` (Alias: `cr`)

    Creates new version of a release stored in `dir`

    - `--force` flag specifies to ignore uncommitted changes in the release directory; it should only be used when building dev releases
    - `--version` flag allows operator to provide custom release version
    - `--timestamp-version` flag will produce timestamp based dev release version
    - `--tarball` flag specifies destination of a release tarball; if not specified, release tarball will not be produced
    - `--sha2` flag to use SHA256 checksum

    While iterating on a release it's common to run `bosh create-release --force && bosh -e my-env upload-release && bosh -e my-env -d my-dep deploy manifest.yml` command sequence.

    In a CI pipeline it's common to use this command to create a release tarball and pass it into acceptance or end-to-end tests. Once release tarball goes through appropriate tests it can be finalized with a `finalize-release` command and shared with release consumers.

    ```shell
    cd release-dir
    bosh create-release --force
    bosh create-release --timestamp-version
    bosh create-release --version 9+dev.10
    bosh create-release --tarball /tmp/my-release.tgz
    bosh create-release --final
    bosh create-release --version 20 --final
    bosh create-release releases/zookeeper/zookeeper-3.yml --tarball /tmp/my-release.tgz
    ```

#### Finalize-Release {: #finalize-release }

- `bosh finalize-release release.tgz [--force] [--version=ver] [--dir=dir]`

    Records contents of a release tarball in the release repository as a final release with an optionally given version. Once `.final_builds` and `releases` directories are updated, it's strongly recommended to commit your changes to version control.

    Typically this command is used as a final step in the CI pipeline to save the final artifact once it passed appropriate tests.

    ```shell
    cd release-dir
    bosh finalize-release /tmp/my-release.tgz
    bosh finalize-release /tmp/my-release.tgz --version 20
    git commit -am 'Final release 20'
    git push origin master
    ```

    * Note: `finalize-release` does not change the input tarball in any way (i.e. if a `--version` flag is passed, it will not modify the version present in the tarball itself).

#### Reset-Release {: #reset-release }

- `bosh reset-release [--dir=dir]`

    Removes temporary artifacts such as dev releases, blobs, etc. kept in the release directory `dir`.

---
### Release blobs {: #blob-mgmt }

See [Release Blobs](release-blobs.md) for a detailed workflow.

#### Blobs {: #blobs }

- `bosh blobs`

    Lists tracked blobs from `config/blobs.yml`. Shows uploaded and not-yet-uploaded blobs.

    ```shell
    cd release-dir
    bosh blobs
    ```

    Should result in:

    ```text
    Path                               Size     Blobstore ID         Digest
    golang/go1.6.2.linux-amd64.tar.gz  81 MiB   f1833f76-ad8b-4b...  b8318b0...
    stress/stress-1.0.4.tar.gz         187 KiB  (local)              e1533bc...

    2 blobs

    Succeeded
    ```

#### Add-Blob {: #add-blob }

- `bosh add-blob src-path dst-path`

    Starts tracking blob in `config/blobs.yml` for inclusion in packages.

    ```shell
    cd release-dir
    bosh add-blob ~/Downloads/stress-1.0.4.tar.gz stress/stress-1.0.4.tar.gz
    ```
#### Remove-Blob {: #remove-blob }

- `bosh remove-blob blob-path`

    Stops tracking blob in `config/blobs.yml`. Does not remove previously uploaded copies from the blobstore as older release versions may still want to reference it.

    ```shell
    cd release-dir
    bosh remove-blob stress/stress-1.0.4.tar.gz
    ```

#### Upload-Blobs {: #upload-blobs }

- `bosh upload-blobs`

    Uploads previously added blobs that were not yet uploaded to the blobstore. Updates `config/blobs.yml` with returned blobstore IDs. Before creating a final release it's strongly recommended to upload blobs so that other release contributors can rebuild a release from scratch.

    ```shell
    cd release-dir
    bosh upload-blobs
    ```

#### Sync-Blobs {: #sync-blobs }

- `bosh sync-blobs`

    Downloads blobs into `blobs/` based on `config/blobs.yml`.

    ```shell
    cd release-dir
    bosh sync-blobs
    ```

---
### Releases {: #release-mgmt }

See [Uploading Releases](uploading-releases.md).

#### Releases {: #releases }

- `bosh -e my-env releases` (Alias: `rs`)

    Lists releases previously uploaded into the Director. Shows their names and versions.

    ```shell
    bosh -e my-env rs
    ```

    Should result in:

    ```text
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

#### Upload-Release {: #upload-release }

- `bosh -e my-env upload-release [location] [--version=ver] [--sha1=digest] [--fix]` (Alias: `ur`)

    Uploads release to the Director. Succeeds even if release is already imported.

    Release location may be local file system path, HTTP/HTTPS URL or a git URL.

    `--fix` flag allows replacement of previously uploaded release with the same name and version to repair releases that might have been corrupted.

    ```shell
    bosh -e my-env ur
    bosh -e my-env ur https://bosh.io/d/github.com/concourse/concourse?v=2.7.3
    bosh -e my-env ur git+https://github.com/concourse/concourse --version 2.7.3
    ```

#### Delete-Release {: #delete-release }

- `bosh -e my-env delete-release name/version`

    Deletes uploaded release from the Director. Succeeds even if release is not found.

    ```shell
    bosh -e my-env delete-release cf-smoke-tests/94
    ```

#### Export-Release {: #export-release }

- `bosh -e my-env -d my-dep export-release name/version os/version [--dir=dir]`

    Compiles and exports a release against a particular stemcell version.

    Requires to operate with a deployment so that compilation resources (VMs) are properly tracked.

    Destination directory default to the current directory.

    ```shell
    bosh -e my-env -d my-dep export-release cf-smoke-tests/94 ubuntu-trusty/3369
    ```

#### Inspect-Release {: #inspect-release }

- `bosh -e my-env inspect-release name/version`

    Lists all jobs, job metadata (such as links), packages, and compiled packages associated with a release version.

    ```shell
    bosh -e gcp-test inspect-release consul/155
    ```

    Should result in:

    ```text
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

#### Inspect-Local-Release {: #inspect-local-release}

- `bosh inspect-local-release PATH`

    Lists all jobs, packages, and compiled packages associated with a release tarball.

    ```shell
    bosh inspect-local-release bpm-1.0.3-ubuntu-xenial-250.25-20190327-162856-776883319.tgz
    ```

    Should result in:

    ```text
    Name         bpm
    Version      1.0.3
    Commit Hash  d2f7197
    Archive      bpm-1.0.3-ubuntu-xenial-250.25-20190327-162856-776883319.tgz

    Job                                                   Digest                                    Packages
    bpm/fafbd62c034aaf20947ec9c9e7102959ca73db8c          1d17ace7f7cef72554b5fe3106212dd43ed76953  -
    test-errand/1ccf9ec7a47043218a7d080a5d674077bfc28529  ff901be8452289d0590a36eb7823174ae8104c7f  -
    test-server/80db4f3e3ef3ce7301c5a256357dd158df147a70  bee2983cffc928354cc2a48f929ed1c4d42ce59d  -

    3 jobs

    Package                                               Digest                                    Dependencies  OS             OS Version
    bpm-runc/b1010b27bec38acce027b2d1d8a1c10b71bb6f87     2046ffbd400ddf71fd6a01114a37714e0d531ea5  golang        ubuntu-xenial  250.25
    bpm/0c350861f27a4b912fb578bfa88d97d1dafe1602          a9dfddb259c4674138da48b9a538aef6b18ab274  golang        ubuntu-xenial  250.25
    bpm-runc
    golang/4f7fa7648892d4d98b7912c945638c8f32f52d6f       2d1b33e23642b159cf012e83597a7ab63933eaa5  -             ubuntu-xenial  250.25
    test-server/b748494d5c1031c9943e0d7f3982e4b09fce36f5  612a488cf46a32883bee4f0415fdcf83de9ee5ec  golang        ubuntu-xenial  250.25

    4 packages

    Succeeded
    ```

---
### Configs {: #configs-mgmt }

See [Configs](configs.md).

#### Configs {: #configs }

- `bosh -e my-env configs [--type=my-type] [--name=my-name]`

    Lists all the configs on the Director.

    ```shell
    bosh -e my-env configs
    ```

    Should result in:

    ```text
    Using environment '192.168.50.6' as client 'admin'

    Type     Name
    cloud    default
    ~        custom-vm-types
    cpi      default
    runtime  default

    3 configs

    Succeeded
    ```

#### Config {: #config }

- `bosh -e my-env config [id] [--type=my-type] [--name=my-name]`

    Either show config by `id` or by `name` and `type` on the Director.

    ```shell
    bosh -e my-env config --type=my-type --name=my-name
    bosh -e my-env config 5
    ```

#### Update-Config {: #update-config }

- `bosh -e my-env update-config config.yml --type=my-type [--name=my-name]`

    Update config on the Director.

    - `--type` (required) flag allows to specify config type
    - `--name` flag allows to specify custom config name

    ```shell
    bosh -e my-env update-config config.yml --type=cloud
    bosh -e my-env update-config config.yml --type=cloud --name=network1
    ```

#### Delete-Config {: #delete-config }

- `bosh -e my-env delete-config --type=my-type [--name=my-name]`

    Delete config on the Director.

    - `--type` (required) flag allows to specify config type
    - `--name` flag allows to specify custom config name

    ```shell
    bosh -e my-env delete-config --type=my-type
    bosh -e my-env delete-config --type=my-type --name=my-name
    ```

#### Diff-Config {: #diff-config }

- `bosh -e my-env diff-config --type=my-type [--name=my-name]`

    Diff two configs by ID or content.

    - `--from-id` ID of first config to compare
    - `--to-id` ID of second config to compare
    - `--from-content` path to first config file to compare
    - `--to-content` path to second config file to compare

    ```shell
    bosh -e my-env diff-config --from-id=1 --to-id=2
    bosh -e my-env diff-config --from-content=/path/to/file1 --to-content=/path/to/file2
    ```

---
### Cloud config {: #cloud-config-mgmt }

See [Cloud config](cloud-config.md).

#### Cloud-Config {: #cloud-config }

- `bosh -e my-env cloud-config` (Alias: `cc`)

    Show current cloud config on the Director.

#### Update-Cloud-Config {: #update-cloud-config }

- `bosh -e my-env update-cloud-config config.yml [-v ...] [-o ...]` (Alias: `ucc`)

    Update current cloud config on the Director.

    ```shell
    bosh -e my-env ucc cc.yml
    ```

---
### Runtime config {: #runtime-config-mgmt }

See [Runtime config](runtime-config.md).

#### Runtime-Config {: #runtime-config }

- `bosh -e my-env runtime-config` (Alias: `rc`)

    Show current runtime config on the Director.

#### Update-Runtime-Config {: #update-runtime-config }

- `bosh -e my-env update-runtime-config config.yml [-v ...] [-o ...]` (Alias: `urc`)

    Update current runtime config on the Director.

    ```shell
    bosh -e my-env urc runtime.yml
    ```

---
### CPI config {: #cpi-config-mgmt }

See [CPI config](cpi-config.md).

#### CPI-Config {: #cpi-config }

- `bosh -e my-env cpi-config`

    Show current CPI config on the Director.

#### Update-CPI-Config {: #update-cpi-config }

- `bosh -e my-env update-cpi-config config.yml [-v ...] [-o ...]`

    Update current CPI config on the Director.

    ```shell
    bosh -e my-env update-cpi-config cpis.yml
    ```

---
### Deployments {: #deployment-mgmt }

#### Deployments {: #deployments }

- `bosh -e my-env deployments` (Alias: `ds`)

    Lists deployments tracked by the Director. Shows their names, used releases and stemcells.

    ```shell
    bosh -e my-env ds
    ```

    Should result in:

    ```text
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

#### Deployment {: #deployment }

- `bosh -e my-env -d my-dep deployment` (Alias: `dep`)

    Shows general deployment information for a given deployment.

    Can be used to determine if Director has a deployment with a given name.

    ```shell
    bosh -e vbox -d cf dep
    ```

    Should result in:

    ```text
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

#### Deploy {: #deploy }

- `bosh -e my-env -d my-dep deploy manifest.yml [-v ...] [-o ...]`

    Create or update specified deployment according to the provided manifest. Operation files and variables can be provided to adjust and fill in manifest before deploy begins.

    Currently name provided via `--deployment` (`-d`) flag must match name specified in the manifest.

    ```shell
    bosh -e vbox -d cf deploy cf.yml -v system_domain=sys.example.com -o large-footprint.yml
    ```

#### Delete-Deployment {: #delete-deployment }

- `bosh -e my-env -d my-dep delete-deployment [--force]` (Alias: `deld`)

    Deletes specified deployment. If `--force` is provided, ignores variety of errors (from IaaS, blobstore, database) when deleting.

    Note that if you've deleted your deployment, not all resources may have been freed. For example "deleted" persistent disks will be deleted after a few days to avoid accidental data loss. See [Persistent and Orphaned Disks](persistent-disks.md) for more details.

    Succeeds even if deployment is not found.

    ```shell
    bosh -e vbox -d cf deld
    bosh -e vbox -d cf deld --force
    ```

#### Instances {: #instances }

- `bosh -e my-env [-d my-dep] instances [--ps] [--details] [--vitals] [--failing]` (Alias: `is`)

    Lists all instances managed by the Director or in a single deployment. Show instance names, IPs, and VM and process health.

    - `--details` (`-i`) flag includes VM CID, persistent disk CIDs, and other instance level details
    - `--ps` flag includes per process health information
    - `--vitals` flag shows basic VM and process usage such RAM, CPU and disk.
    - `--failing` flag hides all healthy instances and processes leaving only non-healthy ones; useful for scripting

    ```shell
    bosh -e vbox is -i
    bosh -e vbox is --ps --vitals
    bosh -e vbox -d cf is
    bosh -e vbox -d cf is --ps
    bosh -e vbox -d cf is --ps --vitals
    ```

#### Manifest {: #manifest }

- `bosh -e my-env -d my-dep manifest` (Alias: `man`)

    Prints deployment manifest to `stdout`. In case a deployment failed, it will print the manifest of the last succesful deploy.

    ```shell
    bosh -e vbox -d cf man > /tmp/manifest.yml
    ```

#### Recreate {: #recreate }

- `bosh -e my-env -d my-dep recreate [group[/instance-id]] [--skip-drain] [--fix] [--canaries=] [--max-in-flight=] [--dry-run]`

    Recreates VMs for specified instances. Follows typical instance lifecycle.

    - `--skip-drain` flag skips running drain scripts; Also skips pre-stop scripts as of director version v270.0.0
    - `--fix` flag specifies to recover an instance with an unresponsive agent instead of erroring
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`
    - `--dry-run` flag runs through as many operations without altering deployment

    ```shell
    bosh -e vbox -d cf recreate
    bosh -e vbox -d cf recreate --fix
    bosh -e vbox -d cf recreate diego-cell
    bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --skip-drain
    bosh -e vbox -d cf recreate diego-cell --canaries=0 --max-in-flight=100%
    ```
    !!! warning
        In case of a **failed** deployment, running `bosh recreate` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Restart {: #restart }

- `bosh -e my-env -d my-dep restart [group[/instance-id]] [--skip-drain] [--canaries=] [--max-in-flight=]`

    Restarts jobs (processes) on specified instances. Does not affect VM state.

    - `--skip-drain` flag skips running drain scripts; Also skips pre-stop scripts as of director version v270.0.0
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

    !!! warning
        In case of a **failed** deployment, running `bosh restart` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Start {: #start }

- `bosh -e my-env -d my-dep start [group[/instance-id]] [--canaries=] [--max-in-flight=]`

    Starts jobs (processes) on specified instances. Does not affect VM state.

    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

    !!! warning
        In case of a **failed** deployment, running `bosh start` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Stop {: #stop }

- `bosh -e my-env -d my-dep stop [group[/instance-id]] [--skip-drain] [--canaries=] [--max-in-flight=]`

    Stops jobs (processes) on specified instances. Does not affect VM state unless `--hard` flag is specified.

    - `--hard` flag forces VM deletion (keeping persistent disk)
    - `--skip-drain` flag skips running drain scripts; Also skips pre-stop scripts as of director version v270.0.0
    - `--canaries=` flag overrides manifest values for `canaries`
    - `--max-in-flight=` flag overrides manifest values for `max_in_flight`

#### Ignore {: #ignore }

- `bosh -e my-env -d my-dep ignore group/instance-id`

    Ignores instance from being affected by other commands such as `bosh deploy`.

#### Unignore {: #unignore }

- `bosh -e my-env -d my-dep unignore group/instance-id`

    Unignores instance from being affected by other commands such as `bosh deploy`.

#### Logs {: #logs }

- `bosh -e my-env -d my-dep logs [group[/instance-id]] [--follow] ...`

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
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --job=rep --job=silkd
    bosh -e vbox -d cf logs -f
    bosh -e vbox -d cf logs -f --num=1000
    ```

#### Events {: #events }

- `bosh -e my-env [-d my-dep] events [--* ...]`

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
    bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --task 281
    bosh -e vbox events -d my-dep
    bosh -e vbox events --before-id=1298284
    bosh -e vbox events --before="2016-05-08 17:26:32 UTC" --after="2016-05-07 UTC"
    ```

#### Event {: #event }

- `bosh -e my-env event id`

    Shows single event details.

#### Variables {: #variables }

- `bosh -e my-env -d my-dep variables` (Alias: `vars`)

    List variables referenced by the deployment.

---
### VMs {: #vm-mgmt }

#### Vms {: #vms }

- `bosh -e my-env [-d my-dep] vms [--vitals]`

    Lists all VMs managed by the Director or VMs in a single deployment. Show instance names, IPs and VM CIDs.

    `--vitals` flag shows basic VM usage such RAM, CPU and disk.

    ```shell
    bosh -e vbox vms
    bosh -e vbox -d cf vms
    bosh -e vbox -d cf vms --vitals
    ```

#### Delete-Vm {: #delete-vm }

- `bosh -e my-env -d my-dep delete-vm cid`

    Deletes VM without going through typical instance lifecycle. Clears out VM reference from a Director database if referenced by any instance.

    ```shell
    bosh -e vbox -d cf delete-vm i-fs384238fjwjf8
    ```

#### Orphaned-Vms {: #orphaned-vms }

- `bosh -e my-env orphaned-vms`

    List all the orphaned VMs for all deployments.

    ```shell
    bosh -e vbox orphaned-vms
    ```

---
### Disks {: #disk-mgmt }

#### Disks {: #disks }

- `bosh -e my-env -d my-dep disks [--orphaned]`

    Lists disks. Currently only supports `--orphaned` flag.

#### Orphan-Disk {: #orphan-disk }

- `bosh -e my-env orphan-disk DISK-CID`

    Orphans a disk attached to an instance. You can get Disk-CID from `bosh instances --details`.

    ```shell
    bosh -e vbox orphan-disk xxxx-xxxx-xxxx
    ```

#### Attach-Disk {: #attach-disk }

- `bosh -e my-env -d my-dep attach-disk group/instance-id disk-cid`

    Attaches disk to an instance, replacing and orphaning the currently attached disk (if any).

    ```shell
    bosh -e vbox -d cf attach-disk postgres/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 vol-shw8f293f2f2
    ```

#### Delete-Disk {: #delete-disk }

- `bosh -e my-env -d my-dep delete-disk cid`

    Deletes orphaned disk.

    ```shell
    bosh -e vbox -d cf delete-disk vol-shw8f293f2f2
    ```


---
### SSH {: #ssh-mgmt }

#### SSH {: #ssh }

- `bosh -e my-env -d my-dep ssh [destination] [-r] [-c=cmd] [--opts=opts] [--gw-* ...]`

    SSH into one or more instances.

    - `--opts` flag allows operator to pass through options to `ssh`; useful for port forwarding
    - `--gw-*` flags allows configuration of SSH gateway

    ```shell
    # execute command on all instances in a deployment
    bosh -e vbox -d cf ssh -c 'uptime'

    # execute command on one instance group
    bosh -e vbox -d cf ssh diego-cell -c 'uptime'

    # execute command on a single instance
    bosh -e vbox -d cf ssh diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 -c 'uptime'

    # execute command with passwordless sudo
    bosh -e vbox -d cf ssh diego-cell -c 'sudo lsof -i|grep LISTEN'

    # present output in a table by instance
    bosh -e vbox -d cf ssh -c 'uptime' -r

    # port forward UAA port locally
    bosh -e vbox -d cf ssh uaa/0 --opts ' -L 8080:localhost:8080'
    ```

#### SCP {: #scp }

- `bosh -e my-env -d my-dep scp src/dst:[file] src/dst:[file] [-r] [--gw-* ...]`

    SCP to/from one or more instances.

    - `--recursive` (`-r`) flag allow to copy directory recursively
    - `--gw-*` flags allow to configure gateway configuration

    ```shell
    # copy file from this machine to machines a deployment
    bosh -e vbox -d cf scp ~/Downloads/script.sh :/tmp/script.sh
    bosh -e vbox -d cf scp ~/Downloads/script.sh diego-cell:/tmp/script.sh
    bosh -e vbox -d cf scp ~/Downloads/script.sh diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0:/tmp/script.sh
    bosh -e vbox -d cf scp ~/Downloads/script.ps1 windows_diego_cell:c:/temp/script/script.ps1

    # copy file from remote machines in a deployment to this machine
    bosh -e vbox -d cf scp :/tmp/script.sh ~/Downloads/script.sh
    bosh -e vbox -d cf scp diego-cell:/tmp/script.sh ~/Downloads/script.sh
    bosh -e vbox -d cf scp diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0:/tmp/script.sh ~/Downloads/script.sh
    bosh -e vbox -d cf scp windows_diego_cell:c:/temp/script/script.ps1:~/Downloads/script.ps1

    # copy files from each instance into instance specific local directory
    bosh -e vbox -d cf scp diego-cell:/tmp/logs/ /tmp/logs/((instance_id))
    ```

---
### Errands {: #errand-mgmt }

#### Errands {: #errands }

- `bosh -e my-env -d my-dep errands` (Alias: `es`)

    Lists all errands defined by the deployment.

    ```shell
    bosh -e vbox -d cf es
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    Using deployment 'cf'

    Name
    smoke-tests

    1 errands

    Succeeded
    ```

#### Run-Errand {: #run-errand }

- `bosh -e my-env -d my-dep run-errand name [--keep-alive] [--when-changed] [--download-logs] [--logs-dir=dir] [--instance=instance-group/instance-id]`

    Runs errand job by name.

    - `--keep-alive` flag keeps VM around where errand was executing
    - `--when-changed` flag indicates whether to skip running an errand if it previously ran (successfully finished) and errand job configuration did not change
    - `--download-logs` flag indicates whether to download full errand logs to a directory specified by `--logs-dir` (defaults to the current directory)
    - `--instance=` flag select which instances to use for errand execution (v2.0.31+)

    See [Errands](errands.md) for details.

    ```shell
    bosh -e vbox -d cf run-errand smoke-tests
    bosh -e vbox -d cf run-errand smoke-tests --keep-alive
    bosh -e vbox -d cf run-errand smoke-tests --when-changed

    # execute errand on all instances that have colocated status errand
    bosh -e vbox -d zookeeper run-errand status

    # execute errand on one instance
    bosh -e vbox -d zookeeper run-errand status --instance zookeeper/3e977542-d53e-4630-bc40-72011f853cb5

    # execute errand on one instance within an instance group
    # (note that select instance may not necessarily be first based on its index)
    bosh -e vbox -d zookeeper run-errand status --instance zookeeper/first

    # execute errand on all instance in an instance group
    bosh -e vbox -d zookeeper run-errand status --instance zookeeper

    # execute errand on two instances
    bosh -e vbox -d zookeeper run-errand status \
      --instance zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc \
      --instance zookeeper/3e977542-d53e-4630-bc40-72011f853cb5
    ```

---
### Tasks {: #task-mgmt }

#### Tasks {: #tasks }

- `bosh -e my-env tasks [--recent[=num]] [--all]` (Alias: `ts`)

    Lists active and previously ran tasks.

    - `--deployment` (`-d`) flag filters tasks by a deployment

    ```shell
    # currently active tasks
    bosh -e vbox ts

    # currently active tasks for my-dep deployment
    bosh -e vbox -d my-dep ts
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    #   State  Started At                    Last Activity At              User   Deployment   Description                   Result

    27  done   Thu Feb 16 19:16:15 UTC 2017  Thu Feb 16 19:20:33 UTC 2017  admin  cockroachdb  create deployment             /deployments/cockroachdb
    26  done   Thu Feb 16 18:54:32 UTC 2017  Thu Feb 16 18:55:27 UTC 2017  admin  cockroachdb  delete deployment cockroachd  /deployments/cockroachdb
    ...

    110 tasks

    Succeeded
    ```

    ```shell
    # show last 30 tasks
    bosh -e vbox ts -r --all

    # show last 1000 tasks
    bosh -e vbox ts -r=1000
    ```

#### Task {: #task }

- `bosh -e my-env task id [--debug] [--result] [--event] [--cpi]` (Alias: `t`)

    Shows single task details. Continues to follow task if it did not finish. `Ctrl^C` does not cancel task.

    ```shell
    bosh -e vbox t 281
    bosh -e vbox t 281 --debug
    ```

#### Cancel-Task {: #cancel-task }

- `bosh -e my-env cancel-task id` (Alias: `ct`)

    Cancel task at its next checkpoint. Does not wait until task is cancelled.

    ```shell
    bosh -e vbox ct 281
    ```

---
### Snapshots {: #snapshot-mgmt }

#### Snapshots {: #snapshots }

- `bosh -e my-env -d my-dep snapshots`

    Lists disk snapshots for given deployment.

#### Take-Snapshot {: #take-snapshot }

- `bosh -e my-env -d my-dep take-snapshot [group/instance-id]`

    Takes snapshot for an instance or an entire deployment.

#### Delete-Snapshot {: #delete-snapshot }

- `bosh -e my-env -d my-dep delete-snapshot cid`

    Deletes snapshot.

    ```shell
    bosh -e vbox -d cf delete-snapshot snap-shw38ty83f2f2
    ```

#### Delete-Snapshots {: #delete-snapshots }

- `bosh -e my-env -d my-dep delete-snapshots`

    Deletes snapshots for an entire deployment.

---
### Deployment recovery {: #deployment-recovery }

#### Update-Resurrection {: #update-resurrection }

- `bosh -e my-env update-resurrection on/off`

    Enables or disables resurrection globally. This state is not reflected in the `bosh instances` command's `Resurrection` column.

    See [Automatic repair with Resurrector](resurrector.md) for details.

#### Cloud-Check {: #cloud-check }

- `bosh -e my-env -d my-dep cloud-check [--report] [--auto]` (Alias: `cck`)

    Checks for resource consistency and allows interactive repair.

    See [Manual repair with Cloud Check](cck.md) for details.

#### Locks {: #locks }

- `bosh -e my-env locks`

    Lists current locks.

---
### Network {: #network}

#### Networks {: #networks }

- `bosh -e my-env networks`

    List networks created by deployments.

    ```shell
    bosh -e vbox networks
    ```

#### Delete-Network {: #delete-network}

- `bosh -e my-env delete-network NETWORK-NAME`

    Deletes a network created during deployment. Check [CPI methods](https://bosh.io/docs/cpi-api-v1-method/create-network/#create_network) for more details

    ```shell
    bosh -e vbox delete-network network-name
    ```

---
### Misc {: #misc }

#### Clean-Up {: #clean-up }

- `bosh -e my-env clean-up [--all]`

    Cleans up unused resources but keeps orphaned disks and the two most recent versions of stemcells and releases.

    - `--all` flag cleans up all unused resources including orphaned disks.

    Note that orphan disks get deleted after a few days by default. See [Orphan Disks](persistent-disks.md#orphaned-disks) for more details.


#### Help {: #help }

- `bosh help`

    Shows list of available commands and global options. Consider using `-h` flag for individual commands.

#### Interpolate Variables {: #interpolate }

- `bosh interpolate manifest.yml [-v ...] [-o ...] [--vars-store path] [--path op-path]` (Alias: `int`)

    Interpolates variables into a manifest sending result to stdout. [Operation files](cli-ops-files.md) and [variables](cli-int.md) can be provided to adjust and fill in manifest before doing a deploy.

    `--path` flag can be used to extract portion of a YAML document.

    ```shell
    bosh int bosh-deployment/bosh.yml \
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

    bosh int creds.yml --path /admin_password
    # skh32i7rdfji4387hg

    bosh int creds.yml --path /director_ssl/ca
    # -----BEGIN CERTIFICATE-----
    # ...
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
    bosh interpolate certs-tpl.yml -v internal_ip=1.2.3.4 --vars-store certs.yml --var-errs
    bosh interpolate certs.yml --path /service_ssl/ca
    bosh interpolate certs.yml --path /service_ssl/certificate
    bosh interpolate certs.yml --path /service_ssl/private_key
    ```

#### HTTP Request {: #curl }

- `bosh curl [--method=HTTP-METHOD] [--header=HTTP-HEADER] [--body=PATH-TO-FILE-WITH-HTTP-REQUEST-BODY] [--show-headers]`

    Make an HTTP request to the BOSH Director. **Recommended to be used for debugging purposes only**.

    - `--method` `(-X)` flag specifies the HTTP method. Allowed values: `GET`, `POST`, `PUT`, and `DELETE`. Defaults to `GET`
    - `--header` `(-H)` flag allows adding an HTTP header to the request in `'name: value'` format. Can be specified multiple times for multiple headers.
    - `--body` flag is the path to the file containing the HTTP request body (for `POST` and `PUT`)
    - `--show-headers` `(-i)` flag shows HTTP headers in the response


```shell
bosh curl /deployments
bosh curl /links?deployment=my-dep
bosh curl -H 'Content-Type: application/json' --body ./request-body.txt --method=POST /links
```
