---
title: Sample BOSH Deployment Manifest
---

The following is a sample BOSH deployment manifest. See [Understanding the BOSH Deployment Manifest](./deployment-manifest.html) for an explanation of the manifest contents.

```yaml
---
name: my-redis-deployment
director_uuid: 1234abcd-5678-efab-9012-3456cdef7890

releases:
- {name: redis, version: 12}

resource_pools:
- name: redis-servers
  network: default
  stemcell:
    name: bosh-aws-xen-ubuntu-trusty-go_agent
    version: 2708
  cloud_properties:
    instance_type: m1.small
    availability_zone: us-east-1c

networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    static:
    - 10.10.0.16 - 10.10.0.18
    reserved:
    - 10.10.0.2 - 10.10.0.15
    dns: [10.10.0.6]
    cloud_properties:
      subnet: subnet-d597b993

compilation:
  workers: 2
  network: default
  reuse_compilation_vms: true
  cloud_properties:
    instance_type: c1.medium
    availability_zone: us-east-1c

update:
  canaries: 1
  max_in_flight: 3
  canary_watch_time: 15000-30000
  update_watch_time: 15000-300000

jobs:
- name: redis-master
  instances: 1
  templates:
  - {name: redis-server, release: redis}
  persistent_disk: 10_240
  resource_pool: redis-servers
  networks:
  - name: default

- name: redis-slave
  instances: 2
  templates:
  - {name: redis-server, release: redis}
  persistent_disk: 10_240
  resource_pool: redis-servers
  networks:
  - name: default

properties:
  redis:
    max_connections: 10
```
