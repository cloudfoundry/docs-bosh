!!! note
    Applies to CLI v3.0.1+.

Installation of the BOSH CLI is required as a prerequisite, see [Installing the CLI](cli-v2-install.md).
Release notes can be found [on Github](https://github.com/cloudfoundry/bosh-cli/releases).

---
## Global BOSH CLI Application options

These options are available to every command execution:

- `-v`, `--version` Show CLI version
- `--config=PATH` Config file path (default: ~/.bosh/config) [$BOSH_CONFIG]
- `-e`, `--environment=NAME` Director environment name or URL [$BOSH_ENVIRONMENT]
- `--ca-cert=PATH` Director CA certificate path or value [$BOSH_CA_CERT]
- `--sha2` Use SHA256 checksums [$BOSH_SHA2]
- `--parallel=NUMBER` The max number of parallel operations (default: 5)
- `--client=NAME` Override username or UAA client [$BOSH_CLIENT]
- `--client-secret=SECRET` Override password or UAA client secret [$BOSH_CLIENT_SECRET]
- `-d`, `--deployment=NAME` Deployment name [$BOSH_DEPLOYMENT]
- `--column=NAME` Filter to show only given column(s)
- `--json` Output as JSON
- `--tty` Force TTY-like output
- `--no-color` Toggle colorized output
- `-n`, `--non-interactive` Don't ask for user input [$BOSH_NON_INTERACTIVE]
- `-h`, `--help` Show help message

### Environments {: #env-mgmt }

See [Environments](cli-envs.md).

#### Environments {: #environments }

- `bosh [GLOBAL-CLI-OPTIONS] environments` (Alias: `envs`)

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

- `bosh [GLOBAL-CLI-OPTIONS] create-env [-v ...] [--var-file=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--skip-drain] [--state=PATH] [--recreate] [--recreate-persistent-disks] PATH`

    Creates single VM based on the manifest. Typically used to create a Director environment. [Operation files](cli-ops-files.md) and [variables](cli-int.md) can be provided to adjust and fill in manifest before doing a deploy.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--skip-drain` Skip running drain and pre-stop scripts
    - `--state=PATH` State file path
    - `--recreate` Recreate VM in deployment
    - `--recreate-persistent-disks` Recreate persistent disks in the deployment
    - `PATH` Path to a manifest file

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

- `bosh [GLOBAL-CLI-OPTIONS] alias-env name -e location`

    Assigns a name to the created environment for easier access in subsequent CLI commands. Instead of specifying Director location and possibly a CA certificate, subsequent commands can just take given name via `--environment` flag (`-e`).

    ```shell
    bosh alias-env gcp -e bosh.corp.com
    bosh alias-env gcp -e 10.0.0.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca)
    ```

#### Unalias-Env {: #unalias-env }

- `bosh [GLOBAL-CLI-OPTIONS] unalias-env ALIAS`

    Remove an aliased environment. You can get list of aliases from `bosh envs`

    ```shell
    bosh unalias-env vbox
    ```

#### Delete-Env {: #delete-env }

- `bosh [GLOBAL-CLI-OPTIONS] delete-env [-v ...] [--var-file=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--skip-drain] [--state=PATH] PATH`

    Deletes previously created VM based on the manifest. Same flags provided to `create-env` command should be given to the `delete-env` command.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--skip-drain` Skip running drain and pre-stop scripts
    - `--state=PATH` State file path
    - `PATH` Path to a manifest file

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

- `bosh [GLOBAL-CLI-OPTIONS] log-in` (Alias: `l`, `login`)

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

- `bosh [GLOBAL-CLI-OPTIONS] log-out` (Alias: `logout`)

    Logs out currently logged in user.

---
### Director Environment {: #director-env}

#### Environment {: #environment }
- `bosh [GLOBAL-CLI-OPTIONS] environment [--details]` (Alias: `env`)

    Shows Director information in the deployment environment.

    - `--details` Show director's certificates details

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
    Features  dns: disabled
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

- `bosh [GLOBAL-CLI-OPTIONS] stemcells` (Alias: `ss`)

    Lists stemcells previously uploaded into the Director. Shows their names, versions and CIDs.

    ```shell
    bosh -e my-env ss
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    Name                                         Version    OS             CPI  CID
    bosh-warden-boshlite-ubuntu-xenial-go_agent  621.74*    ubuntu-xenial  -    6cbb176a-6a43-42...
    ~                                            456.112    ubuntu-xenial  -    43r3496a-4rt3-52...
    bosh-warden-boshlite-centos-7-go_agent       3363*      centos-7       -    38yr83gg-349r-94...

    (*) Currently deployed

    3 stemcells

    Succeeded
    ```

#### Upload-Stemcell {: #upload-stemcell }

- `bosh [GLOBAL-CLI-OPTIONS] upload-stemcell [--fix] [--name=NAME] [--version=VERSION] [--sha1=DIGEST] URL` (Alias: `us`)

    Uploads stemcell to the Director. Succeeds even if stemcell is already imported.

    Stemcell location may be local file system path or an HTTP/HTTPS URL.

    - `--fix` replace previously uploaded stemcell with the same name and version to repair stemcells that might have been corrupted in the cloud.
    - `--name=NAME` Name used in existence check (is not used with local stemcell file)
    - `--version=VERSION` Version used in existence check (is not used with local stemcell file)
    - `--sha1=DIGEST` SHA1 of the remote stemcell (is not used with local files)
    - `URL` Path to a local file or URL


    ```shell
    bosh -e my-env us ~/Downloads/bosh-stemcell-621.74-warden-boshlite-ubuntu-xenial-go_agent.tgz
    bosh -e my-env us https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=621.74
    ```

#### Delete-Stemcell {: #delete-stemcell }

- `bosh [GLOBAL-CLI-OPTIONS] delete-stemcell [GLOBAL-CLI-OPTIONS] [--force] NAME/VERSION`

    Deletes uploaded stemcell from the Director. Succeeds even if stemcell is not found.

    - `--force` Ignore errors

    ```shell
    bosh -e my-env delete-stemcell bosh-warden-boshlite-ubuntu-xenial-go_agent/621.74
    ```

#### Repack-Stemcell {: #repack-stemcell }

