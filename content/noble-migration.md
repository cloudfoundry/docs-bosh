# Migrating to Noble Numbat

Cloud Foundry's upcoming stemcells will be based on Ubuntu's [Noble Numbat](https://wiki.ubuntu.com/Releases) release, which may cause compilation and deployment errors in packages built for earlier stemcells. This document provides guidance on how to address the most common errors that BOSH release authors may encounter. There are a few broad categories to address:

- BOSH DNS — see [below](#bosh-dns)
- BPM — see [below](#bpm)
- systemd and cgroup v2 — see [below](#systemd-and-cgroup-v2)
- EFI bootloader - see [below](#efi-bootloader)
- Addons - see [below](#addons-runtime-configurations)

Discussion Slack channel is [here](https://cloudfoundry.slack.com/archives/C06HTDT78N9).

!!! note
    **Heading for Resolute Raccoon (Ubuntu 26.04)?** Work through this page first, then follow the Resolute migration guide ([platform engineers](resolute-migration.md), [release authors](resolute-release-migration.md)) — it describes the delta from Noble and assumes the changes below are already done.

## BOSH DNS

In Noble we switched from resolved to systemd-resolve, with this change and to be backwards compatible with our bosh-dns release some configuration are necessary in the runtime config for DNS.
If you are using the latest bosh-deployment or bosh bootloader, then you can ignore this.

With the following PR in bosh-deployment repo [#467](https://github.com/cloudfoundry/bosh-deployment/pull/467)
we added the following configuration.

```yaml
- include:
    stemcell:
      - os: ubuntu-noble
  jobs:
    - name: bosh-dns
      properties:
        api:
          client:
            tls: ((/dns_api_client_tls))
          server:
            tls: ((/dns_api_server_tls))
        cache:
          enabled: true
        configure_systemd_resolved: true
        disable_recursors: true
        health:
          client:
            tls: ((/dns_healthcheck_client_tls))
          enabled: true
          server:
            tls: ((/dns_healthcheck_server_tls))
        override_nameserver: false
      release: bosh-dns
  name: bosh-dns-systemd
```

## BPM

Use BPM version v1.4.0 or higher [bpm-releases](https://github.com/cloudfoundry/bpm-release/releases)

## systemd and cgroup v2

On Noble the BOSH agent runs under systemd, and the stemcell uses the **cgroup v2 unified hierarchy**. Jobs and monitoring code that read cgroup v1 controller paths, or that select the `legacy` / `hybrid` hierarchy, need to move to the v2 equivalents:

```text
# cgroup v1
/sys/fs/cgroup/memory/<...>/memory.limit_in_bytes
/sys/fs/cgroup/cpu/<...>/cpu.cfs_quota_us

# cgroup v2
/sys/fs/cgroup/<...>/memory.max
/sys/fs/cgroup/<...>/cpu.max
```

Container runtimes such as garden-runc and containerd already speak cgroup v2, so this mainly affects bespoke resource-limiting or metrics code. Do this migration properly rather than forcing the v1 hierarchy back on: cgroup v1 is removed outright in Ubuntu 26.04, where there is no fallback.

## EFI Bootloader

The Noble stemcells will use by default the EFI bootloader with a fallback to the legacy bootloader.
What this will mean in a real life example for AWS.
The vm type `m4.large` (which is deprecated) only supports legacy bootloader
you can see what the vm type support with the following command `aws ec2 describe-instance-types --region us-east-1 --instance-types m4.large --query "InstanceTypes[*].SupportedBootModes"`
this will result in

```json
[
    [
        "legacy-bios",
    ]
]
```

and for `m5.large`

```json
[
    [
        "legacy-bios",
        "uefi"
    ]
]
```

This will mean when you use the `m4.large` it will boot in legacy bootloader and for `m5.large` you will boot with the efi bootloader.
You can easily check with which bootloader you started by checking if the following file exists `ls /sys/firmware/efi` if this file exists you are in EFI mode and if not you are using the legacy bootloader.

## Addons (Runtime Configurations)

If you restrict your addons to certain stemcells, be sure to include Noble in your list of stemcells (if you intend your addon to run on Noble). The following is the updated stemcell list for [cf-deployment](https://github.com/cloudfoundry/cf-deployment)'s manifest:

```yaml
addons:
- name: loggregator_agent
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
```
