---
schema: true
---

# Deployment Manifest

## deployment {: # }

The deployment manifest defines the components and properties of the deployment.

### `addons` {: #addons }

Specifies the [addons](https://bosh.io/docs/terminology/#addon) to be applied to this deployments.

 * *Use*: Optional
 * *Type*: array

### `features` {: #features }

Specifies Director features that should be used within this deployment.

 * *Use*: Optional
 * *Type*: object

> #### `randomize_az_placement` {: #features.randomize_az_placement }
> 
> Randomizes AZs for left over instances that cannot be distributed equally between AZs. For example, given an instance group with 5 instances and only 3 AZs, 1 remaining instance will be placed in randomly chosen AZ out of specified 3 AZs.
> 
>  * *Use*: Optional
>  * *Type*: boolean
> 
> #### `use_dns_addresses` {: #features.use_dns_addresses }
> 
> Enables or disables returning of DNS addresses in links. Defaults to global Director `use_dns_addresses` configuration.
> 
>  * *Use*: Optional
>  * *Type*: boolean
> 

### `instance_groups[]` {: #instance_groups }

Specifies the mapping between release [jobs](https://bosh.io/docs/terminology/#job) and instance groups.

 * *Use*: Optional
 * *Type*: array

> #### `azs` {: #instance_groups.azs }
> 
> List of AZs associated with this instance group (should only be used when using [first class AZs](https://bosh.io/docs/azs/)).
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> #### `env` {: #instance_groups.env }
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-env)
> 
> #### `instances` {: #instance_groups.instances }
> 
> The number of instances in this group. Each instance is a VM.
> 
>  * *Use*: Required
>  * *Type*: integer
> 
> #### `jobs[]` {: #instance_groups.jobs }
> 
> Specifies the name and release of jobs that will be installed on each instance.
> 
>  * *Use*: Required
>  * *Type*: array
> 
> > ##### `consumes` {: #instance_groups.jobs.consumes }
> > 
> > Links consumed by the job. [Read more about link configuration](https://bosh.io/docs/links/#deployment)
> > 
> >  * *Use*: Optional
> >  * *Type*: object
> > 
> > 
> > ##### `name` {: #instance_groups.jobs.name }
> > 
> > The job name.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `properties` {: #instance_groups.jobs.properties }
> > 
> > Specifies job properties. Properties allow BOSH to configure jobs to a specific environment. `properties` defined in a Job block are accessible only to that job. Only properties specified here will be provided to the job.
> > 
> >  * *Use*: Optional
> >  * *Type*: object
> > 
> > 
> > ##### `provides` {: #instance_groups.jobs.provides }
> > 
> > Links provided by the job. [Read more about link configuration](https://bosh.io/docs/links/#deployment)
> > 
> >  * *Use*: Optional
> >  * *Type*: object
> > 
> > 
> > ##### `release` {: #instance_groups.jobs.release }
> > 
> > The release where the job exists.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> 
> #### `lifecycle` {: #instance_groups.lifecycle }
> 
> Specifies the kind of task the job represents. Valid values are service and errand; defaults to service. A service runs indefinitely and restarts if it fails. An errand starts with a manual trigger and does not restart if it fails.
> 
>  * *Use*: Required
>  * *Default*: `"service"`
>  * *Supported Values*: `"errand"`, `"service"`
> 
> #### `name` {: #instance_groups.name }
> 
> A unique name used to identify and reference this association between a BOSH release job and a VM.
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `networks[]` {: #instance_groups.networks }
> 
> Specifies the networks this job requires.
> 
>  * *Use*: Required
>  * *Type*: array
> 
> > ##### `default` {: #instance_groups.networks.default }
> > 
> > Specifies which network components (DNS, Gateway) BOSH populates by default from this network. This property is required if more than one network is specified.
> > 
> >  * *Use*: Optional
> >  * *Type*: array
> > 
> > ##### `name` {: #instance_groups.networks.name }
> > 
> > A valid network name from the cloud config.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `static_ips` {: #instance_groups.networks.static_ips }
> > 
> > Array of IP addresses reserved for the instances on the network.
> > 
> >  * *Use*: Optional
> >  * *Type*: array
> > 
> 
> #### `persistent_disk` {: #instance_groups.persistent_disk }
> 
> Persistent disk size in MB. Alternatively you can specify `persistent_disk_type` key. [Read more about persistent disks](https://bosh.io/docs/persistent-disks/)
> 
>  * *Use*: Optional
>  * *Type*: integer
> 
> #### `persistent_disk_type` {: #instance_groups.persistent_disk_type }
> 
> A valid disk type name from the cloud config. [Read more about persistent disks](https://bosh.io/docs/persistent-disks/)
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `properties` {: #instance_groups.properties }
> 
> Specifies job properties. Properties allow BOSH to configure jobs to a specific environment. properties defined in a Job block are accessible only to that job, and override any identically named global properties.
> 
>  * *Use*: Optional
>  * *Type*: object
> 
> 
> #### `stemcell` {: #instance_groups.stemcell }
> 
> A valid stemcell alias from the Stemcells Block.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `update` {: #instance_groups.update }
> 
> Specific update settings for this instance group. Use this to override global job update settings on a per-instance-group basis.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-update)
> 
> #### `vm_extensions` {: #instance_groups.vm_extensions }
> 
> A valid list of VM extension names from the cloud config.
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> #### `vm_resources` {: #instance_groups.vm_resources }
> 
> Specifies generic VM resources such as CPU, RAM and disk size that are automatically translated into correct VM cloud properties to determine VM size. VM size is determined on best effort basis as some IaaSes may not support exact size configuration.
> 
>  * *Use*: Optional
>  * *Type*: object
> 
> > ##### `cpu` {: #instance_groups.vm_resources.cpu }
> > 
> > Number of CPUs.
> > 
> >  * *Use*: Required
> >  * *Type*: integer
> > 
> > ##### `ephemeral_disk_size` {: #instance_groups.vm_resources.ephemeral_disk_size }
> > 
> > Ephemeral disk size in MB.
> > 
> >  * *Use*: Required
> >  * *Type*: integer
> > 
> > ##### `ram` {: #instance_groups.vm_resources.ram }
> > 
> > Amount of RAM in MB.
> > 
> >  * *Use*: Required
> >  * *Type*: integer
> > 
> 
> #### `vm_type` {: #instance_groups.vm_type }
> 
> A valid VM type name from the cloud config. Alternatively you can specify `vm_resources` key.
> 
>  * *Use*: Required
>  * *Details*: [See Schema](#def-vm_type_ref)
> 

### `name` {: #name }

The name of the deployment. A single Director can manage multiple deployments and distinguishes them by name.

 * *Use*: Required
 * *Type*: string
 * *Example*: `"my-redis"`

### `properties` {: #properties }

Describes global properties. Deprecated in favor of job level properties and links.

 * *Use*: Optional
 * *Type*: object


### `releases[]` {: #releases }

The name and version of each release in the deployment.

 * *Use*: Required
 * *Type*: array

> #### `name` {: #releases.name }
> 
> Name of a release used in the deployment.
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `sha1` {: #releases.sha1 }
> 
> SHA1 of asset referenced via URL. Works with CLI v2
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `url` {: #releases.url }
> 
> URL of a release to download. Works with CLI v2.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `version` {: #releases.version }
> 
> The version of the release to use. Version can be `latest`.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `stemcells` {: #stemcells }

The name and version of each stemcell in the deployment.

 * *Use*: Optional
 * *Type*: object

> #### `alias` {: #stemcells.alias }
> 
> Name of a stemcell used in the deployment.
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `name` {: #stemcells.name }
> 
> Full name of a matching stemcell. Either `name` or `os` keys must be specified.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `os` {: #stemcells.os }
> 
> Operating system of a matching stemcell. Either `name` or `os` keys must be specified.
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Example*: `"ubuntu-trusty"`
> 
> #### `version` {: #stemcells.version }
> 
> The version of a matching stemcell. Version can be `latest`.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `tags` {: #tags }

Specifies key value pairs to be sent to the CPI for VM tagging. Combined with runtime config level tags during the deploy.

 * *Use*: Optional
 * *Type*: object
 * *Example*: `{
  "project": "cf"
}`


### `update` {: #update }

 * *Use*: Required
 * *Details*: [See Schema](#def-update)

### `variables[]` {: #variables }

Describes variables.

 * *Use*: Optional
 * *Type*: array

> #### `name` {: #variables.name }
> 
> Unique name used to identify a variable.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `options` {: #variables.options }
> 
> Specifies generation options used for generating variable value if variable is not found.
> 
>  * *Use*: Optional
>  * *Type*: object
>  * *Example*: `{
  "common_name": "some-ca",
  "is_ca": true
}`
> 
> 
> #### `type` {: #variables.type }
> 
> Type of a variable.
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Supported Values*: `"certificate"`, `"password"`, `"rsa"`, `"ssh"`
> 

## Agent Environment Settings {: #def-env }

Specifies advanced BOSH Agent configuration for each instance in the group.

> #### `bosh` {: #def-env.bosh }
> 
>  * *Use*: Optional
>  * *Type*: object
> 
> > ##### `ipv6` {: #def-env.bosh.ipv6 }
> > 
> >  * *Use*: Optional
> >  * *Type*: object
> > 
> > > ###### `enable` {: #def-env.bosh.ipv6.enable }
> > > 
> > > Force IPv6 enabled in kernel (this configuration is not necessary if one of the VM addresses is IPv6).
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: boolean
> > >  * *Default*: `false`
> > > 
> > 
> > ##### `keep_root_password` {: #def-env.bosh.keep_root_password }
> > 
> > Keep password for root and only change password for `vcap`.
> > 
> >  * *Use*: Optional
> >  * *Type*: boolean
> >  * *Default*: `false`
> > 
> > ##### `password` {: #def-env.bosh.password }
> > 
> > Crypted password for vcap/root user (will be placed into /etc/shadow on Linux).
> > 
> >  * *Use*: Optional
> >  * *Type*: string
> > 
> > ##### `remove_dev_tools` {: #def-env.bosh.remove_dev_tools }
> > 
> > Remove [compilers and dev tools](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/master/stemcell_builder/stages/dev_tools_config/assets/generate_dev_tools_file_list_ubuntu.sh) on non-compilation VMs.
> > 
> >  * *Use*: Optional
> >  * *Type*: boolean
> >  * *Default*: `false`
> > 
> > ##### `remove_static_libraries` {: #def-env.bosh.remove_static_libraries }
> > 
> > Remove static libraries on non-compilation VMs
> > 
> >  * *Use*: Optional
> >  * *Type*: boolean
> >  * *Default*: `false`
> > 
> > ##### `swap_size` {: #def-env.bosh.swap_size }
> > 
> > Size of swap partition in MB to create. Set this to 0 to avoid having a swap partition created. Default: RAM size of used VM type up to half of the ephemeral disk size.
> > 
> >  * *Use*: Optional
> >  * *Type*: integer
> > 
> 
## Update Settings {: #def-update }

This specifies instance update properties. These properties control how BOSH updates job instances during the deployment.

> #### `canaries` {: #def-update.canaries }
> 
> The number of [canary](https://bosh.io/docs/terminology/#canary) instances.
> 
>  * *Use*: Required
>  * *Type*: integer
> 
> #### `canary_watch_time` {: #def-update.canary_watch_time }
> 
>  * *Use*: Required
> 
> #### `max_in_flight` {: #def-update.max_in_flight }
> 
>  * *Use*: Required
> 
> #### `serial` {: #def-update.serial }
> 
> If disabled (set to false), deployment jobs will be deployed in parallel, otherwise - sequentially. Instances within a deployment job will still follow canary and max_in_flight configuration.
> 
>  * *Use*: Optional
>  * *Type*: boolean
>  * *Default*: `true`
> 
> #### `update_watch_time` {: #def-update.update_watch_time }
> 
>  * *Use*: Required
> 
