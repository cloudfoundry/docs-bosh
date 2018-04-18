---
schema: true
---

# Cloud Config

## Cloud Config {: # }

The cloud config defines IaaS specific configuration used by the Director and all deployments. It allows us to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

### `azs[]` {: #azs }

Specifies the AZs available to deployments. At least one should be specified.

 * *Use*: Required
 * *Type*: array

> #### `cloud_properties` {: #azs.cloud_properties }
> 
> Describes any IaaS-specific properties needed to associated with AZ; for most IaaSes, some data here is actually required.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-vm.json#)
> 
> #### `name` {: #azs.name }
> 
> Name of an AZ within the Director.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `compilation` {: #compilation }

Properties of compilation VMs.

 * *Use*: Required
 * *Type*: object

> #### `az` {: #compilation.az }
> 
> Name of the AZ defined in AZs section to use for creating compilation VMs.
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `cloud_properties` {: #compilation.cloud_properties }
> 
> Describes any IaaS-specific properties needed to create VMs.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-vm.json#)
> 
> #### `env` {: #compilation.env }
> 
> Agent environment options.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-env.json#)
> 
> #### `network` {: #compilation.network }
> 
> References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `reuse_compilation_vms` {: #compilation.reuse_compilation_vms }
> 
> If `false`, BOSH creates a new compilation VM for each new package compilation and destroys the VM when compilation is complete. If `true`, compilation VMs are re-used when compiling packages.
> 
>  * *Use*: Optional
>  * *Type*: boolean
>  * *Default*: `false`
> 
> #### `vm_resources` {: #compilation.vm_resources }
> 
> Specifies generic VM resources such as CPU, RAM and disk size that are automatically translated into correct VM cloud properties to determine VM size. VM size is determined on best effort basis as some IaaSes may not support exact size configuration.
> 
>  * *Use*: Optional
>  * *Type*: object
> 
> 
> #### `vm_type` {: #compilation.vm_type }
> 
> Name of the VM type defined in VM types section to use for creating compilation VMs. Alternatively, you can specify the `vm_resources`, or `cloud_properties` key.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `workers` {: #compilation.workers }
> 
> The maximum number of compilation VMs.
> 
>  * *Use*: Required
>  * *Type*: integer
> 

### `disk_types[]` {: #disk_types }

Specifies the [disk types](http://bosh.io/docs/terminology.html#disk-types) available to deployments. At least one should be specified.

 * *Use*: Required
 * *Type*: array

> #### `cloud_properties` {: #disk_types.cloud_properties }
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-disk.json#)
> 
> #### `disk_size` {: #disk_types.disk_size }
> 
> Specifies the disk size. disk_size must be a positive integer. BOSH creates a [persistent disk](http://bosh.io/docs/persistent-disks.html) of that size in megabytes and attaches it to each job instance VM.
> 
>  * *Use*: Optional
>  * *Type*: integer
> 
> #### `name` {: #disk_types.name }
> 
> A unique name used to identify and reference the disk type.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `networks[]` {: #networks }

Each sub-block listed in the Networks block specifies a network configuration that jobs can reference. There are three different network types: manual, dynamic, and vip. At least one should be specified.

 * *Use*: Required
 * *Type*: array

#### Dynamic Network {: #networks[0] }

> The Director defers IP selection to the IaaS.
> 
>  * *Use*: Required
>  * *Type*: object
> 
> > ##### `cloud_properties` {: #networks[0].cloud_properties }
> > 
> > Describes any IaaS-specific properties for the subnet.
> > 
> >  * *Use*: Optional
> >  * *Details*: [See Schema](#def-network.json#)
> > 
> > ##### `dns` {: #networks[0].dns }
> > 
> > DNS IP addresses for this subnet
> > 
> >  * *Use*: Optional
> >  * *Type*: array
> > 
> > ##### `name` {: #networks[0].name }
> > 
> > Name used to reference this network configuration.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `type` {: #networks[0].type }
> > 
> > Value must be `dynamic`.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> >  * *Supported Values*: `"dynamic"`
> > 


#### Manual Network {: #networks[1] }

> The Director decides how to assign IPs to each job instance based on the specified network subnets in the deployment manifest.
> 
>  * *Use*: Required
>  * *Type*: object
> 
> > ##### `name` {: #networks[1].name }
> > 
> > Name used to reference this network configuration.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `subnets[]` {: #networks[1].subnets }
> > 
> > Lists subnets in this network.
> > 
> >  * *Use*: Required
> >  * *Type*: array
> > 
> > > ###### `az` {: #networks[1].subnets.az }
> > > 
> > > AZ associated with this subnet (should only be used when using [first class AZs](http://bosh.io/docs/azs/)).
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: string
> > > 
> > > ###### `azs` {: #networks[1].subnets.azs }
> > > 
> > > List of AZs associated with this subnet (should only be used when using [first class AZs](http://bosh.io/docs/azs/)).
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: array
> > > 
> > > ###### `cloud_properties` {: #networks[1].subnets.cloud_properties }
> > > 
> > > Describes any IaaS-specific properties for the subnet.
> > > 
> > >  * *Use*: Optional
> > >  * *Details*: [See Schema](#def-network.json#)
> > > 
> > > ###### `dns` {: #networks[1].subnets.dns }
> > > 
> > > DNS IP addresses for this subnet
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: array
> > > 
> > > ###### `gateway` {: #networks[1].subnets.gateway }
> > > 
> > > Subnet gateway IP
> > > 
> > >  * *Use*: Required
> > >  * *Type*: string
> > > 
> > > ###### `range` {: #networks[1].subnets.range }
> > > 
> > > Subnet IP range that includes all IPs from this subnet
> > > 
> > >  * *Use*: Required
> > >  * *Type*: string
> > > 
> > > ###### `reserved` {: #networks[1].subnets.reserved }
> > > 
> > > Array of reserved IPs and/or IP ranges. BOSH does not assign IPs from this range to any VM
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: array
> > > 
> > > ###### `static` {: #networks[1].subnets.static }
> > > 
> > > Array of static IPs and/or IP ranges. BOSH assigns IPs from this range to jobs requesting static IPs. Only IPs specified here can be used for static IP reservations.
> > > 
> > >  * *Use*: Optional
> > >  * *Type*: array
> > > 
> > 
> > ##### `type` {: #networks[1].type }
> > 
> > Value must be `manual`.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> >  * *Supported Values*: `"manual"`
> > 


#### Virtual IP {: #networks[2] }

> The Director allows one-off IP assignments to specific jobs to enable flexible IP routing (e.g. elastic IP).
> 
>  * *Use*: Required
>  * *Type*: object
> 
> > ##### `cloud_properties` {: #networks[2].cloud_properties }
> > 
> >  * *Use*: Optional
> >  * *Details*: [See Schema](#def-network.json#)
> > 
> > ##### `name` {: #networks[2].name }
> > 
> > Name used to reference this network configuration.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `type` {: #networks[2].type }
> > 
> > Value must be `vip`.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> >  * *Supported Values*: `"vip"`
> > 


### `vm_extensions[]` {: #vm_extensions }

Specifies the VM extensions available to deployments.

 * *Use*: Optional
 * *Type*: array

> #### `cloud_properties` {: #vm_extensions.cloud_properties }
> 
> Describes any IaaS-specific properties needed to create VMs.
> 
>  * *Use*: Optional
>  * *Default*: `{}`
>  * *Details*: [See Schema](#def-vm.json#)
> 
> #### `name` {: #vm_extensions.name }
> 
> A unique name used to identify and reference the VM extension.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `vm_types[]` {: #vm_types }

Specifies the VM types available to deployments. At least one should be specified.

 * *Use*: Required
 * *Type*: array

> #### `cloud_properties` {: #vm_types.cloud_properties }
> 
> Describes any IaaS-specific properties needed to create VMs; for most IaaSes, some data here is actually required.
> 
>  * *Use*: Optional
>  * *Default*: `{}`
>  * *Details*: [See Schema](#def-vm.json#)
> 
> #### `name` {: #vm_types.name }
> 
> A unique name used to identify and reference the VM type.
> 
>  * *Use*: Required
>  * *Type*: string
> 

## Availability Zone {: #def-az_ref }

An availability zone configured with cloud-config.

## Disk Type {: #def-disk_type_ref }

A disk type configured with cloud-config.

## Network {: #def-network_ref }

A network configured with cloud-config.

## VM Extension {: #def-vm_extension_ref }

A VM extension configured with cloud-config.

## VM Type {: #def-vm_type_ref }

A VM type configured with cloud-config.

