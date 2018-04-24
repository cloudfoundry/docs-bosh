---
title: CPI API v1
---

For an overview of the sequence of CPI calls, the following resources are helpful:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)

---
## Glossary {: #glossary }

- **cloud ID** is an ID (string) that the Director uses to reference any created infrastructure resource; typically CPI methods return cloud IDs and later receive them. For example AWS CPI's `create_vm` method would return `i-f789df` and `attach_disk` would take it.

- **cloud_properties** is a hash that can be specified for several objects (resource pool, disk pool, stemcell, network) to provide infrastructure specific settings to the CPI for that object. Only CPIs know the meaning of its contents. For example resource pool's `cloud_properties` for AWS can specify `instance_type`:

```yaml
resource_pools:
- name: large_machines
  cloud_properties: {instance_type: r3.8xlarge}
```

---
## CPI Info {: #cpi-info }

### `info` {: #info }

Returns information about the CPI to help the Director to make decisions on which CPI to call for certain operations in a multi CPI scenario.

#### Arguments

No arguments

#### Returned

- **stemcell_formats** [Array of strings]: Stemcell formats supported by the CPI. Currently used in combination with `create_stemcell` by the Director to determine which CPI to call when uploading a stemcell.

---
## Stemcell management {: #stemcells }

### `create_stemcell` {: #create-stemcell }

Creates a reusable VM image in the IaaS from the [stemcell](stemcell.md) image. It's used later for creating VMs. For example AWS CPI creates an AMI and returns AMI ID.

See [Stemcell Building](build-stemcell.md) for more details.

#### Arguments

- **image_path** [String]: Path to the stemcell image extracted from the stemcell tarball on a local filesystem.
- **cloud_properties** [Hash]: Cloud properties hash extracted from the stemcell tarball.

##### Example

```yaml
[
	"/tmp/extracted-stemcell-348754vdsn87fr/image",
	{
		"name": "bosh-openstack-esxi-ubuntu-trusty-go_agent",
		"version": "2972",
		"infrastructure": "openstack",
		"hypervisor": "esxi",
		"disk": 3072,
		"disk_format": "ovf",
		"container_format": "bare",
		"os_type": "linux",
		"os_distro": "ubuntu",
		"architecture": "x86_64",
		"auto_disk_config": true
	}
]
```

#### Returned

- **stemcell_cid** [String]: Cloud ID of the created stemcell (e.g. stemcells in AWS CPI are made into AMIs so cid .would be `ami-83fdflf`)

[Example create_stemcell.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_stemcell.go)

---
### `delete_stemcell` {: #delete-stemcell }

Deletes previously created stemcell. Assume that none of the VMs require presence of the stemcell.

#### Arguments

- **stemcell_cid** [String]: Cloud ID of the stemcell to delete; returned from `create_stemcell`.

#### Returned

No return value

[Example delete_stemcell.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/delete_stemcell.go)

---
## VM management {: #vm }

### `create_vm` {: #create-vm }

Creates a new VM based on the stemcell. Created VM must be powered on and accessible on the provided networks.

Waiting for the VM to finish booting is not required because the Director waits until the Agent on the VM responds back.

Make sure to properly delete created resources if VM cannot be successfully created.

#### Arguments

- **agent_id** [String]: ID selected by the Director for the VM's agent.
- **stemcell_cid** [String]: Cloud ID of the stemcell to use as a base image for new VM.
- **cloud_properties** [Hash]: Cloud properties hash specified in the deployment manifest under VM's resource pool.
- **networks** [Hash]: Networks hash that specifies which VM networks must be configured.
- **disk_cids** [Array of strings] Array of disk cloud IDs for each disk that created VM will most _likely_ be attached; they could be used to optimize VM placement so that disks are located nearby.
- **environment** [Hash]: Resource pool's env hash specified in deployment manifest including initial properties added by the BOSH director as shown below.

##### Example

```json
[
	"4149ba0f-38d9-4485-476f-1581be36f290",
	"ami-478585",
	{ "instance_type": "m1.small" },
	{
		"private": {
			"type": "manual",
			"netmask": "255.255.255.0",
			"gateway": "10.230.13.1",
			"ip": "10.230.13.6",
			"default": [ "dns", "gateway" ],
			"cloud_properties": { "net_id": "subnet-48rt54" }
	  	},
	  	"private2": {
			"type": "dynamic",
			"cloud_properties": { "net_id": "subnet-e12364" }
		},
		"public": {
			"type": "vip",
			"ip": "173.101.112.104",
			"cloud_properties": {}
		}
	},
	[ "vol-3475945" ],
	{
		"bosh": {
			"group": "my-group",
			"groups": [
				"my-second-group",
				"another-group"
			]
		}
	}
]
```

