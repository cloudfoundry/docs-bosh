This topic describes cloud properties for different resources created by the Azure CPI.

## AZs {: #azs }

* **availability_zone** [String, optional]: Availability zone to use for creating instances (available in v33+). Possible values: `'1'`, `'2'`, `'3'`. Read this [document](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview) to get regions and VM sizes on Azure that support availability zones. [More details about availability zone](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/availability-zone).

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: '1'
```

---
## Networks {: #networks }

### Dynamic Network or Manual Network

Schema for `cloud_properties` section:

* **resource\_group\_name** [String, optional]: Name of a resource group. If it is set, Azure CPI will search the virtual network and security group in this resource group. Otherwise, Azure CPI will search the virtual network and security group in `resource_group_name` in the global CPI settings.
* **virtual\_network\_name** [String, required]: Name of a virtual network. Example: `boshnet`.
* **subnet_name** [String, required]: Name of a subnet within virtual network.
* **security_group** [String, optional]: The [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) to apply to network interfaces of all VMs placed in this network. The security group of a network interface can be specified either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default security group (specified by `default_security_group` in the global CPI settings) will be used.
* **application\_security\_groups** [Array, optional]: The [application security group](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#application-security-groups) to apply to network interfaces of all VMs placed in this network. The application security groups of a network interface can be specified either in a VM type/extension (higher priority) or a network configuration (lower priority).
    * This property is supported in v31+.
    * You must reference the [document](https://docs.microsoft.com/en-us/azure/virtual-network/create-network-security-group-preview) to register your subscription with this new feature.
* **ip_forwarding** [Boolean, optional]: The flag to enable [ip forwarding](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface#enable-or-disable-ip-forwarding) for network interfaces of all VMs placed in this network. The ip forwarding can be enabled/disabled either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default value is `false`. Available in v35.3.0+.
* **accelerated_networking** [Boolean, optional]: The flag to enable [accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli) for network interfaces of all VMs placed in this network. The accelerated networking can be enabled/disabled either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default value is `false`. Available in v35.4.0+. This feature needs ubuntu-xenial v81+ and [specific instance type](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli#supported-vm-instances).

See [how to create a virtual network and subnets](azure-resources.md#virtual-network).

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      resource_group_name: my-resource-group-name
      virtual_network_name: my-vnet-name
      subnet_name: my-subnet-name
      security_group: my-security-group-name
      application_security_groups: ["my-application-security-group-name-1", "my-application-security-group-name-2"]
      ip_forwarding: true
      accelerated_networking: true
```

### Vip Network

Schema for `cloud_properties` section:

* **resource\_group\_name** [String, optional]: Name of a resource group. If it is set, Azure CPI will search the public IP in this resource group. Otherwise, Azure CPI will search the public IP in `resource_group_name` in the global CPI settings.

