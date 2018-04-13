---
title: Build Deployment Manifest
---

(See [What is a Deployment?](deployment.md) for an introduction to deployments.)

A deployment is a collection of VMs, persistent disks and other resources. To create a deployment in the Director, it has to be described with a [deployment manifest](terminology.md#manifest). Most deployment manifests look something like this:

```yaml
---
name: zookeeper

releases:
- name: zookeeper
  version: 0.0.5
  url: https://bosh.io/d/github.com/cppforlife/zookeeper-release?v=0.0.5
  sha1: 65a07b7526f108b0863d76aada7fc29e2c9e2095

stemcells:
- alias: default
  os: ubuntu-trusty
  version: latest

update:
  canaries: 2
  max_in_flight: 1
  canary_watch_time: 5000-60000
  update_watch_time: 5000-60000

instance_groups:
- name: zookeeper
  azs: [z1, z2, z3]
  instances: 5
  jobs:
  - name: zookeeper
    release: zookeeper
    properties: {}
  vm_type: default
  stemcell: default
  persistent_disk: 10240
  networks:
  - name: default

- name: smoke-tests
  azs: [z1]
  lifecycle: errand
  instances: 1
  jobs:
  - name: smoke-tests
    release: zookeeper
    properties: {}
  vm_type: default
  stemcell: default
  networks:
  - name: default
```

(Taken from <https://github.com/cppforlife/zookeeper-release/blob/master/manifests/zookeeper.yml>)

Here is how deployment manifest describes a reasonably complex Zookeeper cluster:

- Zookepeer source code, configuration file, startup scripts
  - include `zookeeper` release version `0.0.5` to the `releases` section
- Operating system image onto which install software
  - include latest version of `ubuntu-trusty` stemcell
- Create 5 Zookeeper VMs spread
  - add `zookeeper` [instance group](terminology.md#instance-group) with `instances: 5`
- Spread VMs over multiple availability zones
  - add `azs: [z1, z2, z3]`
- Install Zookeeper software onto VMs
  - add `zookeeper` job to this instance group
- Size VMs in the same way
  - add `vm_type: default` which references VM type from cloud config
- Attach a 10GB [persistent disk](terminology.md#persistent-disk) to each Zookeeper VM
  - add `persistent_disk: 10240` to `zookeeper` instance group
- Place VMs onto some [network](networks.md)
  - add `networks: [{name: default}]` to `zookeeper` instance group
- Provide a way to smoke test Zookeeper cluster
  - add `smoke-tests` instance group with `smoke-tests` job from Zookeeper release

Refer to [manifest v2 schema](manifest-v2.md) for detailed breakdown.

Once manifest is complete referenced stemcells and releases must be uploaded.
