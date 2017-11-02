---
title: Azure CPI
---

This topic describes cloud properties for different resources created by the Azure CPI.

## <a id='azs'></a> AZs

Currently the CPI does not support any cloud properties for AZs.

Example:

```yaml
azs:
- name: z1
```

---
## <a id="networks"></a> Networks

### Dynamic Network or Manual Network

Schema for `cloud_properties` section:

* **resource\_group\_name** [String, optional]: Name of a resource group. If it is set, Azure CPI will search the virtual network and security group in this resource group. Otherwise, Azure CPI will search the virtual network and security group in `resource_group_name` in the global CPI settings.
* **virtual\_network\_name** [String, required]: Name of a virtual network. Example: `boshnet`.
* **subnet_name** [String, required]: Name of a subnet within virtual network.
* **security_group** [String, optional]: The [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) to apply to network interfaces of all VMs placed in this network. The security group of a network interface can be specified either in a resource pool(higher priority) or a network configuration(lower priority); if it is not specified, the default security group (specified by `default_security_group` in the global CPI settings) will be used.

See [how to create a virtual network and subnets](azure-resources.html#virtual-network).

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      resource_group_name: my-resource-group
      virtual_network_name: boshnet
      subnet_name: boshsub
```

### Vip Network

Schema for `cloud_properties` section:

* **resource\_group\_name** [String, optional]: Name of a resource group. If it is set, Azure CPI will search the public IP in this resource group. Otherwise, Azure CPI will search the public IP in `resource_group_name` in the global CPI settings.

See [how to create public IP](azure-resources.html#public-ips) to use with vip networks.

Example of vip network:

```yaml
networks:
- name: public
  type: vip
  cloud_properties:
    resource_group_name: my-resource-group
```

---
## <a id="resource-pools"></a> Resource Pools / VM Types

Schema for `cloud_properties` section:

* **instance_type** [String, required]: Type of the [instance](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/). Example: `Standard_A2`. [Basic Tier Virtual Machines](https://azure.microsoft.com/en-us/blog/basic-tier-virtual-machines-2/) should not be used if you need to bind the instance to Azure Load Balancer (ALB), because Basic Tier VM doesn't support ALB.
* **storage\_account\_name** [String, optional]: Storage account for VMs. Valid only when `use_managed_disks` is `false`. If this is not set, the VMs will be created in the default storage account. See [this document](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/tree/master/docs/advanced/deploy-cloudfoundry-for-enterprise#multiple-storage-accounts) for more details on why this option exists.
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
* **storage\_account\_max\_disk\_number** [Integer, optional]: Number of disks limitation in a storage account. Valid only when `use_managed_disks` is `false`. Default value is 30. This will be used only when **storage\_account\_name** is a pattern.
    * Every storage account has a limitation to host disks. You may hit the performance issue if you create too many disks in one storage account.
    * The maximum number of disks of a standard storage account is 40 because the maximum IOPS of a standard storage account is 20,000 and the maximum IOPS of a standard disk is 500.
    * If you are using premium storage account, Azure maps the disk size (rounded up) to the nearest Premium Storage Disk option (P10, P20 and P30). For example, a disk of size 100 GiB is classified as a P10 option.
      1. The maximum number of disks of a premium storage account is 280 if you are using P10 (128 GiB) as your disk type.
      1. The maximum number of disks of a premium storage account is 70 if you are using P20 (512 GiB) as your disk type.
      1. The maximum number of disks of a premium storage account is 35 if you are using P30 (1024 GiB) as your disk type.
    * **storage\_account\_max\_disk\_number** should be less than the maximum number. Suggest you to use (MAX - 10) as the value because CPI always creates VMs in parallel.
    * Please see more information about [azure-subscription-service-limits](https://azure.microsoft.com/en-us/documentation/articles/azure-subscription-service-limits/).
* **storage\_account\_type** [String, optional]: Storage account type. Valid only when `use_managed_disks` is `false`. It is required if the storage account does not exist. It can be either `Standard_LRS`, `Standard_ZRS`, `Standard_GRS`, `Standard_RAGRS` or `Premium_LRS`. You can click [**HERE**](http://azure.microsoft.com/en-us/pricing/details/storage/) to learn more about the type of Azure storage account.
* **storage\_account\_location** [String, optional]: Location of the storage account. This configuration is deprecated in CPI v25+: if you specify a storage account which does not exist, CPI (v25+) will create it automatically in the same location as VMs' VNET.
* **availability_set** [String, optional]: Name of an [availability set](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) to use for VMs. [More details](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/tree/master/docs/advanced/deploy-cloudfoundry-for-enterprise#availability-set).
    * If available set does not exist, it will be automatically created.
    * If `availability_set` is not specified, Azure CPI will search `env.bosh.group` as the name of availability set.
      1. [bosh release](https://bosh.io/releases/github.com/cloudfoundry/bosh?all=1) v258+ will generate a value for `env.bosh.group` automatically.
      1. On Azure the length of the availability set name must be between 1 and 80 characters. The name got from  `env.bosh.group` may be too long. CPI will truncate the name to the following format `az-MD5-[LAST-40-CHARACTERS-OF-GROUP]` if the length is greater than 80.
    * CPI v27+ will delete the empty availability set.
* **application_gateway** [String, optional]: Name of the [application gateway](https://azure.microsoft.com/en-us/services/application-gateway/) which the VMs should be associated to.
    * Support in CPI v28+.
    * You need to create the application gateway manually before configuring it. Please refer to [the guidance](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/tree/master/docs/advanced/application-gateway).
* **platform\_update\_domain_count** [Integer, optional]: The count of [update domain](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) in the availability set. Default value is `5`.
* **platform\_fault\_domain_count** [Integer, optional]: The count of [fault domain](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/) in the availability set. For unmanaged availability set, default value is `3`. For managed availability set, default value is `2`, because [some regions don't support 3 fault domains for now](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-manage-availability#configure-multiple-virtual-machines-in-an-availability-set-for-redundancy)
* **load_balancer** [String, optional]: Name of a [load balancer](https://azure.microsoft.com/en-us/documentation/articles/load-balancer-overview/) the VMs should belong to. You need to create the load balancer manually before configuring it. Note: [Basic Tier Virtual Machines](https://azure.microsoft.com/en-us/blog/basic-tier-virtual-machines-2/) (Example: `Basic_A1`) doesn't support Azure Load Balancer.
* **security_group** [String, optional]: The [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) to apply to network interfaces of all VMs placed in this resource pool. The security group of a network interface can be specified either in a resource pool(higher priority) or a network configuration(lower priority); if it is not specified, the default security group (specified by `default_security_group` in the global CPI settings) will be used.
* **caching** [String, optional]: Type of the disk caching of the VMs' OS disks. It can be either `None`, `ReadOnly` or `ReadWrite`. Default is `ReadWrite`.
* **root_disk** [Hash, optional]: OS disk of custom size.
    * **size** [Integer, optional]: Specifies the disk size in MiB.
      * The size must be greater than 3 * 1024 and less than the max disk size for [unmanaged](https://azure.microsoft.com/en-us/pricing/details/storage/unmanaged-disks/) or [managed](https://azure.microsoft.com/en-us/pricing/details/managed-disks/) disk. Please always use `N * 1024` as the size because Azure always uses GiB but not MiB.
      * It has a default value `30 * 1024` only when ephemeral_disk.use\_root\_disk is set to true.
* **ephemeral_disk** [Hash, optional]: Ephemeral disk to apply for all VMs that are in this resource pool. By default a data disk with the default size as below will be created as the ephemeral disk.
    * **use\_root\_disk** [Boolean, optional]: Enable to use OS disk to store the ephemeral data. The default value is false. When it is true, ephemeral_disk.size will not be used.
    * **size** [Integer, optional]: Specifies the disk size in MiB. If this is not set, the default size as below will be used. The size of the ephemeral disk for the BOSH VM should be larger than or equal to `30*1024` MiB. Please always use `N * 1024` as the size because Azure always uses GiB not MiB.
      * If the Azure temporary disk size for the instance type is less than `30*1024` MiB, the default size is `30*1024` MiB because the space may not be enough.
      * If the Azure temporary disk size for the instance type is larger than `1000*1024` MiB, the default size is `1000*1024` MiB because it is not expected to use such a large ephemeral disk in CF currently.
      * Otherwise, the Azure temporary disk size will be used as the default size. See more information about [Azure temporary disk size](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/).
* **assign\_dynamic\_public\_ip** [Boolean, optional]: Enable to create and assign dynamic public IP to the VM automatically (to solve the [azure SNAT issue](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/217)). Default value is `false`. Only the VM without vip will be assigned a dynamic public IP when this value is set to true, and the dynamic public IP will be deleted when the VM is deleted.
* **resource\_group\_name** [String, optional]: Name of a resource group (Available in v26+). If it is set, related resources will be created in this resource group; otherwise, they will be created in `resource_group_name` specified in the global CPI settings. The resources affected by this property are:
      1. Virtual Machine
      1. Network Interface Card
      1. Managed Disks (including OS disk, ephemeral disk, persistent disk and snapshot)
      1. Dynamic Public IP for the VM
      1. Availability Set

Example of a `Standard_A2` instance:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-azure-hyperv-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: Standard_A2
    availability_set: <availability-set-name>
    root_disk:
      size: 30_720
    ephemeral_disk:
      use_root_disk: false
      size: 30_720
```

---
## <a id="disk-pools"></a> Disk Pools / Disk Types

Schema for `cloud_properties` section:

* **caching** [String, optional]: Type of the disk caching. It can be either `None`, `ReadOnly` or `ReadWrite`. Default is `None`.
* **storage\_account\_type** [String, optional]: Storage account type. Valid only when `use_managed_disks` is `true`. It can be either `Standard_LRS` or `Premium_LRS`. You can click [**HERE**](http://azure.microsoft.com/en-us/pricing/details/storage/) to learn more about the type of Azure storage account.

Example of 10GB disk:

* **disk_size** [Integer, required]: Size of the disk in MiB. On Azure the disk size must be greater than 1 * 1024 and less than the max disk size for [unmanaged](https://azure.microsoft.com/en-us/pricing/details/storage/unmanaged-disks/) or [managed](https://azure.microsoft.com/en-us/pricing/details/managed-disks/) disk. Please always use `N * 1024` as the size because Azure always uses GiB not MiB.

```yaml
disk_pools:
- name: default
  disk_size: 10_240
```

---
## <a id="global"></a> Global Configuration

Schema:

* **environment** [String, required]: Azure environment name. Possible values are: `AzureCloud`, `AzureChinaCloud`, `AzureUSGovernment` (available in v19+), `AzureGermanCloud` (available in v22+) or `AzureStack`.
* **subscription_id** [String, required]: Subscription ID.
* **tenant_id** [String, required]: Tenant ID of the service principal.
* **client_id** [String, required]: Client ID of the service principal.
* **client_secret** [String, required]: Client secret of the service principal.
* **resource\_group\_name** [String, required]: Resource group name.
* **storage\_account\_name** [String, optional]: Storage account name. It will be used as a default storage account for VM disks and stemcells. If `use_managed_disks` is `false`, `storage_account_name` is required. Otherwise, `storage_account_name` is optional.
* **ssh_user** [String, required]: SSH username. Default: `vcap`.
* **ssh\_public\_key** [String, required]: SSH public key.
* **default\_security\_group** [String, required]: Name of the default [security group](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/) that will be applied to all created VMs.
* **azure\_stack** [Hash, optional]: Configration for AzureStack. Available in v23+.
    * **domain** [String, optional]: The domain for your AzureStack deployment. Default is `local.azurestack.external`.
    * **authentication** [String, optional]: The authentication type for your AzureStack deployment. Possible values are: `AzureAD`, `AzureStackAD` or `AzureStack`. Default is `AzureAD`.
    * **resource** [String, optional]: The token resource for your AzureStack deployment.
    * **endpoint\_prefix** [String, optional]: The endpoint prefix for your AzureStack deployment.  Default is `management`.
    * **skip\_ssl\_validation** [Boolean, optional]: Toggles verification of the Azure Resource Manager REST API SSL certificate. Default is `false`.
    * **use\_http\_to\_access\_storage\_account** [Boolean, optional]: Flag for using HTTP to access storage account rather than the default HTTPS. Default is `false`.
    * **ca_cert** [String, optional]: All required custom CA certificates for AzureStack. You can [export the Azure Stack CA root certificate](https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-connect-cli#export-the-azure-stack-ca-root-certificate). If `ca_cert` is not provided, the `skip_ssl_validation` and `use_http_to_access_storage_account` must be set to `true`. Available in v27+.
* **parallel\_upload\_thread\_num** [Integer, optional]: The number of threads to upload stemcells in parallel. The default value is 16.
* **debug_mode** [Boolean, optional]: Enable debug mode. The default value is `false`. When `debug_mode` is `true`:
    * CPI will log all raw HTTP requests/responses.
    * The new created VMs (only for VMs in same region with `storage_account_name` specified in [Global Configuration](https://bosh.io/docs/azure-cpi.html#global)) will have [boot diagnostics](https://azure.microsoft.com/en-us/blog/boot-diagnostics-for-virtual-machines-v2/) enabled. Available in v26+.
* **use\_managed\_disks** [Boolean, optional]: Enable managed disks. The default value is `false`. For `AzureCloud`, the option is supported in v21+. For `AzureChinaCloud`, `AzureUSGovernment`, and `AzureGermanCloud`, the option is supported in v26+. For `AzureStack`, the option is not yet supported.
* **pip\_idle\_timeout\_in\_minutes** [Integer, optional]: Set idle timeouts in minutes for dynamic public IPs. It must be in the range [4, 30]. The default value is 4. It is only used when **assign\_dynamic\_public\_ip** is set to `true` in **resouce_pool**. Available in V24+.

See [all configuration options](https://bosh.io/jobs/cpi?source=github.com/cloudfoundry-incubator/bosh-azure-cpi-release).

See [Creating Azure resources](azure-resources.html) page for more details on how to create and configure above resources.

Example with hard-coded credentials:

```yaml
properties:
  azure: &azure
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
## <a id='cloud-config'></a> Example Cloud Config

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

---
## <a id="errors"></a> Errors

* Invalid service principal

  ```
  http_get_response - get_token - http error: 400
  ```

  Service principal is most likely invalid. Verify that client ID, client secret and tenant ID successfully work:

  <pre class="terminal">
  $ azure login --username client-id --password client-secret --service-principal --tenant tenant-id
  </pre>

  If your service principal worked and you get the above error suddenly, it may be caused by that your service principal expired. You need to go to Azure Portal to update client secret. By default, the service principal will expire in one year.

  1. Go to [Azure Portal](https://manage.windowsazure.com/), select `active directory` -- > ORGANIZATION-NAME -- > `Applications` -- > search your service principal name.

  2. Then choose your service principal, select `Configure` -- > `keys` -- > add a new key.

* Exceeding quota limits of Core

  ```
  http_put - error: 409 message: {
    "error": {
      "code": "OperationNotAllowed",
      "message": "Operation results in exceeding quota limits of Core. Maximum allowed: 4, Current in use: 4, Additional requested: 1."
    }
  }
  ```

  Either upgrade your trial account, or file a support ticket in the Azure portal to raise account quotas.

* NicInUse

  ```
  http_delete - error: 400 message: {
      "error": {
          "code": "NicInUse",
          "message": "Network Interface /.../networkInterfaces/dc0d3a9a-0b00-40d8-830d-41e6f4ac9809 is used by existing VM /.../virtualMachines/dc0d3a9a-0b00-40d8-830d-41e6f4ac9809.",
          "details": []
      }
  }
  ```

  This error indicates that unknown VM (to the Director) took up the IP that the Director is trying to assign to a new VM. Either let the Director know to not use this IP by including it in the reserved section of a subnet in your manual network, or make that IP available by terminating the unknown VM.

* Limits of Premium Storage blob snapshots

  ```
  Error 100: Unknown CPI error 'Unknown' with message 'SnaphotOperationRateExceeded (409): The rate of snapshot blob calls is exceeded.
  ```

  The BOSH snapshot operation may be throttled if you do all of the following:

  * Use Premium Storage for the Cloud Foundry VMs.

  * Enable snapshot in `bosh.yml`. For more information on BOSH Snapshots, please go to https://bosh.io/docs/snapshots.html.

    ```
    director:
      enable_snapshots: true
    ```

  * The time between consecutive snapshots by BOSH is less than **10 minutes**. The limits are documented in [Snapshots and Copy Blob for Premium Storage](https://azure.microsoft.com/en-us/documentation/articles/storage-premium-storage/#snapshots-and-copy-blob).

  The workaround is:

  * Disable snapshot temporarily.

    ```
    director:
      enable_snapshots: false
    ```

  * Adjust the snapshot interval to more than 10 minutes.

* Version mismatch between CPI and Stemcell

  For CPI v11 or later, the compatible stemcell version is v3181 or later. If the stemcell version is older than v3181, you may hit the following failure when deploying BOSH.

  ```
  Performing POST request:
    Post https://mbus-user:<redacted>@10.0.0.4:6868/agent: dial tcp 10.0.0.4:6868: getsockopt: connection refused
  ```

  It is recommended to use the latest version. For example, Stemcell v3232.5 or later, and CPI v12 or later. You may hit the issue [#135](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/135) if you still use an older stemcell than v3232.5.

* Out of memory

  If you hit `Out of memory` or `Virtual memory exhausted`, please check whether you use Standard_A0 as instance_type. You should change instance_type to a VM size with more memory.
  Please reference the issue [#230](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/230).

---
[Back to Table of Contents](index.html#cpi-config)
