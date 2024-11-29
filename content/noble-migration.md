Cloud Foundry's upcoming stemcells will be based on Ubuntu's [Noble Numbat](https://wiki.ubuntu.com/Releases) release, which may cause compilation and deployment errors in packages built for earlier stemcells. This document provides guidance on how to address the most common errors that BOSH release authors may encounter. There are three broad categories to address:

- BOSH DNS — see [below](#bosh-dns)
- BPM — see [below](#bpm)
- EFI bootloader - see [below](#efi-bootloader)
- Addons - see [below](#addons-runtime-configurations)

Discussion Slack channel is [here](https://cloudfoundry.slack.com/archives/C06HTDT78N9).

### BOSH DNS

In Noble we switched from resolved to systemd-resolve, with this change and to be backwards compatible with our bosh-dns release some configuration are necessary in the runtime config for DNS.
if you are uing the latest bosh-deployment or bosh bootloader. than you can ignore this.

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

### BPM

use BPM version v1.4.0 or higher [bpm-releases](https://github.com/cloudfoundry/bpm-release/releases)

### EFI Bootloader

The Noble stemcells will use by default the EFI bootloader with a fallback to the legacy bootloader.
What this will mean in a real life example for AWS.
the vm type `m4.large` (which is deprecated) only supports legacy bootloader
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

this will mean when you use the m4.large it will boot in legacy bootloader and for m5.large you will boot with the efi bootloader.
you can easily check with which bootloader you started by checking if the following file exists `ls /sys/firmware/efi` if this file exists your in EFI mode and if not your using the legacy bootloader.


### Addons (Runtime Configurations)

If you restrict your addons to certain stemcells, be sure to include Noble in your list of stemcells (if you intend your addon to run on Noble). The following is the updated stemcell list for [cf-deployment](https://github.com/cloudfoundry/cf-deployment)'s manifest:

```yaml
addons:
- name: loggregator_agent
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-noble
```