- `bosh [GLOBAL-CLI-OPTIONS] repack-stemcell [--name=NAME] [--cloud-properties=JSON-STRING] [--empty-image] [--format=FORMAT] [--version=VERSION] PATH-TO-STEMCELL PATH-TO-RESULT`

    !!! warning
        Starting in version CLI v5.4.0, repacking a stemcell will preserve a new field `api_version` in the manifest. Repacking any stemcells with `api_version` in their manifest with CLI v5.3.1 and lower will omit the field.

    Produces new stemcell tarball with updated properties such as name, version, and cloud properties.

    - `--name=NAME` Repacked stemcell name
    - `--cloud-properties=JSON-STRING` Repacked stemcell cloud properties
    - `--empty-image` Pack zero byte file instead of image
    - `--format=FORMAT` Repacked stemcell formats. Can be used multiple times. Overrides existing formats.
    - `--version=VERSION` Repacked stemcell version
    - `PATH-TO-STEMCELL` Path to stemcell
    - `PATH-TO-RESULT` Path to repacked stemcell

    See [Repacking stemcells](repack-stemcell.md) for details.

#### Inspect-Local-Stemcell {: #inspect-local-stemcell}

- `bosh [GLOBAL-CLI-OPTIONS] inspect-local-stemcell PATH-TO-STEMCELL`

    Display information from stemcell metadata.

    ```shell
    bosh inspect-local-stemcell /path/to/bosh-stemcell-170.5-aws-xen-hvm-ubuntu-xenial-go_agent.tgz
    ```

---
### Release creation {: #release-creation }

#### Init-Release {: #init-release }

- `bosh [GLOBAL-CLI-OPTIONS] init-release [--dir=DIR] [--git]`

    Creates an empty release skeleton for a release in `dir`. By default `dir` is the current directory.

    - `--dir=DIR` Release directory path if not current working directory (default: .)
    - `--git` initialize release skeleton as a Git repository, adding appropriate `.gitignore` file.

    ```shell
    bosh init-release --git --dir release-dir
    cd release-dir
    ```

#### Generate-Job {: #generate-job }

- `bosh [GLOBAL-CLI-OPTIONS] generate-job [--dir=DIR] NAME`

    Creates an empty job skeleton for a release in `dir`. Includes bare `spec` and an empty `monit` file.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

#### Generate-Package {: #generate-package }

- `bosh [GLOBAL-CLI-OPTIONS] generate-package [--dir=DIR] NAME`

    Creates an empty package skeleton for a release in `dir`. Includes bare `spec` and an empty `packaging` file.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

#### Vendor-Package {: #vendor-package }

- `bosh [GLOBAL-CLI-OPTIONS] vendor-package [--dir=DIR] PACKAGE SRC-DIR` (v2.0.36+)

    Vendors a package from a different release into a release in `dir`. It includes `spec.lock` in the package directory so that CLI will reference specific package by its fingerprint when creating releases.

    - `--dir=DIR` Release directory path if not current working directory (default: .)
    - `--prefix=` Prefix to add to the package name

    See [Package vendoring](package-vendoring.md) for details.

#### Create-Release {: #create-release }

- `bosh [GLOBAL-CLI-OPTIONS] create-release [--dir=DIR] [--name=NAME] [--version=VERSION] [--timestamp-version] [--final] [--tarball=PATH] [--force] [PATH]` (Alias: `cr`)

    Creates new version of a release stored in `dir`

    - `--dir=DIR` Release directory path if not current working directory (default: .)
    - `--name=NAME` Custom release name
    - `--version=VERSION` set release version
    - `--timestamp-version` produce timestamp-based dev release version
    - `--final` Make it a final release
    - `--tarball=PATH` specify destination of a release tarball; if not specified, release tarball will not be produced
    - `--force` include uncommitted changes in the release directory; it should only be used when building dev releases
    - `PATH` path to release yml file

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

- `bosh [GLOBAL-CLI-OPTIONS] finalize-release [--dir=DIR] [--name=NAME] [--version=VERSION] [--force] PATH`

    Records contents of a release tarball in the release repository as a final release with an optionally given version. Once `.final_builds` and `releases` directories are updated, it's strongly recommended to commit your changes to version control.

    Typically this command is used as a final step in the CI pipeline to save the final artifact once it passed appropriate tests.

    - `--dir=DIR` Release directory path if not current working directory (default: .)
    - `--name=NAME` Custom release name
    - `--version=VERSION` Custom release version (e.g.: 1.0.0, 1.0-beta.2+dev.10)
    - `--force` Ignore Git dirty state check

    ```shell
    cd release-dir
    bosh finalize-release /tmp/my-release.tgz
    bosh finalize-release /tmp/my-release.tgz --version 20
    git commit -am 'Final release 20'
    git push origin master
    ```

    * Note: `finalize-release` does not change the input tarball in any way (i.e. if a `--version` flag is passed, it will not modify the version present in the tarball itself).

#### Reset-Release {: #reset-release }

- `bosh [GLOBAL-CLI-OPTIONS] reset-release [--dir=DIR]`

    Removes temporary artifacts such as dev releases, blobs, etc. kept in the release directory `dir`.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

---
### Release blobs {: #blob-mgmt }

See [Release Blobs](release-blobs.md) for a detailed workflow.

#### Blobs {: #blobs }

- `bosh [GLOBAL-CLI-OPTIONS] blobs [--dir=DIR]`

    Lists tracked blobs from `config/blobs.yml`. Shows uploaded and not-yet-uploaded blobs.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

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

- `bosh [GLOBAL-CLI-OPTIONS] add-blob [--dir=DIR] PATH BLOBS-PATH`

    Starts tracking blob in `config/blobs.yml` for inclusion in packages.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

    ```shell
    cd release-dir
    bosh add-blob ~/Downloads/stress-1.0.4.tar.gz stress/stress-1.0.4.tar.gz
    ```

#### Remove-Blob {: #remove-blob }

- `bosh [GLOBAL-CLI-OPTIONS] remove-blob [--dir=DIR] BLOBS-PATH`

    Stops tracking blob in `config/blobs.yml`. Does not remove previously uploaded copies from the blobstore as older release versions may still want to reference it.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

    ```shell
    cd release-dir
    bosh remove-blob stress/stress-1.0.4.tar.gz
    ```

#### Upload-Blobs {: #upload-blobs }

- `bosh [GLOBAL-CLI-OPTIONS] upload-blobs [--dir=DIR]`

    Uploads previously added blobs that were not yet uploaded to the blobstore. Updates `config/blobs.yml` with returned blobstore IDs. Before creating a final release it's strongly recommended to upload blobs so that other release contributors can rebuild a release from scratch.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

    ```shell
    cd release-dir
    bosh upload-blobs
    ```

