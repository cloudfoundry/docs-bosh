!!! note
    This document was updated to mention orphaned disks introduced in bosh-release v241+ (1.3163.0).

Instance groups may need to store persistent data.

If you attach a persistent disk to a virtual machine and then delete the VM via `bosh delete-vm`, your
persistent disk data remains intact. Attaching the persistent disk to another VM allows you to access your data.

!!! warning
    If you terminate or delete a VM ***from your IaaS console***, the fate of the persistent disk depends on the IaaS provider. For example, in AWS, the default behavior is to keep the     persistent disk when you delete a VM. However, if you right click and pick "Delete from Disk" on a VM in vSphere, the persistent disk is permanently destroyed.

Persistent disks are kept for each instance under the following circumstances:

* updating deployment to use new releases or stemcells
* using cloud check to recover deleted VMs
* instances are hard stopped and later started again

As of bosh-release v241+ (1.3163.0), the Director no longer deletes persistent disks that are no longer needed. Unnecessary persistent disks will be marked as orphaned so that they can be garbage collected after 5 days.

The following conditions result in persistent disks to be marked as orphaned:

* instance group no longer specifies a persistent disk size or a disk pool
* instance group changes the size or cloud properties of a disk
* instance group is renamed without `migrated_from` configuration
* instance group is scaled down
* instance group is deleted or AZ assignment is removed
* deployment is deleted

You can specify that an instance group needs an attached persistent disk in one of two ways:

* [Persistent Disk declaration](#persistent-disk)
* [Persistent Disk Pool declaration](#persistent-disk-pool)

---
## Persistent Disk Declaration {: #persistent-disk }

To specify that an instance group needs an attached persistent disk, add a `persistent_disk` key-value pair to the instance group in the [Jobs](deployment-manifest.md#jobs) block of your deployment manifest.

The `persistent_disk` key-value pair specifies the persistent disk size, and defaults to 0 (no persistent disk). If the `persistent_disk` value is a positive integer, BOSH creates a persistent disk of that size in megabytes and attaches it to each instance VM for the job.

Example:

```yaml
instance_groups:
- name: redis
  jobs:
  - {name: redis, release: redis}
  instances: 1
  resource_pool: default
  persistent_disk: 1024
  networks:
  - name: default
```

!!! note
    If you use persistent disk declaration, you cannot specify the persistent disk type that the CPI attaches to your job VMs. Instead, the CPI uses its default disk configuration when deploying the VMs.

---
## Persistent Disk Pool Declaration {: #persistent-disk-pool }

To specify that an instance group needs an attached persistent disk, add a [Disk Pool](deployment-manifest.md#disk-pools) block to your deployment manifest.

The persistent disk pool declaration allows you to specify the precise type and size of the persistent disks attached to your instance group VMs.

* **persistent\_disk_pool** [String, optional]: Associated with an instance group; specifies a particular disk_pool.

* **disk_pools** [Array, optional]: Specifies the [disk_pools](terminology.md#disk-pool) a deployment uses. A deployment manifest can describe multiple disk pools and uses unique names to identify and reference them.

    * **name** [String, required]: A unique name used to identify and reference the disk pool.
    * **disk_size** [Integer, required]: Size of the disk in megabytes.
    * **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create disk. Examples: `type`, `ops`

Example:

```yaml
disk_pools:
- name: my-fast-disk
  disk_size: 1_024
  cloud_properties: {type: gp2}

- name: my-standard-disk
  disk_size: 1_024
  cloud_properties: {type: standard}

instance_groups:
- name: redis
  jobs:
  - {name: redis, release: redis}
  instances: 1
  resource_pool: default
  persistent_disk_pool: my-fast-disk
  networks:
  - name: default
```

---
## Checking Stats {: #checking-stats }

After your deployment completes, run `bosh vms --vitals` from a terminal window to view persistent disk usage percentage values under `Persistent Disk Usage`.

---
## Accessing Persistent Disks {: #accessing-persistent-disk }

The CPI mounts persistent disks `/var/vcap/store` on deployed VMs, and persists any files stored in `/var/vcap/store`.

You specify jobs using the `jobs` key when defining a instance group. By convention, each job creates a self-named directory in `/var/vcap/store` and sets the correct permissions on this directory.

For example, a `redis` job creates the following directory: `/var/vcap/store/redis`

---
## Changing Disk Properties {: #changing-persistent-disk }

BOSH allows you to change disk types and sizes by modifying the deployment manifest. As long as the instance group name stays the same, data on existing persistent disks will be migrated onto new persistent disks. Old persistent disks will be marked as orphaned.

During the disk migration from one disk type and size to another, the Director communicates with the Agent to attach both existing and newly created disk to the same VM and copy over any existing data. After the transfer successfully completes, the Director deletes the original disk and keeps the new disk attached to the VM instance.

!!! note
    An IaaS might disallow attaching particular disk types and sizes to certain VM types. Consult your IaaS documentation for more information.

---
## Orphaned Disks {: #orphaned-disks }

Orphaned persistent disks are not attached to any VM and are not associated with any deployment. You can list orphaned disks known to the Director via [`bosh disks --orphaned` command](sysadmin-commands.md#disks). If deployment changes were done erroneously and you would like to reattach specific orphaned persistent disk to an instance follow these steps:

- run `bosh stop name/id` command to stop instance (or multiple instances) for repair
- run [`bosh attach-disk name/id disk-cid` command](sysadmin-commands.md#disks) to attach disk to given instance
- run `bosh start name/id` command to resume running instance workload

For example, to re-attach the disk:

`bosh attach-disk redis/a4ecc903-e342-4a40-8a59-4c9e4aeba28d 1c13b266-6e14-4124-51f6-24ec3bc05344`

!!! note
    `attach-disk` command can also attach available disks found in the IaaS. They don't have to be listed in the orphaned disks list.

Orphaned disks are deleted after [5 days by default](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.disks). You can decide to clean up orphaned disks manually with `bosh clean-up --all` or one-by-one with `bosh delete-disk`.
