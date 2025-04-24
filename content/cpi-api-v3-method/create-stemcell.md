# create_stemcell

Creates a reusable VM image in the IaaS from the [stemcell](../stemcell.md) image. It's used later for creating VMs. For example AWS CPI creates an AMI and returns AMI ID.

See [Stemcell Building](../build-stemcell.md) for more details.


## Arguments

 * `image_path` [String]: Path to the stemcell image extracted from the stemcell tarball on a local filesystem.
 * `cloud_properties` [Hash]: Cloud properties hash extracted from the stemcell tarball.
 * `env` [Hash]: A random hash with a "tags" key which itself is a hash of key/value pairs. This is used from version 282.0.0 of the director.


## Result

 * `stemcell_cid` [String]: Cloud ID of the created stemcell (e.g. stemcells in AWS CPI are made into AMIs so cid .would be `ami-83fdflf`)


## Example


### API Request

```json
[
	"/tmp/extracted-stemcell-348754vdsn87fr/image",
	{
		"name": "bosh-openstack-esxi-ubuntu-xenial-go_agent",
		"version": "621.74",
		"infrastructure": "openstack",
		"hypervisor": "esxi",
		"disk": 3072,
		"disk_format": "ovf",
		"container_format": "bare",
		"os_type": "linux",
		"os_distro": "ubuntu",
		"architecture": "x86_64",
		"auto_disk_config": true
	},
	{"tags": {"any": "tag value"} }
]
```

### Implementations

 * [cloudfoundry/bosh-aws-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/create_stemcell.go)