#### Sync-Blobs {: #sync-blobs }

- `bosh sync-blobs [--dir=DIR]`

    Downloads blobs into `blobs/` based on `config/blobs.yml`.

    - `--dir=DIR` Release directory path if not current working directory (default: .)

    ```shell
    cd release-dir
    bosh sync-blobs
    ```

---
### Releases {: #release-mgmt }

See [Uploading Releases](uploading-releases.md).

#### Releases {: #releases }

- `bosh [GLOBAL-CLI-OPTIONS] releases` (Alias: `rs`)

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

- `bosh [GLOBAL-CLI-OPTIONS] upload-release [--dir=DIR] [--rebase] [--fix] [--name=NAME] [--version=VERSION] [--sha1=DIGEST] [--stemcell=OS/VERSION] [URL]` (Alias: `ur`)

    Uploads release to the Director. Succeeds even if release is already imported.

    Release location may be local file system path, HTTP/HTTPS URL or a git URL

    - `--dir=DIR` Release directory path if not current working directory (default: .)
    - `--rebase` Rebases this release onto the latest version known by the Director
    - `--fix` Replaces corrupt and missing jobs and packages
    - `--name=NAME`  Name used in existence check (is not used with local release file)
    - `--version=VERSION` Version used in existence check (is not used with local release file)
    - `--sha1=DIGEST` SHA1 of the remote release (is not used with local files)
    - `--stemcell=OS/VERSION` Stemcell that the release is compiled against (applies to remote releases)
    - `URL` Path to a local file or URL

    ```shell
    bosh -e my-env ur
    bosh -e my-env ur https://bosh.io/d/github.com/concourse/concourse?v=2.7.3
    bosh -e my-env ur git+https://github.com/concourse/concourse --version 2.7.3
    ```

#### Delete-Release {: #delete-release }

- `bosh [GLOBAL-CLI-OPTIONS] delete-release [--force] NAME[/VERSION]`

    Deletes uploaded release from the Director. Succeeds even if release is not found.

    - `--force` Ignore errors

    ```shell
    bosh -e my-env delete-release cf-smoke-tests/94
    ```

#### Export-Release {: #export-release }

- `bosh [GLOBAL-CLI-OPTIONS] export-release [--dir=DIR] [--job=NAME] NAME/VERSION OS/VERSION`

    Compiles and exports a release against a particular stemcell version.

    Requires to operate with a deployment so that compilation resources (VMs) are properly tracked.

    - `--dir=DIR` Destination directory (default: .)
    - `--job=NAME` Name of job to export

    ```shell
    bosh -e my-env -d my-dep export-release cf-smoke-tests/94 ubuntu-xenial/621.74
    ```

#### Inspect-Release {: #inspect-release }

- `bosh [GLOBAL-CLI-OPTIONS] inspect-release NAME/VERSION`

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
    ~                                                                  ubuntu-xenial/621.74  f66fe541-8c21-4fe3-...  8e662c2e2...
    consul-windows/2a8e0b7ce1424d1d5efe5c7184791481a0c26424            (source)              9516870b-801e-42ea-...  19db18127...
    consul/6049d3016cd34ac64ccbf7837b06b6db81942102                    (source)              04aa38af-e883-4842-...  c42cacfc7...
    ~                                                                  ubuntu-xenial/621.74  ab4afda6-881e-46b1-...  27c1390fa...
    golang1.7-windows/1a80382e081cd429cf518f0c783f4e4172cac79e         (source)              d7670210-7038-4749-...  b91caa06a...
    golang1.7/181f7537c2ec17ac2406d9f2eb3322fd80fa2a1c                 (source)              ac8aa36a-8965-46e9-...  ca440d716...
    ~                                                                  ubuntu-xenial/621.74  9d40794f-0c50-4d0c-...  9d6e29221...

    11 packages

    Succeeded
    ```

#### Inspect-Local-Release {: #inspect-local-release}

- `bosh [GLOBAL-CLI-OPTIONS] inspect-local-release PATH`

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

- `bosh [GLOBAL-CLI-OPTIONS] configs [--name=NAME] [--type=TYPE] [-r ...]`

    Lists all the configs on the Director.

    - `--name=NAME` Config name
    - `--type=TYPE` Config type
    - `-r`, `--recent=NUMBER` Number of configs to show (default: 1)

    ```shell
    bosh -e my-env configs
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as client 'admin'

    Type     Name
    cloud    default
    ~        custom-vm-types
    cpi      default
    runtime  default

    3 configs

    Succeeded
    ```

#### Config {: #config }

- `bosh [GLOBAL-CLI-OPTIONS] config [--name=NAME] [--type=TYPE] [ID]`

    Show current config for either `ID` or both `type` and `name`.

    - `--name=NAME` Config name
    - `--type=TYPE` Config type
    - `ID` Config ID

    ```shell
    bosh -e my-env config --type=my-type --name=my-name
    bosh -e my-env config 5
    ```

#### Update-Config {: #update-config }

- `bosh [GLOBAL-CLI-OPTIONS] update-config [--type=TYPE] [--name=NAME] [--expected-latest-id=ID] [-v ...] [--var-file=VAR=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] PATH`

    Update config on the Director.

    - `--type=TYPE` Config type, e.g. 'cloud', 'runtime', or 'cpi'
    - `--name=NAME` Config name
    - `--expected-latest-id=ID` Expected ID of latest config
    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `PATH` Path to a YAML config file

    ```shell
    bosh -e my-env update-config config.yml --type=cloud
    bosh -e my-env update-config config.yml --type=cloud --name=network1
    ```

#### Delete-Config {: #delete-config }

- `bosh [GLOBAL-CLI-OPTIONS] delete-config [--type=TYPE] [--name=NAME] [ID]`

    Delete config on the Director.

    - `--name=NAME` Config name
    - `--type=TYPE` Config type
    - `ID` Config ID

    ```shell
    bosh -e my-env delete-config --type=my-type
    bosh -e my-env delete-config --type=my-type --name=my-name
    ```

#### Diff-Config {: #diff-config }

- `bosh [GLOBAL-CLI-OPTIONS] diff-config [--from-id=ID] [--to-id=ID] [--from-content=PATH] [--to-content=PATH]`

    Diff two configs by ID or content.

    - `--from-id=ID` ID of first config to compare
    - `--to-id=ID` ID of second config to compare
    - `--from-content=PATH` path to first config file to compare
    - `--to-content=PATH` path to second config file to compare

    ```shell
    bosh -e my-env diff-config --from-id=1 --to-id=2
    bosh -e my-env diff-config --from-content=/path/to/file1 --to-content=/path/to/file2
    ```

---
### Cloud config {: #cloud-config-mgmt }

See [Cloud config](cloud-config.md).

#### Cloud-Config {: #cloud-config }

- `bosh [GLOBAL-CLI-OPTIONS] cloud-config` (Alias: `cc`)

    Show current cloud config on the Director.

    - `--name=NAME` Cloud-Config name (default: ''); Available as of director version v273.0.0

#### Update-Cloud-Config {: #update-cloud-config }

- `bosh [GLOBAL-CLI-OPTIONS] update-cloud-config [-v ...] [--var-file=VAR=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] PATH` (Alias: `ucc`)

    Update current cloud config on the Director.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--name=NAME` Cloud-Config name (default: ''); Available as of director version v273.0.0
    - `PATH` Path to a cloud config file

    ```shell
    bosh -e my-env ucc cc.yml
    ```