See [how to create public IP](azure-resources.md#public-ips) to use with vip networks.

Example of vip network:

```yaml
networks:
- name: public
  type: vip
  cloud_properties:
    resource_group_name: my-resource-group
```

---
## VM Types / VM Extensions {: #resource-pools }

Schema for `cloud_properties` section:

* **instance_type** [String, required]: Type of the [instance](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/). Example: `Standard_A2`. [Basic Tier Virtual Machines](https://azure.microsoft.com/en-us/blog/basic-tier-virtual-machines-2/) should not be used if you need to bind the instance to Azure Load Balancer (ALB), because Basic Tier VM doesn't support ALB.
* **root_disk** [Hash, optional]: OS disk of custom size.
    * **size** [Integer, optional]: Specifies the disk size in MiB.
        * The size must be greater than 3 * 1024 and less than the max disk size for [unmanaged](https://azure.microsoft.com/en-us/pricing/details/storage/unmanaged-disks/) or [managed](https://azure.microsoft.com/en-us/pricing/details/managed-disks/) disk. Please always use `N * 1024` as the size because Azure always uses GiB but not MiB.
        * It has a default value `30 * 1024` only when ephemeral_disk.use\_root\_disk is set to true.
* **caching** [String, optional]: Type of the disk caching of the VMs' OS disks. It can be either `None`, `ReadOnly` or `ReadWrite`. Default is `ReadWrite`.
* **ephemeral_disk** [Hash, optional]: Ephemeral disk to apply for all VMs that are in this VM type/extension. By default a data disk with the default size as below will be created as the ephemeral disk.
    * **use\_root\_disk** [Boolean, optional]: Enable to use OS disk to store the ephemeral data. The default value is false. When it is true, ephemeral_disk.size will not be used.
    * **size** [Integer, optional]: Specifies the disk size in MiB. If this is not set, the default size as below will be used. The size of the ephemeral disk for the BOSH VM should be larger than or equal to `30*1024` MiB. Please always use `N * 1024` as the size because Azure always uses GiB not MiB.
        * If the Azure temporary disk size for the instance type is less than `30*1024` MiB, the default size is `30*1024` MiB because the space may not be enough.
        * If the Azure temporary disk size for the instance type is larger than `1000*1024` MiB, the default size is `1000*1024` MiB because it is not expected to use such a large ephemeral disk in CF currently.
        * Otherwise, the Azure temporary disk size will be used as the default size. See more information about [Azure temporary disk size](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/).

* **load_balancer** [String, optional]: Name of a [load balancer](https://azure.microsoft.com/en-us/documentation/articles/load-balancer-overview/) the VMs should belong to.
    * _Notes:_
        * You need to create the load balancer manually before configuring it.
        * [Basic Tier Virtual Machines](https://azure.microsoft.com/en-us/blog/basic-tier-virtual-machines-2/) (Example: `Basic_A1`) doesn't support Azure Load Balancer.
        * If `availability_zone` is specified for the VM, [standard sku load balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview) must be used, as `basic sku load balancer` does not work for zone.
        * In CPI v37.6.0+, you can configure multiple Load Balancers (using a comma-delimited string).
        * This property is equivalent to the `load_balancer/name` property below.
* **load_balancer** [Array or Hash, optional]: The [load balancers](https://azure.microsoft.com/en-us/documentation/articles/load-balancer-overview/) the VMs should belong to.
    * _Notes:_
        * This property is supported in CPI v35.5.0+. In earlier versions, use the String property above instead.
        * In CPI [v37.7.0+](https://github.com/cloudfoundry/bosh-azure-cpi-release/releases/tag/v37.7.0), you can configure multiple Load Balancers, using an Array of Hashes with the properties below.
        * In CPI [v35.5.0+](https://github.com/cloudfoundry/bosh-azure-cpi-release/releases/tag/v35.5.0), you can configure a single Load Balancer, using a single Hash with the properties below.
        * You need to create the load balancer(s) manually before configuring them.
        * [Basic Tier Virtual Machines](https://azure.microsoft.com/en-us/blog/basic-tier-virtual-machines-2/) (Example: `Basic_A1`) doesn't support Azure Load Balancer.
        * If `availability_zone` is specified for the VM, [standard sku load balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview) must be used, as `basic sku load balancer` does not work for zone.
    * **name** [String, required]: The name of the load balancer.
    * **resource\_group\_name** [String, optional]: The name of the load balancer's resource group. Default value is the `resource_group_name` specified in the global CPI settings.
    * **backend\_pool\_name** [String, optional]: The name of the load balancer backend address pool which VMs' IPs should be attached to. If not specified, defaults to the load balancer's "first" backend pool (as returned by the Azure API).
        * This property is supported in CPI [v37.7.0+](https://github.com/cloudfoundry/bosh-azure-cpi-release/releases/tag/v37.7.0).
* **application_gateway** [String, optional]: Name of the [application gateway](https://azure.microsoft.com/en-us/services/application-gateway/) which the VMs should be attached to.
    * _Notes:_
        * This property is supported in CPI v28+.
        * You need to create the application gateway manually before configuring it. Please refer to [the guidance](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/application-gateway).
        * This property is equivalent to the `application_gateway/name` property below.
* **application_gateway** [Array or Hash, optional]: The [application gateways](https://azure.microsoft.com/en-us/services/application-gateway/) the VMs should be attached to.
    * _Notes:_
        * This property is supported in CPI [v37.7.0+](https://github.com/cloudfoundry/bosh-azure-cpi-release/releases/tag/v37.7.0). In earlier versions, use the String property above instead.
        * You need to create the application gateway(s) manually before configuring them. Please refer to [the guidance](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/application-gateway).
    * **name** [String, required]: The name of the application gateway.
    * **resource\_group\_name** [String, optional]: The name of the application gateway's resource group. Default value is the `resource_group_name` specified in the global CPI settings.
    * **backend\_pool\_name** [String, optional]: The name of the application gateway backend address pool which VMs' IPs should be attached to. If not specified, defaults to the application gateway's "first" backend pool (as returned by the Azure API).
* **security_group** [String, optional]: The [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) to apply to network interfaces of all VMs who have this VM type/extension. The security group of a network interface can be specified either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default security group (specified by `default_security_group` in the global CPI settings) will be used.
* **application\_security\_groups** [Array, optional]: The [application security group](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#application-security-groups) to apply to network interfaces of all VMs who have this VM type/extension. The application security groups of a network interface can be specified either in a VM type/extension (higher priority) or a network configuration (lower priority).
    * This property is supported in v31+.
    * You must reference the [document](https://docs.microsoft.com/en-us/azure/virtual-network/create-network-security-group-preview) to register your subscription with this new feature.
* **ip_forwarding** [Boolean, optional]: The flag to enable [ip forwarding](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface#enable-or-disable-ip-forwarding) for network interfaces of all VMs who have this VM type/extension. The ip forwarding can be enabled/disabled either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default value is `false`. Available in v35.3.0+.
* **accelerated_networking** [Boolean, optional]: The flag to enable [accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli) for network interfaces of all VMs who have this VM type/extension. The accelerated networking can be enabled/disabled either in a VM type/extension (higher priority) or a network configuration (lower priority). If it's not specified in neither places, the default value is `false`. Available in v35.4.0+. This feature needs ubuntu-xenial v81+ and [specific instance type](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli#supported-vm-instances).

* **assign\_dynamic\_public\_ip** [Boolean, optional]: Enable to create and assign dynamic public IP to the VM automatically (to solve the [azure SNAT issue](https://github.com/cloudfoundry/bosh-azure-cpi-release/issues/217)). Default value is `false`. Only the VM without vip will be assigned a dynamic public IP when this value is set to true, and the dynamic public IP will be deleted when the VM is deleted.

* **availability_zone** [String, optional]: Availability zone to use for creating instances (available in v33+). Possible values: `'1'`, `'2'`, `'3'`. Read this [document](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview) to get regions and VM sizes on Azure that support availability zones. [More details about availability zone](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/availability-zone).
* **availability_set** [String, optional]: Name of an [availability set](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) to use for VMs. [More details](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/deploy-cloudfoundry-for-enterprise#availability-set).
    * If available set does not exist, it will be automatically created.
    * If `availability_set` is not specified, Azure CPI will search `env.bosh.group` as the name of availability set.
        1. [bosh release](https://bosh.io/releases/github.com/cloudfoundry/bosh?all=1) v258+ will generate a value for `env.bosh.group` automatically.
        1. On Azure the length of the availability set name must be between 1 and 80 characters. The name got from  `env.bosh.group` may be too long. CPI will truncate the name to the following format `az-MD5-[LAST-40-CHARACTERS-OF-GROUP]` if the length is greater than 80.
    * CPI v27+ will delete the empty availability set.
    * Only one of `availability_zone` and `availability_set` is allowed to be configured for a VM. If `availability_zone` is specified, the VM will be in a zone and not in any availability set.
* **platform\_update\_domain_count** [Integer, optional]: The count of [update domain](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) in the availability set.
    * For Azure, the default value is `5`.
    * For Azure Stack, the default value is `1`.
* **platform\_fault\_domain_count** [Integer, optional]: The count of [fault domain](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) in the availability set.
    * For Azure, the default value of an unmanaged availability set is `3`. The default value of a managed availability set is `2`, because [some regions don't support 3 fault domains for now](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-manage-availability#configure-multiple-virtual-machines-in-an-availability-set-for-redundancy)
    * For Azure Stack, the default value is `1`. Before 1802 update, only `1` is allowed. After [1802 update](https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-update-1802), you can configure up to 3 fault domains.

* **storage\_account\_name** [String, optional]: Storage account for VMs. Valid only when `use_managed_disks` is `false`. If this is not set, the VMs will be created in the default storage account. See [this document](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/deploy-cloudfoundry-for-enterprise#multiple-storage-accounts) for more details on why this option exists.
    * If you use `DS-series` or `GS-series` as `instance_type`, you should set this to a premium storage account. See more information about [Azure premium storage](https://azure.microsoft.com/en-us/documentation/articles/storage-premium-storage-preview-portal/). See [avaliable regions](http://azure.microsoft.com/en-us/regions/#services) where you can create premium storage accounts.
    * If you use a different storage account which must be in the same resource group, please make sure:
        1. The permissions for the container `stemcell` in the default storage account is set to `Public read access for blobs only`.
        1. A table `stemcells` is created in the default storage account.
        1. Two containers `bosh` and `stemcell` are created in the new storage account.
    * If this storage account does not exist, it can be created automatically by Azure CPI. But you must specify storage\_account\_type and make sure:
        1. The name must be **unique within Azure**.
        1. **The name must be between 3 and 24 characters in length and use numbers and lower-case letters only**.
    * If you use a pattern `*keyword*`. CPI will filter all storage accounts under the default resource group by the pattern and pick one available storage account to create the VM.
        1. The pattern must start with `*` and end with `*`.
        1. The keyword must only contain numbers and lower-case letters because of the naming rule of storage account name.
        1. The rule to select an available storage account is to check the number of disks under the container `bosh` does not exceed the limitation.
        1. The default number of disks limitation is 30 but you can specify it in **storage\_account\_max\_disk\_number**.
* **storage\_account\_type** [String, optional]: Storage account type. You can click [**HERE**](http://azure.microsoft.com/en-us/pricing/details/storage/) to learn more about the type of Azure storage account.
    * When `use_managed_disks` is `true`, the root disk's type is specified by this property. It can be either `Standard_LRS` or `Premium_LRS`. If not specified, `Premium_LRS` will be used when its `instance_type` supports premium storage, otherwise, `Standard_LRS` will be used.
    * When `use_managed_disks` is `false`, the newly-created storage account's type is specified by this property. It can be either `Standard_LRS`, `Standard_ZRS`, `Standard_GRS`, `Standard_RAGRS` or `Premium_LRS`. It's required if the storage account does not exist.
* **storage\_account\_max\_disk\_number** [Integer, optional]: Number of disks limitation in a storage account. Valid only when `use_managed_disks` is `false`. Default value is 30. This will be used only when **storage\_account\_name** is a pattern.
    * Every storage account has a limitation to host disks. You may hit the performance issue if you create too many disks in one storage account.
    * The maximum number of disks of a standard storage account is 40 because the maximum IOPS of a standard storage account is 20,000 and the maximum IOPS of a standard disk is 500.
    * If you are using premium storage account, Azure maps the disk size (rounded up) to the nearest Premium Storage Disk option (P10, P20 and P30). For example, a disk of size 100 GiB is classified as a P10 option.
        1. The maximum number of disks of a premium storage account is 280 if you are using P10 (128 GiB) as your disk type.
        1. The maximum number of disks of a premium storage account is 70 if you are using P20 (512 GiB) as your disk type.
        1. The maximum number of disks of a premium storage account is 35 if you are using P30 (1024 GiB) as your disk type.
    * **storage\_account\_max\_disk\_number** should be less than the maximum number. Suggest you to use (MAX - 10) as the value because CPI always creates VMs in parallel.
    * Please see more information about [azure-subscription-service-limits](https://azure.microsoft.com/en-us/documentation/articles/azure-subscription-service-limits/).
* **storage\_account\_location** [String, optional]: Location of the storage account. This configuration is deprecated in CPI v25+: if you specify a storage account which does not exist, CPI (v25+) will create it automatically in the same location as VMs' VNET.

* **resource\_group\_name** [String, optional]: Name of a resource group (Available in v26+). If it is set, related resources will be created in this resource group; otherwise, they will be created in `resource_group_name` specified in the global CPI settings. The resources affected by this property are:
      1. Virtual Machine
      1. Network Interface Card
      1. Managed Disks (including OS disk, ephemeral disk, persistent disk and snapshot)
      1. Dynamic Public IP for the VM
      1. Availability Set

* **tags** [Hash, optional]: Custom tags of VMs (Available in v35.4.0+). They are name-value pairs that are used to organize VMs.

Example of a `Standard_A2` VM:

```yaml
vm_types:
- name: default
  cloud_properties:
    instance_type: Standard_A2
    root_disk:
      size: 30_720
    ephemeral_disk:
      use_root_disk: false
      size: 30_720
```

Example of a load balancer (simple configuration):

```yaml
vm_extensions:
- name: load-balancer-example-1
  cloud_properties:
    load_balancer: <load-balancer-name>
```

Example of a load balancer (complex configuration):

```yaml
vm_extensions:
- name: load-balancer-example-2
  cloud_properties:
    load_balancer:
      name: <load-balancer-name>
      # resource_group_name is optional
      resource_group_name: <resource-group-name>
      # backend_pool_name is optional
      backend_pool_name: <backend-pool-name>
```

Example of multiple load balancers (4 backend address pools of 3 LBs):

```yaml
vm_extensions:
- name: load-balancer-example-3
  cloud_properties:
    load_balancer:
      - name: <load-balancer-1-name>
      # NOTE: the following LB is in a different Resource Group (than the `resource_group_name` in the global CPI settings)
      - name: <load-balancer-2-name>
        resource_group_name: <resource-group-name>
      # NOTE: the following 2 attach the VMs to 2 separate backend address pools of the same LB
      - name: <load-balancer-3-name>
        backend_pool_name: <backend-pool-2-name>
      - name: <load-balancer-3-name>
        backend_pool_name: <backend-pool-4-name>
```

Example of an application gateway (simple configuration):

```yaml
vm_extensions:
- name: application-gateway-example-1
  cloud_properties:
    application_gateway: <application-gateway-name>
```

Example of an application gateway (complex configuration):

```yaml
vm_extensions:
- name: application-gateway-example-2
  cloud_properties:
    application_gateway:
      name: <application-gateway-name>
      # resource_group_name is optional
      resource_group_name: <resource-group-name>
      # backend_pool_name is optional
      backend_pool_name: <backend-pool-name>
```

Example of multiple application gateways (4 backend address pools of 3 AGWs):

```yaml
vm_extensions:
- name: application-gateway-example-3
  cloud_properties:
    application_gateway:
      - name: <application-gateway-1-name>
      # NOTE: the following AGW is in a different Resource Group (than the `resource_group_name` in the global CPI settings)
      - name: <application-gateway-2-name>
        resource_group_name: <resource-group-name>
      # NOTE: the following 2 attach the VMs to 2 separate backend address pools of the same AGW
      - name: <application-gateway-3-name>
        backend_pool_name: <backend-pool-2-name>
      - name: <application-gateway-3-name>
        backend_pool_name: <backend-pool-4-name>
```

Example of an availability set:

```yaml
vm_extensions:
- name: availability-set
  cloud_properties:
    availability_set: <availability-set-name>
```

The above `vm_extensions` cloud configuration examples are referenced within the deployment manifest as such:

```yaml
instance_groups:
- name: router
  instances: 2
  azs: [z1, z2]
  networks: [{name: default}]
  vm_type: default
  stemcell: default
  jobs:
  - name: router
    release: default
  vm_extensions:
  - load-balancer-example-1
  - application-gateway-example-2
  - availability-set
```

---
## Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **caching** [String, optional]: Type of the disk caching. It can be either `None`, `ReadOnly` or `ReadWrite`. Default is `None`.
* **storage\_account\_type** [String, optional]: Storage account type. Valid only when `use_managed_disks` is `true`. It can be either `Standard_LRS` or `Premium_LRS`. You can click [**HERE**](http://azure.microsoft.com/en-us/pricing/details/storage/) to learn more about the type of Azure storage account.
* **disk_size** [Integer, required]: Size of the disk in MiB. On Azure the disk size must be greater than 1 * 1024 and less than the max disk size for [unmanaged](https://azure.microsoft.com/en-us/pricing/details/storage/unmanaged-disks/) or [managed](https://azure.microsoft.com/en-us/pricing/details/managed-disks/) disk. Please always use `N * 1024` as the size because Azure always uses GiB not MiB.

Example of 10GB disk:
```yaml
disk_types:
- name: default
  disk_size: 10_240
```

---
## Global Configuration {: #global }

Schema:

* **environment** [String, required]: Azure environment name. Possible values are: `AzureCloud`, `AzureChinaCloud`, `AzureUSGovernment` (available in v19+), `AzureGermanCloud` (available in v22+) or `AzureStack`.
* **location** [String, optional]: Azure region name. Only required when [`vm_resources`](https://bosh.io/docs/manifest-v2.html#instance-groups) is specified in the deployment manifest. Available in v33+.
* **subscription_id** [String, required]: Subscription ID.
* **tenant_id** [String, required]: Tenant ID of the service principal.
* **client_id** [String, required]: Client ID of the service principal.
* **client_secret** [String, optional]: Client secret of the service principal.
* **certificate** [String, optional]: The certificate for your service principal. Azure CPI v35.0.0+ supports the [service principal with a certificate](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/use-service-principal-with-certificate). Only one of `client_secret` and `certificate` can be specified.
* **resource\_group\_name** [String, required]: Resource group name.
* **storage\_account\_name** [String, optional]: Storage account name. It will be used as a default storage account for VM disks and stemcells. If `use_managed_disks` is `false`, `storage_account_name` is required. Otherwise, `storage_account_name` is optional.
* **ssh_user** [String, required]: SSH username. Default: `vcap`.
* **ssh\_public\_key** [String, required]: SSH public key.
* **default\_security\_group** [String, optional]: Name of the default [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) that will be applied to all created VMs. This property is required before v35.0.0, and optional in v35.0.0+.
* **azure_stack** [Hash, optional]: [Configration for AzureStack](https://github.com/cloudfoundry/bosh-azure-cpi-release/tree/master/docs/advanced/azure-stack). Available in v23+.
    * **domain** [String, optional]: The domain for your AzureStack deployment. Default is `local.azurestack.external`. You can use the default value for [Azure Stack development kit](https://azure.microsoft.com/en-us/overview/azure-stack/development-kit/). To get this value for Azure Stack integrated systems, contact your service provider.
    * **authentication** [String, optional]: The authentication type for your AzureStack deployment. Possible values are: `AzureAD`, `AzureChinaCloudAD` and `ADFS`. You need to specify `certificate` if you select `ADFS`, because Azure Stack with ADFS authentication only supports the service principal with a certificate.
    * **resource** [String, optional]: Active Directory Service Endpoint Resource ID, where you can get the token for your AzureStack deployment.
    * **endpoint_prefix** [String, optional]: The endpoint prefix for your AzureStack deployment. Default is `management`.
    * **skip\_ssl\_validation** [Boolean, optional]: Toggles verification of the Azure Resource Manager REST API SSL certificate. Default is `false`. Deprecated in v35.0.0+.
    * **use\_http\_to\_access\_storage\_account** [Boolean, optional]: Flag for using HTTP to access storage account rather than the default HTTPS. Default is `false`. Deprecated in v35.0.0+.
    * **ca_cert** [String, required]: All required custom CA certificates for AzureStack. You can [export the Azure Stack CA root certificate](https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-connect-cli#export-the-azure-stack-ca-root-certificate). Available in v27+.
        * The property is required for v35.0.0+.
        * For the versions from v27 to v34, if `ca_cert` is not provided, the `skip_ssl_validation` and `use_http_to_access_storage_account` must be set to `true`.
* **parallel\_upload\_thread\_num** [Integer, optional]: The number of threads to upload stemcells in parallel. The default value is 16.
* **debug_mode** [Boolean, optional]: Enable debug mode. The default value is `false`. When `debug_mode` is `true`:
    * CPI will log all raw HTTP requests/responses.
    * For Azure CPI v26~v35.1.0, the new created VMs (only for VMs in same region with `storage_account_name` specified in [Global Configuration](https://bosh.io/docs/azure-cpi.html#global)) will have [boot diagnostics](https://azure.microsoft.com/en-us/blog/boot-diagnostics-for-virtual-machines-v2/) enabled. **Note**: For Azure CPI v35.2.0+, VM boot diagnostics will NOT be configured by `debug_mode` any more, it will be configured by `enable_vm_boot_diagnostics`.
* **use\_managed\_disks** [Boolean, optional]: Enable managed disks. The default value is `false`. For `AzureCloud`, the option is supported in v21+. For `AzureChinaCloud`, `AzureUSGovernment`, and `AzureGermanCloud`, the option is supported in v26+. For `AzureStack`, the option is not yet supported.
* **pip\_idle\_timeout\_in\_minutes** [Integer, optional]: Set idle timeouts in minutes for dynamic public IPs. It must be in the range [4, 30]. The default value is 4. It is only used when **assign\_dynamic\_public\_ip** is set to `true` in **resouce_pool**. Available in V24+.
* **keep\_failed\_vms** [Boolean, optional]: A flag to keep the failed VM. If it's set to `true` and CPI fails to **provision** the VM, CPI will keep the VM for troubleshooting. The default value is `false`. Available in v32+. Please note that the option is different from **keep\_unreachable\_vms** of the [director configuration](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh). The latter is to keep the VM whose BOSH agent is unresponsive.
* **enable_telemetry** [Boolean, optional]: A flag to enable telemetry on CPI calls on Azure. Available since v35.2.0. The default value is `true` in v35.2.0, and is `false` in v35.3.0+.
* **enable\_vm\_boot\_diagnostics** [Boolean, optional]: A flag to enable VM boot diagnostics on Azure. Available since v35.2.0. The default value is `true` in v35.2.0, and is `false` in v35.3.0+.

See [all configuration options](https://bosh.io/jobs/azure_cpi?source=github.com/cloudfoundry/bosh-azure-cpi-release).

See [Creating Azure resources](azure-resources.md) page for more details on how to create and configure above resources.

Example with hard-coded credentials:

```yaml
environment: AzureCloud
subscription_id: 3c39a033-c306-4615-a4cb-260418d63879
tenant_id: 0412d4fa-43d2-414b-b392-25d5ca46561da
client_id: 33e56099-0bde-8z93-a005-89c0f6df7465
client_secret: client-secret
resource_group_name: bosh-res-group
storage_account_name: boshstore
ssh_user: vcap
ssh_public_key: "ssh-rsa AAAAB3N...6HySEF6IkbJ"
default_security_group: nsg-azure
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
- name: z2

vm_types:
- name: default
  cloud_properties:
    instance_type: Standard_A2

disk_types:
- name: default
  disk_size: 10_240

networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    dns: [168.63.129.16]
    azs: [z1, z2]
    cloud_properties:
      virtual_network_name: boshnet
      subnet_name: boshsub
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: default
```
