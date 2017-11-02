---
title: Renaming/migrating instance groups
---

Occasionally, it's convenient to rename one or more instance groups as their purpose changes or as better names are found. In most cases it's desirable to maintain existing persistent data by keeping existing persistent disks.

Previously, the CLI provided the `rename job` command to rename a specific instance group one at a time. That approach worked OK in non-automated, non-frequently updated environments, but it was inconvenient for automated, frequently updated environments. As a replacement, the `migrated_from` directive was added to allow renames to happen in a more systematic way.

Additionally `migrated_from` directive can be used to migrate instance groups to use first class AZs.

---
## <a id='schema'></a> Schema

**migrated_from** [Array, required]: The name and AZ of each instance group that should be used to form new instance group.

* **name** [String, required]: Name of an instance group that used to exist in the manifest.
* **az** [String, optional]: Availability zone that was used for the named instance group. This key is optional for instance groups that used first class AZs (via `azs` key). If first class AZ was not used, then this key must specify first class AZ that matches actual IaaS AZ configuration.

---
## <a id="rename"></a> Renaming Instance Groups

1. Given follow deployment instance group `etcd`:

    ```yaml
    instance_groups:
    - name: etcd-primary
      instances: 2
      jobs:
      - {name: etcd, release: etcd}
      vm_type: default
      stemcell: default
      persistent_disk: 10_240
      networks:
      - name: default
    ```

1. Change instance group's name to `etcd` and add `migrated_from` with a previous name.

    ```yaml
    instance_groups:
    - name: etcd
      instances: 2
      jobs:
      - {name: etcd, release: etcd}
      vm_type: default
      stemcell: default
      persistent_disk: 10_240
      networks:
      - name: default
      migrated_from:
      - name: etcd-primary
    ```

1. Deploy.

---
## <a id="migrate"></a> Migrating Instance Groups (to first class AZs)

Before the introduction of first class AZs, each instance group was associated with a resource pool that typically defined some CPI specific AZ configuration in its `cloud_properties`. Typically there would be multiple instance groups that mostly differed by their name, for example `etcd_z1` and `etcd_z2`. With first class AZs, multiple instance groups typically should be collapsed to simplify the deployment.

1. Given following instance groups `etcd_z1` and `etcd_z2` with AZ specific resource pools and networks:

    ```yaml
    instance_groups:
    - name: etcd_z1
      instances: 2
      jobs:
      - {name: etcd, release: etcd}
      persistent_disk: 10_240
      resource_pool: medium_z1
      networks:
      - name: default_z1

    - name: etcd_z2
      instances: 1
      jobs:
      - {name: etcd, release: etcd}
      persistent_disk: 10_240
      resource_pool: medium_z2
      networks:
      - name: default_z2
    ```

1. Collapse both instance groups into a single instance group `etcd` and use `migrated_from` with previous group names.

    ```yaml
    instance_groups:
    - name: etcd
      azs: [z1, z2]
      instances: 3
      jobs:
      - {name: etcd, release: etcd}
      vm_type: default
      stemcell: default
      persistent_disk: 10_240
      networks:
      - name: default
      migrated_from:
      - {name: etcd_z1, az: z1}
      - {name: etcd_z2, az: z2}
    ```

    <p class="note">Note that other referenced resources such as resource pool and network should be adjusted to work with AZs.</p>

    <p class="note">Note: Migration from one AZ to a different AZ is not supported yet.</p>

1. Deploy.
