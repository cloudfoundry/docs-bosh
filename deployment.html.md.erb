---
title: What is a Deployment?
---

A deployment is a collection of VMs, built from a [stemcell](stemcell.html), that has been populated with specific [releases](release.html) and disks that keep persistent data. These resources are created based on a manifest file in the IaaS and managed by the BOSH Director, a centralized management server.

The deployment process begins with deciding which Operating System images (stemcells) need to be used and which software (releases) need to be deployed, how to track persistent data while a cluster is updated and transformed, and how to automate steps of deploying images to an IaaS; this includes configuring machines to use said image, and placing correct software versions onto provisioned machines. BOSH builds upon previously introduced primitives (stemcells and releases) by providing a way to state an explicit combination of stemcells, releases, and operator-specified properties in a human readable file. This file is called a deployment manifest.

When a deployment manifest is uploaded to a BOSH Director, requested resources are allocated and stored. These resources form a deployment. The deployment keeps track of associated VMs and persistent disks that are attached to the VMs. Over time, as the deployment manifest changes, VMs are replaced and updated. However, persistent disks are retained and are re-attached to the newer VMs.

A user can manage a deployment via its deployment manifest. A deployment manifest contains all needed information for tracking, managing, and updating software on the deployment's VMs. It describes the deployment in an IaaS-agnostic way [1]. For example, to update a Redis cluster (deployment is named 'redis-us') to a later version of a Redis release, one would update few lines in the deployment manifest:

```yaml
---
name: redis-us

releases:
- name: redis
  version: 15.9 # <--- bump version

resource_pools:
- name: all-machines
  stemcell:
    name: bosh-aws-xen-ubuntu-trusty-go_agent
    version: 2972
  network: default
  cloud_properties:
    instance_type: m1.small
    availability_zone: us-east-1a
...
```

[1] There are differences in the deployment manifest depending on which IaaS is used. These differences capture IaaS specific features that the operator decides to use.

---
[Back to Table of Contents](index.html#intro)

Previous: [What is a Release?](release.html)