#### Returned

- **vm_cid** [String]: Cloud ID of the created VM.

#### Agent settings

For the Agent to successfully start on the created VM, several bootstrapping settings must be exposed which include network configuration, message bus location (NATS/HTTPS), agent id, etc. Each infrastructure might have a different way of providing such settings to the Agent. For example AWS CPI uses instance user metadata and BOSH Registry. vSphere CPI uses CDROM drive. Most CPIs choose to communicate with default Agent hence communication settings follow certain format:

```yaml
{
	"agent_id": "4149ba0f-38d9-4485-476f-1581be36f290",

	"vm": { "name": "i-347844" },

	"networks": {
		"private": {
			"type": "manual",
			"netmask": "255.255.255.0",
			"gateway": "10.230.13.1",
			"ip": "10.230.13.6",
			"default": [ "dns", "gateway" ],
			"cloud_properties": { "net_id": "d29fdb0d-44d8-4e04-818d-5b03888f8eaa" }
		},
		"public": {
			"type": "vip",
			"ip": "173.101.112.104",
			"cloud_properties": {}
		}
	},

	"disks": {
		"system": "/dev/sda",
		"ephemeral": "/dev/sdb",
		"persistent": {}
	},

	"mbus": "https://mbus:mbus-password@0.0.0.0:6868"

	"ntp": [ "0.pool.ntp.org", "1.pool.ntp.org" ],

	"blobstore": {
		"provider": "local",
		"options": { "blobstore_path": "/var/vcap/micro_bosh/data/cache" }
	},

	"env": {},
}
```

