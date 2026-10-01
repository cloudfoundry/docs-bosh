# Migrating Releases to Resolute Raccoon: For Release Authors

**Who this is for:** maintainers who need their BOSH release to compile and run on the Ubuntu 26.04 "Resolute Raccoon" stemcell. If you're moving a platform onto Resolute, read the [Platform Engineer guide](resolute-migration.md) instead.

!!! note
    **Coming from Jammy?** Work through the [Noble migration guide](noble-migration.md) first; everything below assumes those changes are done. In particular, the cgroup v2 and BPM changes described there are prerequisites.

This page lists the errors you're most likely to hit on Resolute, what causes them, and how to fix them:

## Removal of `runit` and `chpst`

This is the change most likely to break a release. The Resolute stemcell doesn't install the `runit` package. The stemcell itself no longer uses runit, but the package also provides `chpst`, which many job scripts use to drop privileges.

Symptom: the job fails to start, and its logs show

```text
chpst: command not found
```

or, from a `/bin/sh` script,

```text
chpst: not found
```

Check your release with:

```shell
grep -rn chpst jobs/ src/
```

Scripts that monit no longer runs, such as an old `ctl` script left behind after a move to BPM, can't break anything, but delete them anyway so the next search is clean.

### Fix: Run the Process Under BPM

This is the preferred fix. [BPM](bpm/bpm.md) runs processes as `vcap` by default, so the privilege drop comes for free. Anything that needs root, such as creating directories or setting file ownership, moves into a `pre-start` script. See [Migrating to BPM](bpm/transitioning.md).

Here is config-server-release's change. Before, `jobs/config_server/templates/ctl.erb`:

```bash
mkdir -p $RUN_DIR $LOG_DIR
chown -R $RUNAS:$RUNAS $RUN_DIR $LOG_DIR

echo $$ > $PIDFILE

exec chpst -u $RUNAS:$RUNAS /var/vcap/packages/config_server/bin/config-server $CONFIG_FILE \
  >>  $LOG_DIR/config_server.stdout.log \
  2>> $LOG_DIR/config_server.stderr.log
```

After, the `ctl` script is gone. `jobs/config_server/templates/bpm.yml.erb`:

```yaml
processes:
- name: config_server
  executable: /var/vcap/packages/config_server/bin/config-server
  args:
  - /var/vcap/jobs/config_server/config/config.json
```

and `jobs/config_server/monit`:

```text
check process config_server
  with pidfile /var/vcap/sys/run/bpm/config_server/config_server.pid
  start program "/var/vcap/jobs/bpm/bin/bpm start config_server"
  stop program "/var/vcap/jobs/bpm/bin/bpm stop config_server"
  group vcap
```

If the process needed root only for a capability, BPM can grant it. syslog-release's blackbox process ran as `chpst -u syslog:vcap` so that it could read system log files. Under BPM it runs as `vcap`, with `DAC_READ_SEARCH` and a read-only mount of the log directory:

```yaml
processes:
- name: blackbox
  executable: /var/vcap/packages/blackbox/bin/blackbox
  args:
  - -config=/var/vcap/jobs/syslog_forwarder/config/blackbox_config.yml
  capabilities:
  - DAC_READ_SEARCH
  unsafe:
    unrestricted_volumes:
    - path: <%= p("syslog.blackbox.source_dir") %>
      writable: false
      mount_only: true
```

### Fix: Replace `chpst` With `setpriv`, `su`, or `runuser`

When BPM doesn't fit, for example because the job must stay under plain monit, use a tool that's on every stemcell:

```bash
# Before
exec chpst -u vcap:vcap /var/vcap/packages/foo/bin/foo

# After: any of these
exec setpriv --reuid=vcap --regid=vcap --clear-groups -- /var/vcap/packages/foo/bin/foo
exec runuser -u vcap -- /var/vcap/packages/foo/bin/foo
exec su -s /bin/bash vcap -c "/var/vcap/packages/foo/bin/foo"
```

bosh-dns-release used `setpriv` as an interim fix. Where the binary relies on a file capability, such as `cap_net_bind_service` for port 53, leave out `setpriv --no-new-privs`, because it stops file capabilities from taking effect.

### Fix: Do Privileged Work in `pre-start`, or Drop `chpst`

Many uses of `chpst` don't need a replacement at all:

- `chpst` with no options (`exec chpst /path/to/start.sh`) does nothing. Remove it.
- `chpst -u root:root` in a script that already runs as root does nothing. Remove it.
- `chpst -u vcap:vcap mkdir -p /some/dir` in a `pre-start` script can become `mkdir -p /some/dir && chown vcap:vcap /some/dir`.

### bpm Is Installed in the Stemcell

The Resolute stemcell installs bpm in `/usr/libexec/bpm`, and `/var/vcap/jobs/bpm/bin/bpm` points to it. A job's `monit` file can call `/var/vcap/jobs/bpm/bin/bpm` without the bpm-release job colocated in the instance group.

- Don't make colocating the bpm job a requirement for Resolute deployments. It still works, but it replaces the stemcell's bpm on that instance, and we discourage it.
- If your release also supports Jammy or Noble, those deployments still need the bpm job colocated, because those stemcells don't include bpm.

