# Migrating to Resolute Raccoon: For Platform Engineers

**Who this is for:** operators moving BOSH deployments onto the Ubuntu 26.04 "Resolute Raccoon" stemcell. If you maintain a BOSH release, read the [Release Author guide](resolute-release-migration.md) instead.

!!! note
    **Coming from Jammy?** Work through the [Noble migration guide](noble-migration.md) first; everything below assumes those changes are done. The systemd-managed agent, cgroup v2, BOSH DNS via `systemd-resolved`, and the EFI bootloader all arrived with Noble and are not repeated here.

This page covers what changes for a platform: manifest and runtime config edits, and runtime behaviour you'll see on Resolute VMs. It doesn't require you to change any release source.

## Why and When

Ubuntu 22.04 (Jammy) leaves Canonical's standard support in May 2027. Resolute is the next LTS, and it brings post-quantum cryptography to OpenSSL and OpenSSH (ML-KEM, ML-DSA, and SLH-DSA), which Noble doesn't have.

Resolute stemcells are published as `0.x` versions while the line is in alpha. The line moves to `1.x` at GA. See [Stemcell Lines & Support](stemcell-lines.md) for the current status.

Jammy users can go straight to Resolute, but the Noble changes still apply: do the [Noble migration guide](noble-migration.md) first, then this page.

## BOSH DNS