See [Agent Configuration](vm-config.md#agent) for an overview of the Agent configuration file locations.

[Example create_vm.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_vm.go)

---
### `delete_vm` {: #delete-vm }

Deletes the VM.

This method will be called while the VM still has persistent disks attached. It's important to make sure that IaaS behaves appropriately in this case and properly disassociates persistent disks from the VM.

To avoid losing track of VMs, make sure to raise an error if VM deletion is not absolutely certain.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM to delete; returned from `create_vm`.

#### Returned

No return value

[Example delete_vm.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/delete_vm.go)

---
### `has_vm` {: #has-vm }

Checks for VM presence in the IaaS.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the VM still exists.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM to check; returned from `create_vm`.

#### Returned

- **exists** [Boolean]: True if VM is present.

[Example has_vm.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/has_vm.go)

---
### `reboot_vm` {: #reboot-vm }

Reboots the VM. Assume that VM can be either be powered on or off at the time of the call.

Waiting for the VM to finish rebooting is not required because the Director waits until the Agent on the VM responds back.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM to reboot; returned from `create_vm`.

#### Returned

No return value

[Example #reboot_vm](https://github.com/cloudfoundry/bosh/blob/1dfc5da695cdcfe3998e0c8b3bea4cda86e963c4/bosh_vsphere_cpi/lib/cloud/vsphere/cloud.rb#L193)

---
### `set_vm_metadata` {: #set-vm-metadata }

Sets VM's metadata to make it easier for operators to categorize VMs when looking at the IaaS management console. For example AWS CPI uses tags to store metadata for operators to see in the AWS Console.

We recommend to set VM name based on *sometimes* provided `name` key.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM to modify; returned from `create_vm`.
- **metadata** [Hash]: Collection of key-value pairs. CPI should not rely on presence of specific keys.

##### Example

```yaml
[
	"i-387459",
	{
		"director": "director-784430",
		"deployment": "redis",
		"name": "redis/ce7d2040-212e-4d5a-a62d-952a12c50741",
		"job": "redis",
		"id": "ce7d2040-212e-4d5a-a62d-952a12c50741",
		"index": "1"
	}
]
```

#### Returned

No return value

[Example #set\_vm\_metadata](https://github.com/cloudfoundry/bosh/blob/1dfc5da695cdcfe3998e0c8b3bea4cda86e963c4/bosh_vsphere_cpi/lib/cloud/vsphere/cloud.rb#L217)

---
### `configure_networks` {: #configure-networks }

The recommended implementation is to raise `Bosh::Clouds::NotSupported` error. This method will be deprecated in API v2.

After the Director received NotSupported error, it will delete the VM (via `delete_vm`) and create a new VM with desired network configuration (via `create_vm`).

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM to modify; returned from `create_vm`.
- **networks** [Hash]: Network hashes that specify networks VM must be configured.

##### Example

```yaml
[
	"i-238445",
	{
		"private": {
			"type": "manual",
			"netmask": "255.255.255.0",
			"gateway": "10.230.13.1",
			"ip": "10.230.13.6",
			"default": [ "dns", "gateway" ],
			"cloud_properties": { "net_id": "subnet-48rt54" }
	  	},
	  	"private2": {
			"type": "dynamic",
			"cloud_properties": { "net_id": "subnet-e12364" }
		}
		"public": {
			"type": "vip",
			"ip": "173.247.112.104",
			"cloud_properties": {}
		}
	}
]
```

#### Returned

No return value

---
### `calculate_vm_cloud_properties` {: #calculate-vm-cloud-properties }

Returns a hash that can be used as VM `cloud_properties` when calling `create_vm`; it describes the IaaS instance type closest to the arguments passed.

The `cloud_properties` returned are IaaS-specific. For example, when querying the AWS CPI for a VM with the parameters `{ "cpu": 1, "ram": 512, "ephemeral_disk_size": 1024 }`, it will return the following, which includes a `t2.nano` instance type which has 1 CPU and 512MB RAM:

```yaml
{
  "instance_type": "t2.nano",
  "ephemeral_disk": { "size": 1024 }
}
```

`calculate_vm_cloud_properties` returns the minimum resources that satisfy the parameters, which may result in a larger machine than expected. For example, when querying the AWS CPI for a VM with the parameters `{ "cpu": 1, "ram": 8192, "ephemeral_disk_size": 4096}`, it will return an `m4.large` instance type (which has 2 CPUs) because it is the smallest instance type which has at least 8 GiB RAM.

If a parameter is set to a value greater than what is available (e.g. 1024 CPUs), an error is raised.

#### Arguments

- **desired\_instance\_size** [Hash]: Parameters of the desired size of the VM consisting of the following keys:
  - **cpu** [Integer]: Number of virtual cores desired
  - **ram** [Integer]: Amount of RAM, in MiB (i.e. `4096` for 4 GiB)
  - **ephemeral\_disk\_size** [Integer]: Size of ephemeral disk, in MB

##### Example

```yaml
{
  "ram": 1024,
  "cpu": 2,
  "ephemeral_disk_size": 2048
}
```

#### Returned

- **cloud_properties** [Hash]: an IaaS-specific set of cloud properties that define the size of the VM.

---
## Disk management {: #disk }

### `create_disk` {: #create-disk }

Creates disk with specific size. Disk does not belong to any given VM.

#### Arguments

- **size** [Integer]: Size of the disk in MiB.
- **cloud_properties** [Hash]: Cloud properties hash specified in the deployment manifest under the disk pool.
- **vm_cid** [String]: Cloud ID of the VM created disk will most _likely_ be attached; it could be used to .optimize disk placement so that disk is located near the VM.

##### Example

```yaml
[
	25000,
	{
		"type": "gp2",
		"encrypted": true
	},
	"i-2387475"
]
```

#### Returned

- **disk_cid** [String]: Cloud ID of the created disk.

[Example create_disk.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_disk.go)

---
### `delete_disk` {: #delete-disk }

Deletes disk. Assume that disk was detached from all VMs.

To avoid losing track of disks, make sure to raise an error if disk deletion is not absolutely certain.

#### Arguments

- **disk_cid** [String]: Cloud ID of the disk to delete; returned from `create_disk`.

#### Returned

No return value

[Example delete_disk.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/delete_disk.go)

---
### `resize_disk` {: #resize-disk }

Resizes disk with IaaS-native methods. Assume that disk was detached from all VMs. Set property [`director.enable_cpi_resize_disk`](http://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh&version=263#p=director.enable_cpi_resize_disk) to `true` to have the Director call this method.

Depending on the capabilities of the underlying infrastructure, this method may raise an `Bosh::Clouds::NotSupported` error when the `new_size` is smaller than the current disk size. The same error is raised when the method is not implemented.

If `Bosh::Clouds::NotSupported` is raised, the Director falls back to creating a new disk and copying data.

#### Arguments

- **disk_cid** [String]: Cloud ID of the disk to resize; returned from `create_disk`.
- **new_size** [Integer]: New disk size in MiB.

#### Returned

No return value

[Example #resize_disk](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/blob/88e1c6d402b3c4ce23ad39ebdf5ab5fc93790127/src/bosh_openstack_cpi/lib/cloud/openstack/cloud.rb#L701)

---
### `has_disk` {: #has-disk }

Checks for disk presence in the IaaS.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the disk still exists.

#### Arguments

- **disk_cid** [String]: Cloud ID of the disk to check; returned from `create_disk`.

#### Returned

- **exists** [Boolean]: True if disk is present.

[Example #has_disk](https://github.com/cloudfoundry/bosh/blob/1dfc5da695cdcfe3998e0c8b3bea4cda86e963c4/bosh_vsphere_cpi/lib/cloud/vsphere/cloud.rb#L61)

---
### `attach_disk` {: #attach-disk }

Attaches disk to the VM.

Typically each VM will have one disk attached at a time to store persistent data; however, there are important cases when multiple disks may be attached to a VM. Most common scenario involves persistent data migration from a smaller to a larger disk. Given a VM with a smaller disk attached, the operator decides to increase the disk size for that VM, so new larger disk is created, it is then attached to the VM. The Agent then copies over the data from one disk to another, and smaller disk subsequently is detached and deleted.

Agent settings should have been updated with necessary information about given disk.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM.
- **disk_cid** [String]: Cloud ID of the disk.

#### Returned

No return value

#### Agent settings

For the Agent to eventually format, partition and mount attached disk, it needs to identify the disk attachment from inside the OS. The Agent can currently identify attached disk based on either device path, disk's ID, or SCSI volume ID. For example settings below show that CPI attached a disk `vol-7447851` at `/dev/sdd`:

```yaml
{
	"agent_id": "4149ba0f-38d9-4485-476f-1581be36f290",

	"vm": { "name": "i-347844" },

	"networks": { ... },

	"disks": {
		"system": "/dev/sda",
		"ephemeral": "/dev/sdb",
		"persistent": {
			"vol-3475945": { "volume_id": "3" },
			"vol-7447851": { "path": "/dev/sdd" },
		}
	},

	"mbus": "https://mbus:mbus-password@0.0.0.0:6868"

	"ntp": [ ... ],

	"blobstore": { ... },

	"env": {},
}
```

[Example attach_disk.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/attach_disk.go)

---
### `detach_disk` {: #detach-disk }

Detaches disk from the VM.

If the persistent disk is attached to a VM that will be deleted, it's more likely `delete_vm` CPI method will be called without a call to `detach_disk` with an expectation that `delete_vm` will make sure disks are disassociated from the VM upon its deletion.

Agent settings should have been updated to remove information about given disk.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM.
- **disk_cid** [String]: Cloud ID of the disk.

#### Returned

No return value

[Example detach_disk.go](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/detach_disk.go)

---
### `set_disk_metadata` {: #set-disk-metadata }

!!! note
    This method is called by BOSH v262+.

Sets disk's metadata to make it easier for operators to categorize disks when looking at the IaaS management console. For example AWS CPI uses tags to store metadata for operators to see in the AWS Console.

Disk metadata is written when the disk is attached to a VM. Metadata is not removed when disk is detached or VM is deleted.

#### Arguments

- **disk_cid** [String]: Cloud ID of the disk to modify; returned from `create_disk`.
- **metadata** [Hash]: Collection of key-value pairs. CPI should not rely on presence of specific keys.

##### Example

```yaml
[
  "vol-3475945",
  {
    "director": "director-784430",
    "deployment": "redis",
    "instance_id": "ce7d2040-212e-4d5a-a62d-952a12c50741",
    "job": "redis",
    "instance_index": "1",
    "instance_name": "redis/ce7d2040-212e-4d5a-a62d-952a12c50741",
    "attached_at": "2017-08-10T12:03:32Z"
  }
]

```

#### Returned

No return value

[Example #set\_disk\_metadata](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/blob/0c8ee8951cab41d0ddc86591719d55d8a783ac98/src/bosh_openstack_cpi/lib/cloud/openstack/cloud.rb#L629)

---
### `get_disks` {: #get-disks }

Returns list of disks _currently_ attached to the VM.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the VM has required disks attached.

#### Arguments

- **vm_cid** [String]: Cloud ID of the VM.

#### Returned

- **disk_cids** [Array of strings]: Array of `disk_cid`s that are currently attached to the VM.

---
## Disk snapshots {: #disk-snapshots }

### `snapshot_disk` {: #snapshot-disk }

Takes a snapshot of the disk.

#### Arguments

- **disk_cid** [String]: Cloud ID of the disk.
- **metadata** [Hash]: Collection of key-value pairs. CPI should not rely on presence of specific keys.

#### Returned

- **snapshot_cid** [String]: Cloud ID of the disk snapshot.

---
### `delete_snapshot` {: #delete-snapshot }

Deletes the disk snapshot.

#### Arguments

- **snapshot_cid** [String]: Cloud ID of the disk snapshot.

#### Returned

No return value

---
### `current_vm_id` {: #current-vm-id }

Determines cloud ID of the VM executing the CPI code. Currently used in combination with `get_disks` by the Director to determine which disks to self-snapshot.

!!! note
    Do not implement; this method will be deprecated and removed.

#### Arguments

No arguments

#### Returned

- **vm_cid** [String]: Cloud ID of the VM.
