---
title: Update Cloud Config
---

!!! note
    Document uses CLI v2.

The [cloud config](terminology.md#cloud-config) is a YAML file that defines IaaS specific configuration used by all deployments. It allows to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

Here is an example cloud config used with [BOSH Lite](terminology.md#bosh-lite):

```yaml
---
azs:
- name: z1
- name: z2
- name: z3

vm_types:
- name: default

disk_types:
- name: default
  disk_size: 1024

networks:
- name: default
  type: manual
  subnets:
  - azs: [z1, z2, z3]
    dns: [8.8.8.8]
    range: 10.244.0.0/24
    gateway: 10.244.0.1
    static: [10.244.0.34]
    reserved: []

compilation:
  workers: 5
  az: z1
  reuse_compilation_vms: true
  vm_type: default
  network: default
```

(Taken from <https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml>)

Without going into much detail, above cloud config defines three [availability zones](terminology.md#az), one `default` [VM type](terminology.md#vm-type) and one `default` [disk types](terminology.md#disk-type) and a `default` [network](networks.md). All of these definitions will be referenced by the deployment manifest.

See [cloud config schema](cloud-config.md) for detailed breakdown.

To configure Director with above cloud config use [`bosh update-cloud-config` command](cli-v2.md#update-cloud-config):

```shell
$ bosh -e vbox update-cloud-config cloud-config.yml
```