The `configure_systemd_resolved` runtime config from the [Noble guide](noble-migration.md#bosh-dns) still applies on Resolute. Its `include.stemcell` list must contain `ubuntu-resolute`:

```yaml
- include:
    stemcell:
    - os: ubuntu-noble
    - os: ubuntu-resolute
  jobs:
  - name: bosh-dns
    properties:
      configure_systemd_resolved: true
      disable_recursors: true
      override_nameserver: false
      # ... other properties as in the Noble guide
    release: bosh-dns
  name: bosh-dns-systemd
```

The current [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) `runtime-configs/dns.yml` already includes `ubuntu-resolute`. If you use the latest bosh-deployment, you can skip this step.

!!! warning
    If `ubuntu-resolute` is missing from this list, bosh-dns is silently skipped on Resolute VMs. The deploy then fails later, when links don't resolve.

## Check Your Releases First

Every release in a deployment has to support Resolute before you can move that deployment. Check each release's notes for Resolute support, and ask its maintainers if they don't mention it.

A release that doesn't support Resolute usually fails in one of two ways:

- **Compilation fails.** Resolute ships GCC 15 and CMake 4, which reject code that compiled on Noble.
- **A job doesn't start.** The Resolute stemcell doesn't include `runit`, so the `chpst` command is gone. The job's logs under `/var/vcap/sys/log/<job>/` show:

    ```text
    chpst: command not found
    ```

    or, from `/bin/sh` scripts:

    ```text
    chpst: not found
    ```

The fixes for both belong in the release. Point its maintainers at the [Release Author guide](resolute-release-migration.md).

## Addons (Runtime Configurations)

If you restrict your addons to certain stemcells, add `ubuntu-resolute` to every `include.stemcell` list for addons that should run on Resolute. Addons scoped to an OS that isn't listed are silently skipped.

Before:

```yaml
addons:
- name: loggregator_agent
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
```

After:

```yaml
addons:
- name: loggregator_agent
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
    - os: ubuntu-resolute
```

Check `exclude.stemcell` lists too.

## BPM

[BPM](bpm/bpm.md) is installed in the Resolute stemcell. Jobs can use it without the bpm-release job colocated in the instance group.

Colocating the bpm job still works, but we discourage it on Resolute. When the bpm job is colocated, its version of bpm is used instead of the stemcell's on that instance.

If your platform deploys both older stemcells and Resolute, and you add bpm as an addon, scope that addon to the older stemcells:

```yaml
addons:
- name: bpm
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
  jobs:
  - name: bpm
    release: bpm
```

## IaaS Notes

- **No instance-type changes.** Ubuntu 26.04 cloud images target the `x86-64-v3` microarchitecture level, which drops older instance families. The BOSH stemcell is still built for baseline `x86-64`, so every instance type that runs Noble stemcells also runs Resolute. EFI boot behaves as described in the [Noble guide](noble-migration.md#efi-bootloader).
- **Light stemcells.** Light stemcells are published for AWS and Google Cloud, as for earlier lines. Use full stemcells on other IaaSes.

## Runtime Behaviour Changes

### SSH

Resolute ships OpenSSH 10.2.

- DSA keys don't work. The stemcell generates no DSA host key, and DSA client keys are rejected. Replace any DSA keys with Ed25519, ECDSA, or RSA keys.
- The post-quantum key exchange `mlkem768x25519-sha256` is on by default. The `ssh` client on a Resolute VM prints a warning when it connects to a server that can't negotiate a post-quantum key exchange. Jobs or scripts that SSH from Resolute VMs to older servers see this warning.
- `sshd` no longer reads `~/.pam_environment`. Set environment variables for `bosh ssh` sessions some other way.

### sudo-rs

`sudo` is now [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs), a Rust implementation. Most uses are unchanged. What differs:

- `sudo-rs` doesn't support some sudoers settings that classic sudo accepted, including `tty_tickets` and `logfile`. When a sudoers file uses one, every `sudo` call prints an `unknown setting` error and ignores that line, and `visudo -c` reports the file as invalid. Remove these settings from any sudoers files that your addons or `os-conf` configuration write.
- `sudo -E` is ignored, with the warning `sudo: preserving the entire environment is not supported, '-E' is ignored`. `--preserve-env=VAR` works.
- sudo activity is logged to syslog (`/var/log/auth.log`), not to a dedicated `/var/log/sudo.log`.

### Kernel Modules

Ubuntu 26.04 no longer splits kernel modules into a separate "extra" package, so the stock kernel carries nearly 7,000 modules. The Resolute stemcell removes most of them: the ones for hardware that doesn't exist on cloud VMs, and obsolete protocols and filesystems that are a frequent source of CVEs. About 750 remain, covering hypervisor guest drivers, storage, networking, netfilter, container networking, cryptography, and network filesystems.

If a job needs a module that was removed, `modprobe` fails with:

```text
modprobe: FATAL: Module <name> not found in directory /lib/modules/<kernel-version>
```

The list of kept and removed modules, with the reason for each, is in [`linux-generic.csv`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/ubuntu-resolute/stemcell_builder/stages/system_kernel_modules/linux-generic.csv) in the stemcell builder. To get a module back, open an issue or a pull request against [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder) that changes its row to `remove=No`, and say what needs it.

This doesn't apply to warden stemcells, which use the host's kernel.

### `/tmp` Is Still Disk-Backed

Ubuntu 26.04 makes `/tmp` a tmpfs by default. The Resolute stemcell masks that unit, and the BOSH agent bind-mounts `/tmp` from the ephemeral disk as it does on Noble, so nothing changes for BOSH VMs. We call it out because Ubuntu's own release notes say otherwise.

### cgroup v2 Only

The Resolute kernel has no cgroup v1 support. Noble already used the cgroup v2 unified hierarchy, but on Resolute there's no fallback: anything that expects cgroup v1 paths fails. See [systemd and cgroup v2](noble-migration.md#systemd-and-cgroup-v2) in the Noble guide.

### syslog TLS

The stemcell includes `rsyslog-gnutls` but no longer includes `rsyslog-openssl`. If you set the syslog-release property `syslog.tls_library: ossl`, forwarding over TLS fails on Resolute. Use the default, `gtls`.

### Time Sync

`systemd-timesyncd` is no longer installed. chrony, which BOSH stemcells already used for time sync, is the only time daemon.

### Audit and Compliance Scanning

- `sudo-rs` can't write a log file. sudo events go to `/var/log/auth.log` instead.
- Audit rules no longer watch the `stime` syscall, which Linux 7.0 removed.
- `auvirt` and `autrace` are no longer shipped with `auditd`.
- On warden stemcells, `audit-rules.service` is skipped: the kernel rejects audit rule changes from inside a container. Don't expect audit records from warden containers.

### bosh-lite on Apple Silicon

Resolute warden stemcells don't run under Rosetta 2 emulation on Apple Silicon ([bosh-linux-stemcell-builder#577](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/issues/577)). A `-rosetta` warden stemcell variant for Apple Silicon bosh-lite is available. It is for local development only, not production.

## Getting Help

Ask in [`#bosh`](https://cloudfoundry.slack.com/messages/C02HPPYQ2/) on the Cloud Foundry Slack. Report stemcell problems as [bosh-linux-stemcell-builder issues](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/issues).