---
### Runtime config {: #runtime-config-mgmt }

See [Runtime config](runtime-config.md).

#### Runtime-Config {: #runtime-config }

- `bosh [GLOBAL-CLI-OPTIONS] runtime-config [--name=NAME]` (Alias: `rc`)

    Show current runtime config on the Director.

    - `--name=NAME` Runtime-Config name (default: '')

#### Update-Runtime-Config {: #update-runtime-config }

- `bosh [GLOBAL-CLI-OPTIONS] update-runtime-config [-v ...] [--var-file=VAR=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--no-redact] [--name=NAME] PATH` (Alias: `urc`)

    Update current runtime config on the Director.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--no-redact` Show non-redacted manifest diff
    - `--name=NAME` Runtime-Config name (default: '')
    - `PATH` Path to a runtime config file

    ```shell
    bosh -e my-env urc runtime.yml
    ```

---
### CPI config {: #cpi-config-mgmt }

See [CPI config](cpi-config.md).

#### CPI-Config {: #cpi-config }

- `bosh [GLOBAL-CLI-OPTIONS] cpi-config`

    Show current CPI config on the Director.

#### Update-CPI-Config {: #update-cpi-config }

- `bosh [GLOBAL-CLI-OPTIONS] update-cpi-config [-v ...] [--var-file=VAR=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--no-redact] PATH`

    Update current CPI config on the Director.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--no-redact` Show non-redacted manifest diff
    - `PATH` Path to a CPI config file

    ```shell
    bosh -e my-env update-cpi-config cpis.yml
    ```

---
### Deployments {: #deployment-mgmt }

#### Deployments {: #deployments }

- `bosh [GLOBAL-CLI-OPTIONS] deployments` (Alias: `ds`)

    Lists deployments tracked by the Director. Shows their names, used releases and stemcells.

    ```shell
    bosh -e my-env ds
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as client 'admin'

    Name                                Release(s)                Stemcell(s)                                         Team(s)
    cf                                  binary-buildpack/1.0.9    bosh-warden-boshlite-ubuntu-xenial-go_agent/621.74  -
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
    service-instance_0d4140a0-42b7-...  mysql/0.6.0               bosh-warden-boshlite-ubuntu-xenial-go_agent/621.74  -

    2 deployments

    Succeeded
    ```

#### Deployment {: #deployment }

- `bosh [GLOBAL-CLI-OPTIONS] deployment` (Alias: `dep`)

    Shows general deployment information for a given deployment.

    Can be used to determine if Director has a deployment with a given name.

    ```shell
    bosh -e vbox -d cf dep
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as client 'admin'

    Name  Release(s)              Stemcell(s)                                         Team(s)  Cloud Config
    cf    binary-buildpack/1.0.9  bosh-warden-boshlite-ubuntu-xenial-go_agent/621.74  -        latest
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

- `bosh [GLOBAL-CLI-OPTIONS] deploy [-v ...] [--var-file=VAR=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--no-redact] [--recreate] [--recreate-persistent-disks] [--fix] [--skip-drain=[INSTANCE-GROUP[/INSTANCE-ID]]] [--canaries=NUMBER or PERCENTAGE] [--max-in-flight=NUMBER or PERCENTAGE] [--dry-run] [--force-latest-variables] PATH`

    Create or update specified deployment according to the provided manifest. Operation files and variables can be provided to adjust and fill in manifest before deploy begins.

    Currently name provided via `--deployment` (`-d`) flag must match name specified in the manifest.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--no-redact` Show non-redacted manifest diff
    - `--recreate` Recreate all VMs in deployment. It will recreate regardless of whether there is a manifest change
    - `--recreate-persistent-disks` Recreate all persistent disks in deployment. It will recreate regardless of whether there is a manifest change
    - `--fix` Recreate an instance with an unresponsive agent instead of erroring
    - `--fix-releases` Reupload releases in manifest and replace corrupt or missing jobs/packages
    - `--skip-drain=[INSTANCE-GROUP[/INSTANCE-ID]]` Skip running drain and pre-stop scripts for specific instance groups
    - `--canaries=NUMBER or PERCENTAGE` Override manifest values for canaries
    - `--max-in-flight=NUMBER or PERCENTAGE` Override manifest values for max_in_flight
    - `--dry-run` Renders job templates without altering a deployment. It will save some state in the director database (like ip reservations) which will be reused on the next deploy
    - `--force-latest-variables` Causes the director to retreive the latest value of all variables from the config server, overriding their update strategies.  Available as of director version v279.0.0
    - `PATH` Path to a manifest file

    ```shell
    bosh -e vbox -d cf deploy cf.yml -v system_domain=sys.example.com -o large-footprint.yml
    ```

#### Delete-Deployment {: #delete-deployment }

- `bosh [GLOBAL-CLI-OPTIONS] delete-deployment [--force]` (Alias: `deld`)

    Deletes specified deployment.

    - `--force` Ignore errors

    Note that if you've deleted your deployment, not all resources may have been freed. For example "deleted" persistent disks will be deleted after a few days to avoid accidental data loss. See [Persistent and Orphaned Disks](persistent-disks.md) for more details.

    Succeeds even if deployment is not found.

    ```shell
    bosh -e vbox -d cf deld
    bosh -e vbox -d cf deld --force
    ```

#### Instances {: #instances }