## GCC 15 and CMake 4

Resolute ships GCC 15 (Noble had GCC 13) and CMake 4.2. Code that compiled on Noble can fail for several reasons.

### C23 Is the Default C Standard

GCC 15 compiles C as C23 (`-std=gnu23`) by default. In C23, `bool`, `true`, and `false` are keywords, and `int f();` declares a function that takes no arguments. Typical errors:

```text
a.c:1:13: error: 'bool' cannot be defined via 'typedef'
    1 | typedef int bool;
      |             ^~~~
a.c:1:13: note: 'bool' is a keyword with '-std=c23' onwards
```

```text
b.c:1:8: error: cannot use keyword 'false' as enumeration constant
    1 | enum { false, true };
      |        ^~~~~
```

```text
c.c:2:23: error: too many arguments to function 'f'; expected 0, have 1
```

The easiest fix is to compile with the older standard. pxc-release did this for libtirpc:

```bash
export CFLAGS="${CFLAGS:-} -std=gnu17"
```

Better still, bump to an upstream version that builds with GCC 15. See [Porting to GCC 15](https://gcc.gnu.org/gcc-15/porting_to.html).

### Warnings That Became Errors in GCC 14

Noble's GCC 13 only warned about these. GCC 14 and later treat them as errors:

```text
d.c:1:23: error: implicit declaration of function 'foo' [-Wimplicit-function-declaration]
```

```text
e.c:1:33: error: initialization of 'char *' from incompatible pointer type 'int *' [-Wincompatible-pointer-types]
```

These usually mean the vendored source is too old. capi-release bumped `mariadb-connector-c` from 3.3.5 to 3.4.8 to fix errors like these, and garden-runc-release bumped xfsprogs from 4.20.0 to 6.19.0. If you can't bump, `-fpermissive` or `-Wno-error=<warning>` restores the old behaviour. See [Porting to GCC 14](https://gcc.gnu.org/gcc-14/porting_to.html).

A project that turns on warnings-as-errors can also fail on new warnings. capi-release's `mariadb_connector_c` packaging turns that off:

```bash
cmake .. -DCMAKE_INSTALL_PREFIX=${BOSH_INSTALL_TARGET} -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
```

### CMake 4

CMake 4 no longer supports projects that declare compatibility with CMake older than 3.5:

```text
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
  Compatibility with CMake < 3.5 has been removed from CMake.

  Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
  to tell CMake that the project requires at least <min> but has been updated
  to work with policies introduced by <max> or earlier.

  Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
```

garden-runc-release's `tini` package fixed this with the flag the error suggests:

```bash
# Before
cmake .
# After
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .
```

CMake 4 also dropped its built-in `FindBoost` module. Projects that call `find_package(Boost)` now need the CMake config files that Boost 1.70 and later ship.

## Rust Coreutils

Most core utilities, such as `ls`, `cat`, and `install`, now come from [uutils](https://github.com/uutils/coreutils), a Rust implementation. `cp`, `mv`, and `rm` are still the GNU versions. Most scripts behave the same, but the differences are subtle when they do show up.

Known problem: [uutils/coreutils#11469](https://github.com/uutils/coreutils/issues/11469). `install -D` replaces a symlink in the destination path with a real directory, instead of following it. During compilation `BOSH_INSTALL_TARGET` is a symlink, so a `make install` that uses `install -D` writes its files to the wrong place. The package compiles without errors but ends up empty or missing files.

pxc-release works around this by resolving the symlink first:

```bash
# Workaround for uutils coreutils (ubuntu-resolute): its `install -D`
# replaces symlink path components with real directories instead of following
# them.
BOSH_INSTALL_TARGET=$(readlink -f "${BOSH_INSTALL_TARGET}")
```

The GNU versions of every utility are still installed with a `gnu` prefix: `gnuinstall`, `gnuls`, `gnudate`, and so on. Call the GNU tool directly, for example `gnuinstall -D`, when a script of yours depends on GNU behaviour.

Treat the `gnu`-prefixed tools as a stopgap. They may not be included in future stemcell lines.

## `sudo-rs`

`sudo` is now [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs). It doesn't support some sudoers settings. If your job writes a sudoers file that uses one of them, `sudo` prints an error on every call and ignores the line, and `visudo -c` rejects the file:

```text
/etc/sudoers:6:26: syntax error: unknown setting: 'tty_tickets'
visudo: invalid sudoers file
```

```text
/etc/sudoers:10:17: syntax error: unknown setting: 'logfile'
visudo: invalid sudoers file
```

- `tty_tickets`: remove it. Per-terminal credential caching is already the default in both implementations.
- `logfile`: remove it. `sudo-rs` logs to syslog (`/var/log/auth.log`) and has no log file option.

`sudo -E` is ignored, with a warning:

```text
sudo: preserving the entire environment is not supported, '-E' is ignored
```

Pass specific variables with `--preserve-env=VAR1,VAR2`, or set them in the command itself.

## cgroup v1 Removed

The Resolute kernel doesn't support cgroup v1 at all, so there's no way to bring it back. If your release still reads cgroup v1 paths or asks for the `legacy` or `hybrid` hierarchy, follow [systemd and cgroup v2](noble-migration.md#systemd-and-cgroup-v2) in the Noble guide.

## Python, `apt-key`, `libcrypt`, and `pkgconf`

- **Python 3.14.** The stemcell's system Python is 3.14 (Noble had 3.12). `python3-six` and `python3-netifaces` are no longer installed. Releases should ship their own Python rather than rely on the system one; see [bosh-package-python-release](https://github.com/cloudfoundry/bosh-package-python-release).
- **`apt-key` is gone.** A job that calls it fails with `apt-key: command not found`. Put keyrings in `/usr/share/keyrings/` or `/etc/apt/keyrings/`, and point to them with `signed-by=` in the APT source.
- **Link `crypt()` explicitly.** Code that calls `crypt()` without linking `libcrypt` fails at link time:

    ```text
    f.c:(.text+0x1d): undefined reference to `crypt'
    collect2: error: ld returned 1 exit status
    ```

    Add `-lcrypt`. The stemcell's own monit build now passes `LIBS='-lcrypt'` to `./configure`.

- **`pkgconf`.** `pkg-config` on the stemcell is now [pkgconf](https://github.com/pkgconf/pkgconf). garden-runc-release replaced its vendored `pkg-config` 0.29.2 package with a `pkgconf` 2.5.1 package.

## Library Changes

These libraries in the Noble stemcell are replaced or removed in Resolute:

| Noble | Resolute |
|---|---|
| `libicu74`, `libicu-dev` | `libicu78`, no `-dev` package. Bundle ICU if you compile against it, as pxc-release does. |
| `libssh-4` | `libssh2-1t64`. libssh2 is a different project, not a new version of libssh. |
| `libxml2` | `libxml2-16` |
| `libargon2-1` | Removed |
| `libfuse3-3` | `libfuse3-4` |
| `libjsoncpp25` | `libjsoncpp26` |
| `libperl5.38t64` | `libperl5.40` |

The complete package list is [`dpkg-list-ubuntu.txt`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/ubuntu-resolute/bosh-stemcell/spec/assets/dpkg-list-ubuntu.txt) in the stemcell builder. Compare it with the [`ubuntu-noble` version](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/ubuntu-noble/bosh-stemcell/spec/assets/dpkg-list-ubuntu.txt).

## Missing Kernel Modules

The Resolute stemcell removes about 6,000 kernel modules that cloud VMs don't need. If your job loads a module that was removed, `modprobe` fails with:

```text
modprobe: FATAL: Module <name> not found in directory /lib/modules/<kernel-version>
```

The kept and removed modules are listed, with reasons, in [`linux-generic.csv`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/ubuntu-resolute/stemcell_builder/stages/system_kernel_modules/linux-generic.csv). To get a module back, open an issue or a pull request against [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder) that changes its row to `remove=No`, and explain what uses it.

## systemd

- **Last release with SysV compatibility.** Resolute's systemd (259) still runs SysV init scripts, but Ubuntu 26.04 is the last LTS that will. BOSH jobs run under monit and aren't affected. If your job installs an init script in `/etc/init.d`, replace it with a systemd unit or a monit-managed process before the next stemcell line.
- **`/tmp` isn't a tmpfs.** Ubuntu 26.04 makes `/tmp` a tmpfs by default, but the stemcell masks `tmp.mount`, and `/tmp` stays on the ephemeral disk as on Noble. Don't depend on either. Keep using `/var/vcap/data/<job>/` or `/var/vcap/data/tmp` for scratch space.

## Testing Your Release

- **Compile on the warden stemcell.** The Resolute warden stemcell is the quickest way to find compilation errors. Upload it to a bosh-lite or docker-CPI director, and deploy a manifest that uses `os: ubuntu-resolute`.
- **Apple Silicon.** Resolute warden stemcells don't yet run under Rosetta 2 ([bosh-linux-stemcell-builder#577](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/issues/577)). A `-rosetta` warden variant for Apple Silicon bosh-lite is available, but test on x86-64 if Rosetta gives you problems.
- **CI.** Stemcell lines come and go, so ideally structure your pipelines to test all of them. Add an `ubuntu-resolute` job to your pipeline next to your existing stemcell lines, and keep it running.
- **Compiled releases.** When your release works, publish a version compiled against `ubuntu-resolute` so that operators don't have to compile it. See [Compiled Releases](compiled-releases.md).

## Addons in Example Manifests

If your release ships example manifests, ops files, or runtime configs that scope jobs with `include.stemcell` or `exclude.stemcell`, add `ubuntu-resolute`:

```yaml
addons:
- name: my-addon
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
    - os: ubuntu-resolute
```

If an example adds bpm as an addon, don't add `ubuntu-resolute` to that one. The stemcell already includes bpm.

## Getting Help

Ask in [`#bosh`](https://cloudfoundry.slack.com/messages/C02HPPYQ2/) on the Cloud Foundry Slack. Report stemcell problems as [bosh-linux-stemcell-builder issues](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/issues).