- `bosh [GLOBAL-CLI-OPTIONS] instances [-i] [--dns] [--vitals] [-p] [-f]` (Alias: `is`)

    Lists all instances managed by the Director or in a single deployment. Show instance names, IPs, and VM and process health.

    - `-i`, `--details` Show details including VM CID, persistent disk CID, etc.
    - `--dns` Show DNS A records
    - `--vitals` Show vitals
    - `-p`, `--ps` Show processes
    - `-f`, `--failing` Only show failing instances

    ```shell
    bosh -e vbox is -i
    bosh -e vbox is --ps --vitals
    bosh -e vbox -d cf is
    bosh -e vbox -d cf is --ps
    bosh -e vbox -d cf is --ps --vitals
    ```

#### Manifest {: #manifest }

- `bosh [GLOBAL-CLI-OPTIONS] manifest` (Alias: `man`)

    Prints deployment manifest to `stdout`. In case a deployment failed, it will print the manifest of the last succesful deploy.

    ```shell
    bosh -e vbox -d cf man > /tmp/manifest.yml
    ```

#### Recreate {: #recreate }

- `bosh [GLOBAL-CLI-OPTIONS] recreate [--skip-drain] [--fix] [--canaries=NUMBER or PERCENTAGE] [--max-in-flight=NUMBER or PERCENTAGE] [--dry-run] [--converge] [--no-converge] [INSTANCE-GROUP[/INSTANCE-ID]]`

    Recreates VMs for specified instances. Follows typical instance lifecycle.

    - `--skip-drain` skip running drain scripts; Also skip pre-stop scripts as of director version v270.0.0
    - `--fix` recover an instance with an unresponsive agent instead of erroring
    - `--canaries=NUMBER or PERCENTAGE` override manifest values for `canaries`
    - `--max-in-flight=NUMBER or PERCENTAGE` override manifest values for `max_in_flight`
    - `--dry-run` run through as many operations as possible without altering deployment
    - `--converge` converge the deployment with the last successful deployment state. This flag is optional and is the default behavior. See [Deployment Convergence](deployment-convergence.md) for more details
    - `--no-converge` update only the specified instance with current instance state. See [Deployment Convergence](deployment-convergence.md) for more details

    ```shell
    bosh -e vbox -d cf recreate
    bosh -e vbox -d cf recreate --fix
    bosh -e vbox -d cf recreate diego-cell
    bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox -d cf recreate diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --skip-drain
    bosh -e vbox -d cf recreate diego-cell --canaries=0 --max-in-flight=100%
    ```
    !!! warning
        In case of a **failed** deployment, running `bosh recreate` with the default behavior of `--converge` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Restart {: #restart }

- `bosh [GLOBAL-CLI-OPTIONS] restart [--skip-drain] [--canaries=NUMBER or PERCENTAGE] [--max-in-flight=NUMBER or PERCENTAGE] [--converge] [--no-converge] [INSTANCE-GROUP[/INSTANCE-ID]]`

    Restarts jobs (processes) on specified instances. Does not affect VM state.

    - `--skip-drain` skip running drain scripts; Also skip pre-stop scripts as of director version v270.0.0
    - `--canaries=NUMBER or PERCENTAGE` override manifest values for `canaries`
    - `--max-in-flight=NUMBER or PERCENTAGE` override manifest values for `max_in_flight`
    - `--converge` converge the deployment with the last successful deployment state. This flag is optional and is the default behavior. See [Deployment Convergence](deployment-convergence.md) for more details
    - `--no-converge` update only the specified instance with current instance state. See [Deployment Convergence](deployment-convergence.md) for more details

    !!! warning
        In case of a **failed** deployment, running `bosh restart` without `--no-converge` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Start {: #start }

- `bosh [GLOBAL-CLI-OPTIONS] start [--canaries=NUMBER or PERCENTAGE] [--max-in-flight=NUMBER or PERCENTAGE] [--converge] [--no-converge] [INSTANCE-GROUP[/INSTANCE-ID]]`

    Starts jobs (processes) on specified instances. Does not affect VM state.

    - `--canaries=NUMBER or PERCENTAGE` override manifest values for `canaries`
    - `--max-in-flight=NUMBER or PERCENTAGE` override manifest values for `max_in_flight`
    - `--converge` converge the deployment with the last successful deployment state. This flag is optional and is the default behavior. See [Deployment Convergence](deployment-convergence.md) for more details
    - `--no-converge` update only the specified instance with current instance state. See [Deployment Convergence](deployment-convergence.md) for more details

    !!! warning
        In case of a **failed** deployment, running `bosh start` without `--no-converge` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Stop {: #stop }

- `bosh [GLOBAL-CLI-OPTIONS] stop [--skip-drain] [--canaries=NUMBER or PERCENTAGE] [--max-in-flight=NUMBER or PERCENTAGE] [--converge] [--no-converge] [INSTANCE-GROUP[/INSTANCE-ID]]`

    Stops jobs (processes) on specified instances. Does not affect VM state unless `--hard` flag is specified.

    - `--hard` force VM deletion (keeping persistent disk)
    - `--skip-drain` skip running drain scripts; Also skip pre-stop scripts as of director version v270.0.0
    - `--canaries=NUMBER or PERCENTAGE` override manifest values for `canaries`
    - `--max-in-flight=NUMBER or PERCENTAGE` override manifest values for `max_in_flight`
    - `--converge` converge the deployment with the last successful deployment state. This flag is optional and is the default behavior. See [Deployment Convergence](deployment-convergence.md) for more details
    - `--no-converge` update only the specified instance with current instance state. See [Deployment Convergence](deployment-convergence.md) for more details

    !!! warning
        In case of a **failed** deployment, running `bosh stop` without `--no-converge` will converge to the last **successfully deployed state**, not the intended state of the failed deployment. See [Deployment Convergence](deployment-convergence.md).

#### Ignore {: #ignore }

- `bosh [GLOBAL-CLI-OPTIONS] ignore INSTANCE-GROUP/INSTANCE-ID`

    Ignores instance from being affected by other commands such as `bosh deploy`. [See details](terminology.md#ignored-instances).

#### Unignore {: #unignore }

- `bosh -e my-env -d my-dep unignore INSTANCE-GROUP/INSTANCE-ID`

    Unignores instance from being affected by other commands such as `bosh deploy`.

#### Logs {: #logs }

- `bosh [GLOBAL-CLI-OPTIONS] logs [--dir=DIR] [-f] [--num=NUMBER] [-q] [--job=NAME] [--only=FILTERS] [--agent] [--gw-disable] [--gw-user=USER] [--gw-host=HOST] [--gw-private-key=KEY] [--gw-socks5=URL] [INSTANCE-GROUP[/INSTANCE-ID]]`

    Downloads logs from one or more instances.

    - `--dir=DIR` Destination directory (default: .)
    - `-f`, `--follow` Follow logs via SSH
    - `--num=NUMBER` Last number of lines
    - `-q`, `--quiet` Suppresses printing of headers when multiple files are being examined
    - `--job=NAME` Limit to only specific jobs
    - `--only=FILTERS` Filter logs (comma-separated)
    - `--agent` Include only agent logs
    - `--system` Include only system logs
    - `--all-logs` Include all logs (agent, system, and job logs)
    - `--gw-disable` Disable usage of gateway connection [$BOSH_GW_DISABLE]
    - `--gw-user=USER` Username for gateway connection [$BOSH_GW_USER]
    - `--gw-host=HOST` Host for gateway connection [$BOSH_GW_HOST]
    - `--gw-private-key=KEY` Private key path for gateway connection [$BOSH_GW_PRIVATE_KEY]
    - `--gw-socks5=URL` SOCKS5 URL [$BOSH_ALL_PROXY]
    - `--director` Target the command at the BOSH director (or other type of VM deployed via create-env)
    - `--agent-endpoint=URL` Address to connect to the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.mbus` property of a BOSH director manifest. [$BOSH_AGENT_ENDPOINT]
    - `--agent-certificate=CERTIFICATE_CONTENT` CA certificate to validate the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.cert` property of a BOSH director manifest. [$BOSH_AGENT_CERTIFICATE]

    See [Location and use of logs](job-logs.md) for details.

    ```shell
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --job=rep --job=silkd
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --only='*/*stderr.log'
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --agent --only=current --only=sync-time.out
    bosh -e vbox -d cf logs diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --system --only=kern.log --only=syslog --only=auth.log
    bosh -e vbox -d cf logs -f
    bosh -e vbox -d cf logs -f --num=1000
    bosh -e vbox -d cf logs -f --system --num=1000
    ```

    !!! note
        The `--system` and `--all-logs` flags require version `v7.2.0` or later of the BOSH CLI.

    !!! note
        Downloading `--system` or `--all-logs` logs requires special Agent support, and only works with Agents `v2.516.0` or newer. Following (with `--follow`) `--system` or `--all-logs` logs works with any Agent version.

#### Events {: #events }

- `bosh [GLOBAL-CLI-OPTIONS] events [--before-id=ID] [--before=TIMESTAMP] [--after=TIMESTAMP] [--task=ID] [--instance=ID] [--event-user=USER] [--action=ACTION] [--object-type=TYPE] [--object-name=NAME]`

    Lists events.

    See [Events](events.md) for details.

    - `--before-id=ID` show events with ID less than the given ID
    - `--before=TIMESTAMP` show events before the given timestamp (ex: 2016-05-08 17:26:32)
    - `--after=TIMESTAMP` show events after the given timestamp (ex: 2016-05-08 17:26:32)
    - `--task=ID` show events with the given task ID
    - `--instance=ID` show events with given instance
    - `--event-user=USER` show events with given user
    - `--action=ACTION` show events with given action
    - `--object-type=TYPE` show events with given object type
    - `--object-name=NAME` show events with given object name

    ```shell
    bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0
    bosh -e vbox events --instance diego-cell/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 --task 281
    bosh -e vbox events -d my-dep
    bosh -e vbox events --before-id=1298284
    bosh -e vbox events --before="2016-05-08 17:26:32 UTC" --after="2016-05-07 UTC"
    ```

#### Event {: #event }

- `bosh [GLOBAL-CLI-OPTIONS] event ID`

    Shows single event details.

#### Variables {: #variables }

- `bosh [GLOBAL-CLI-OPTIONS] variables` (Alias: `vars`)

    List variables referenced by the deployment.

---
### VMs {: #vm-mgmt }

#### Vms {: #vms }

- `bosh [GLOBAL-CLI-OPTIONS] vms [--dns] [--vitals] [--cloud-properties]`

    Lists all VMs managed by the Director or VMs in a single deployment. Show instance names, IPs and VM CIDs.

    - `--dns` Show DNS A records
    - `--vitals` Show vitals
    - `--cloud-properties` Show cloud properties

    ```shell
    bosh -e vbox vms
    bosh -e vbox -d cf vms
    bosh -e vbox -d cf vms --vitals
    ```

#### Delete-Vm {: #delete-vm }

- `bosh [GLOBAL-CLI-OPTIONS] delete-vm CID`

    Deletes VM without going through typical instance lifecycle. Clears out VM reference from a Director database if referenced by any instance.

    ```shell
    bosh -e vbox -d cf delete-vm i-fs384238fjwjf8
    ```

#### Orphaned-Vms {: #orphaned-vms }

- `bosh [GLOBAL-CLI-OPTIONS] orphaned-vms`

    List all the orphaned VMs for all deployments.

    ```shell
    bosh -e vbox orphaned-vms
    ```

---
### Disks {: #disk-mgmt }

#### Disks {: #disks }

- `bosh [GLOBAL-CLI-OPTIONS] disks [-o ]`

    Lists disks.

    - `-o`, `--orphaned` List orphaned disks

#### Orphan-Disk {: #orphan-disk }

- `bosh [GLOBAL-CLI-OPTIONS] orphan-disk CID`

    Orphans a disk attached to an instance. You can get disk's CID from `bosh instances --details`.

    ```shell
    bosh -e vbox orphan-disk xxxx-xxxx-xxxx
    ```

#### Attach-Disk {: #attach-disk }

- `bosh [GLOBAL-CLI-OPTIONS] attach-disk [--disk-properties=PROPERTIES] INSTANCE-GROUP/INSTANCE-ID DISK-CID`

    Attaches disk to an instance, replacing and orphaning the currently attached disk (if any).

    - `--disk-properties=PROPERTIES` Disk properties to use for the new disk. Use 'copy' to copy the properties from the currently attached disk

    ```shell
    bosh -e vbox -d cf attach-disk postgres/209c42e5-3c1a-432a-8445-ab8d7c9f69b0 vol-shw8f293f2f2
    ```

#### Delete-Disk {: #delete-disk }

- `bosh [GLOBAL-CLI-OPTIONS] delete-disk CID`

    Deletes orphaned disk.

    ```shell
    bosh -e vbox -d cf delete-disk vol-shw8f293f2f2
    ```


---
### SSH {: #ssh-mgmt }

#### SSH {: #ssh }

- `bosh [GLOBAL-CLI-OPTIONS] ssh [-c=CMD] [--opts=OPTS] [-r] [--gw-disable] [--gw-user=USER] [--gw-host=HOST] [--gw-private-key=KEY] [--gw-socks5=URL] [INSTANCE-GROUP[/INSTANCE-ID]]`

    SSH into one or more instances.

    - `-c`, `--command=CMD` Command
    - `--opts=OPTS` specify pass-through options to `ssh`; useful for port forwarding
    - `-r`, `--results` Collect results into a table instead of streaming
    - `--gw-disable` Disable usage of gateway connection [$BOSH_GW_DISABLE]
    - `--gw-user=USER` Username for gateway connection [$BOSH_GW_USER]
    - `--gw-host=HOST` Host for gateway connection [$BOSH_GW_HOST]
    - `--gw-private-key=KEY` Private key path for gateway connection [$BOSH_GW_PRIVATE_KEY]
    - `--gw-socks5=URL` SOCKS5 URL [$BOSH_ALL_PROXY]
    - `--director` Target the command at the BOSH director (or other type of VM deployed via create-env)
    - `--agent-endpoint=URL` Address to connect to the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.mbus` property of a BOSH director manifest. [$BOSH_AGENT_ENDPOINT]
    - `--agent-certificate=CERTIFICATE_CONTENT` CA certificate to validate the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.cert` property of a BOSH director manifest. [$BOSH_AGENT_CERTIFICATE]

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

- `bosh [GLOBAL-CLI-OPTIONS] scp [-r] [--gw-disable] [--gw-user=USER] [--gw-host=HOST] [--gw-private-key=KEY] [--gw-socks5=URL] PATH...`

    SCP to/from one or more instances.

    - `--recursive` (`-r`) copy directory recursively
    - `--gw-disable` Disable usage of gateway connection [$BOSH_GW_DISABLE]
    - `--gw-user=USER` Username for gateway connection [$BOSH_GW_USER]
    - `--gw-host=HOST` Host for gateway connection [$BOSH_GW_HOST]
    - `--gw-private-key=KEY` Private key path for gateway connection [$BOSH_GW_PRIVATE_KEY]
    - `--gw-socks5=URL` SOCKS5 URL [$BOSH_ALL_PROXY]
    - `--director` Target the command at the BOSH director (or other type of VM deployed via create-env)
    - `--agent-endpoint=URL` Address to connect to the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.mbus` property of a BOSH director manifest. [$BOSH_AGENT_ENDPOINT]
    - `--agent-certificate=CERTIFICATE_CONTENT` CA certificate to validate the agent's HTTPS endpoint (used with --director). Corresponds to the `cloud_provider.cert` property of a BOSH director manifest. [$BOSH_AGENT_CERTIFICATE]

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

- `bosh [GLOBAL-CLI-OPTIONS] errands` (Alias: `es`)

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

- `bosh [GLOBAL-CLI-OPTIONS] run-errand [--instance=INSTANCE-GROUP[/INSTANCE-ID]] [--keep-alive] [--when-changed] [--download-logs] [--logs-dir=DIR] NAME`

    Runs errand job by name.

    - `--instance=INSTANCE-GROUP[/INSTANCE-ID]` Instance or group the errand should run on (must specify errand by release job name)
    - `--keep-alive` Use existing VM to run an errand and keep it after completion
    - `--when-changed` Run errand only if errand configuration has changed or if the previous run was unsuccessful
    - `--download-logs` Download logs
    - `--logs-dir=DIR` Destination directory for logs (default: .)

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

- `bosh [GLOBAL-CLI-OPTIONS] tasks [--recent=NUMBER] [-a]` (Alias: `ts`)

    Lists active and previously ran tasks.

    - `-r`,` --recent=NUMBER` Show 30 recent tasks. Use '=' to specify the number of tasks to show
    - `-a`, `--all` Include all task types (ssh, logs, vms, etc)

    ```shell
    # currently active tasks
    bosh -e vbox ts

    # currently active tasks for my-dep deployment
    bosh -e vbox -d my-dep ts
    ```

    Should result in:

    ```text
    Using environment '192.168.56.6' as '?'

    #   State  Started At                    Finished At                   User   Deployment   Description                   Result

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

- `bosh [GLOBAL-CLI-OPTIONS] task [--event] [--cpi] [--debug] [--result] [-a] [ID]` (Alias: `t`)

    Shows single task details. Continues to follow task if it did not finish. `Ctrl^C` does not cancel the task.

    - `--event` Track event log
    - `--cpi` Track CPI log
    - `--debug` Track debug log
    - `--result` Track result log
    - `-a`, `--all` Include all task types (ssh, logs, vms, etc)
    - `ID` ID of the task

    ```shell
    bosh -e vbox t 281
    bosh -e vbox t 281 --debug
    ```

#### Cancel-Task {: #cancel-task }

- `bosh [GLOBAL-CLI-OPTIONS] cancel-task ID` (Alias: `ct`)

    Cancel task at its next checkpoint. Does not wait until task is cancelled.

    ```shell
    bosh -e vbox ct 281
    ```

#### Cancel-Tasks {: #cancel-tasks }

- `bosh [GLOBAL-CLI-OPTIONS] cancel-tasks [--type=TYPE] [--state=STATE]` (Alias: `cts`)

    Cancel multiple tasks by type and state at their next checkpoints.

    - `-t`, `--type=TYPE` task types to cancel (cck_scan_and_fix, cck_apply, update_release, update_deployment, vms, etc.) (default is all types)
    - `-s`, `--state=STATE` task states to cancel (queued, processing) (default: queued)

    ```shell
    bosh -e vbox cts \
         -d my-dep \
         -t scan_and_fix \
         -t update_deployment \
         -t fetch_logs \
         -s queued \
         -s processing
    ```

---
### Snapshots {: #snapshot-mgmt }

#### Snapshots {: #snapshots }

- `bosh [GLOBAL-CLI-OPTIONS] snapshots [INSTANCE-GROUP/INSTANCE-ID]`

    Lists disk snapshots for given deployment.

#### Take-Snapshot {: #take-snapshot }

- `bosh [GLOBAL-CLI-OPTIONS] take-snapshot [INSTANCE-GROUP/INSTANCE-ID]`

    Takes snapshot for an instance or an entire deployment.

#### Delete-Snapshot {: #delete-snapshot }

- `bosh [GLOBAL-CLI-OPTIONS] delete-snapshot CID`

    Deletes snapshot.

    ```shell
    bosh -e vbox -d cf delete-snapshot snap-shw38ty83f2f2
    ```

#### Delete-Snapshots {: #delete-snapshots }

- `bosh [GLOBAL-CLI-OPTIONS] delete-snapshots`

    Deletes snapshots for an entire deployment.

---
### Deployment recovery {: #deployment-recovery }

#### Update-Resurrection {: #update-resurrection }

- `bosh [GLOBAL-CLI-OPTIONS] update-resurrection on|off`

    Enables or disables resurrection globally. This state is not reflected in the `bosh instances` command's `Resurrection` column.

    **Note:** Using `bosh update-resurrection on` will not enable resurrection unless the Resurrector has already been configured for the Director via the `resurrector_enabled` property.

    See [Automatic repair with Resurrector](resurrector.md) for details.

#### Cloud-Check {: #cloud-check }

- `bosh [GLOBAL-CLI-OPTIONS] cloud-check [-a] [--resolution=RESOLUTION-VALUE] [-r]` (Alias: `cck`)

    Checks for resource consistency and allows interactive repair

    - `-a`, `--auto` Resolve problems automatically
    - `--resolution=RESOLUTION-VALUE` Apply resolution of given type
    - `-r`, `--report` Only generate report; don't attempt to resolve problems

    See [Manual repair with Cloud Check](cck.md) for details.

#### Create-Recovery-Plan {: #create-recovery-plan }

- `bosh [GLOBAL-CLI-OPTIONS] create-recovery-plan PATH`

    Checks for resource consistency and interactively prompts for problem resolution by instance group.  Optionally allows overriding the current value of `max_in_flight` for each instance group.  This information is then written to a YAML file and is used by the `bosh recover` command.

    - `PATH` Create recovery plan file at path

    See [Manual repair with recovery plans](recover.md) for details.

#### Recover {: #recover }

- `bosh [GLOBAL-CLI-OPTIONS] recover PATH`

    Using a recovery plan generated by `bosh create-recovery-plan`, this command displays a summary of the recovery plan, then applies the resolutions in the plan to the applicable instance groups, with their optional `max_in_flight` overrides.

    - `PATH` Path to a recovery plan that will be used

    See [Manual repair with recovery plans](recover.md) for details.

#### Locks {: #locks }

- `bosh [GLOBAL-CLI-OPTIONS] locks`

    Lists current locks.

---
### Network {: #network}

#### Networks {: #networks }

- `bosh [GLOBAL-CLI-OPTIONS] networks [-o]`

    List networks created by deployments.

    - `-o`, `--orphaned` List orphaned networks

    ```shell
    bosh -e vbox networks
    ```

#### Delete-Network {: #delete-network}

- `bosh [GLOBAL-CLI-OPTIONS] delete-network NAME`

    Deletes a network created during deployment. Check [CPI methods](https://bosh.io/docs/cpi-api-v2-method/create-network/#create_network) for more details

    ```shell
    bosh -e vbox delete-network network-name
    ```

---
### Misc {: #misc }

#### Clean-Up {: #clean-up }

- `bosh[GLOBAL-CLI-OPTIONS] clean-up [--all] [--dry-run] [--keep-orphaned-disks]`

    Cleans up unused resources but keeps orphaned disks and the two most recent versions of stemcells and releases.

    - `--all` clean up all unused resources including orphaned disks.
    - `--dry-run` list resources that would be cleaned up.
    - `--keep-orphaned-disks` do not delete orphaned disks with `--all`.

    Orphan disks get deleted after a few days by default. See [Orphan Disks](persistent-disks.md#orphaned-disks) for more details.

    **Note:** From BOSH v270.5.0, releases specified in runtime configs are considered 'in use' and won't be deleted by running `bosh clean-up [--all]`.


#### Help {: #help }

- `bosh help`

    Shows list of available commands and global options. Consider using `-h` flag for individual commands.

#### Interpolate Variables {: #interpolate }

- `bosh [GLOBAL-CLI-OPTIONS] interpolate [-v ...] [--var-file=PATH] [-l ...] [--vars-env=PREFIX] [--vars-store=PATH] [-o ...] [--path=OP-PATH] [--var-errs] [--var-errs-unused] PATH` (Alias: `int`)

    Interpolates variables into a manifest sending result to stdout. [Operation files](cli-ops-files.md) and [variables](cli-int.md) can be provided to adjust and fill in manifest before doing a deploy.

    - `-v`, `--var=VAR=VALUE` Set variable
    - `--var-file=VAR=PATH` Set variable to file contents
    - `-l`, `--vars-file=PATH` Load variables from a YAML file
    - `--vars-env=PREFIX` Load variables from environment variables (e.g.: 'MY' to load MY_var=value)
    - `--vars-store=PATH` Load/save variables from/to a YAML file
    - `-o`, `--ops-file=PATH` Load manifest operations from a YAML file
    - `--path=OP-PATH` Extract value out of template (e.g.: /private_key)
    - `--var-errs` Expect all variables to be found, otherwise error
    - `--var-errs-unused` Expect all variables to be used, otherwise error
    - `PATH` Path to a template that will be interpolated

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

- `bosh [GLOBAL-CLI-OPTIONS] curl [--method=HTTP-METHOD] [--header=HTTP-HEADER] [--body=PATH-TO-FILE-WITH-HTTP-REQUEST-BODY] [--show-headers] PATH`

    Make an HTTP request to the BOSH Director. **Recommended to be used for debugging purposes only**.

    - `--method` `(-X)` specify the HTTP method. Allowed values: `GET`, `POST`, `PUT`, and `DELETE`. Defaults to `GET`
    - `--header` `(-H)` add an HTTP header to the request in `'name: value'` format. Can be specified multiple times for multiple headers.
    - `--body` path to the file containing the HTTP request's body (for `POST` and `PUT`)
    - `--show-headers` `(-i)` show HTTP headers in the response
    - `PATH` URL path which can include query string


```shell
bosh curl /deployments
bosh curl /links?deployment=my-dep
bosh curl -H 'Content-Type: application/json' --body ./request-body.txt --method=POST /links
```
