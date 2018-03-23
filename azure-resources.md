---
title: Creating Azure Resources
---

## <a id="subscription"></a> Subscription

To find out subscription and tenant ID use following commands:

<p class="note">Note: All azure commands were tested with the azure-cli v[2.0.21] on Ubuntu 16.04. The azure commands may vary based on your version and OS.</p>

```shell
$ az cloud set --name AzureCloud

$ az login

$ az account list --output json
[
  {
    "cloudName": "AzureCloud",
    "id": "my-subscription-id",
    "isDefault": true,
    "name": "my-subscription-name",
    "state": "Enabled",
    "tenantId": "my-tenant-id",
    "user": {
      "name": "my-user-name",
      "type": "user"
    }
  }
]
```

<p class="note">
Note:
If `tenantId` is not present, you may be using a personal account to log in to your Azure subscription. Switch to using work or school account.
If you are using Azure cloud in China, you should switch the cloud from `AzureCloud` to `AzureChinaCloud`.
If you are using Azure cloud in Azure Government, you should switch the cloud from `AzureCloud` to `AzureUSGovernment`.
If you are using Azure cloud in German Cloud, you should switch the cloud from `AzureCloud` to `AzureGermanCloud`.
</p>

Once you've determined your subscription ID, switch to using that account:

```shell
$ az account set --subscription my-subscription-id
```

Register the required providers:

```shell
$ az provider register --namespace Microsoft.Network
$ az provider register --namespace Microsoft.Storage
$ az provider register --namespace Microsoft.Compute
```

---
## <a id="client"></a> Client

Azure CPI needs client ID and secret to make authenticated requests.

```shell
$ az ad app create --display-name "mycpi" --password client-secret --identifier-uris "http://mycpi" --homepage "http://mycpi"
{
  "appId": "my-app-id",
  "appPermissions": null,
  "availableToOtherTenants": false,
  "displayName": "mycpi",
  "homepage": "http://mycpi",
  "identifierUris": [
    "http://mycpi"
  ],
  "objectId": "my-object-id",
  "objectType": "Application",
  "replyUrls": []
}
```

Application ID (`my-app-id` in the above output) is the client ID and specified password (`client-secret` in above example) is the client secret.

Finally create service principal to enable authenticated access:

```shell
$ az ad sp create --id my-app-id
$ az role assignment create --role "Contributor" --assignee "http://mycpi" --scope /subscriptions/my-subscription-id
```

---
## <a id="res-group"></a> Resource Group

Create a resource group in one of the supported [Azure locations](http://azure.microsoft.com/en-us/regions/):

```shell
$ az group create --name bosh-res-group --location "Central US"

$ az group show --name bosh-res-group
{
  "id": "/subscriptions/my-subscription-id/resourceGroups/bosh-res-group",
  "location": "centralus",
  "managedBy": null,
  "name": "bosh-res-group",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null
}
```

Make sure to wait for 'Provisioning State' to become `Succeeded`.

---
## <a id="virtual-network"></a> Virtual Network & Subnet

Create a virtual network:

```shell
$ az network vnet create --name boshnet --address-prefixes 10.0.0.0/8 --resource-group bosh-res-group --location "Central US" --dns-server 168.64.129.16
$ az network vnet subnet create --name bosh --address-prefix 10.0.0.0/24 --vnet-name boshnet --resource-group bosh-res-group

$ az network vnet show --name boshnet --resource-group bosh-res-group
{
  "addressSpace": {
    "addressPrefixes": [
      "10.0.0.0/8"
    ]
  },
  "dhcpOptions": {
    "dnsServers": [
      "168.64.129.16"
    ]
  },
  "enableDdosProtection": false,
  "enableVmProtection": false,
  "etag": "W/\"e62167ab-0e8c-4e78-9d78-18d1a963da2e\"",
  "id": "/subscriptions/my-subscription-id/resourceGroups/bosh-res-group/providers/Microsoft.Network/virtualNetworks/boshnet",
  "location": "centralus",
  "name": "boshnet",
  "provisioningState": "Succeeded",
  "resourceGroup": "bosh-res-group",
  "resourceGuid": "9fa33ff9-2a3f-4139-8e03-af0cc3af67a0",
  "subnets": [
    {
      "addressPrefix": "10.0.0.0/24",
      "etag": "W/\"e62167ab-0e8c-4e78-9d78-18d1a963da2e\"",
      "id": "/subscriptions/my-subscription-id/resourceGroups/bosh-res-group/providers/Microsoft.Network/virtualNetworks/boshnet/subnets/bosh",
      "ipConfigurations": null,
      "name": "bosh",
      "networkSecurityGroup": null,
      "provisioningState": "Succeeded",
      "resourceGroup": "bosh-res-group",
      "resourceNavigationLinks": null,
      "routeTable": null,
      "serviceEndpoints": null
    }
  ],
  "tags": {},
  "type": "Microsoft.Network/virtualNetworks",
  "virtualNetworkPeerings": []
}
```

---
## <a id="network-security-group"></a> Network Security Group

Create two network security groups:

```shell
$ az network nsg create --resource-group bosh-res-group --location "Central US" --name nsg-bosh
$ az network nsg create --resource-group bosh-res-group --location "Central US" --name nsg-cf

$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-bosh --access Allow --protocol Tcp --direction Inbound --priority 200 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'ssh' --destination-port-range 22
$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-bosh --access Allow --protocol Tcp --direction Inbound --priority 201 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'bosh-agent' --destination-port-range 6868
$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-bosh --access Allow --protocol Tcp --direction Inbound --priority 202 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'bosh-director' --destination-port-range 25555
$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-bosh --access Allow --protocol '*' --direction Inbound --priority 203 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'dns' --destination-port-range 53

$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-cf --access Allow --protocol Tcp --direction Inbound --priority 201 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'cf-https' --destination-port-range 443
$ az network nsg rule create --resource-group bosh-res-group --nsg-name nsg-cf --access Allow --protocol Tcp --direction Inbound --priority 202 --source-address-prefix Internet --source-port-range '*' --destination-address-prefix '*' --name 'cf-log' --destination-port-range 4443
```

---
## <a id="public-ips"></a> Public IPs

To make certain VMs publicly accessible, you will need to create a Public IP. If Azure Availability Zones is used in [AZs](azure-cpi.md#azs), the Public IP should be created with type `Standard SKU`; otherwise, you can use the default `Basic SKU`.

```shell
$ az network public-ip create --name my-public-ip --allocation-method Static --resource-group bosh-res-group --location "Central US" --sku Basic # sku should be `Standard' when using Azure Availability Zones

$ az network public-ip show --name my-public-ip --resource-group bosh-res-group
{
  "dnsSettings": null,
  "etag": "W/\"b3686484-21fe-470a-a059-32d02b4f9589\"",
  "id": "/subscriptions/my-subscription-id/resourceGroups/bosh-res-group/providers/Microsoft.Network/publicIPAddresses/my-public-ip",
  "idleTimeoutInMinutes": 4,
  "ipAddress": "13.89.236.107",
  "ipConfiguration": null,
  "location": "centralus",
  "name": "my-public-ip",
  "provisioningState": "Succeeded",
  "publicIpAddressVersion": "IPv4",
  "publicIpAllocationMethod": "Static",
  "resourceGroup": "bosh-res-group",
  "resourceGuid": "a25d2f1e-d8f7-4258-9c83-7c30e4a2c270",
  "sku": {
    "name": "Basic"
  },
  "tags": null,
  "type": "Microsoft.Network/publicIPAddresses",
  "zones": null
}

```

<p class="note">
Note:
You can skip below section if you are using managed disks with Azure CPI v21+
</p>

---
## <a id="storage-account"></a> Storage Account

Create a default storage account to hold root disks, persistent disks, stemcells, etc.
If unsure of desired SKU Name, choose `LRS`, desired Kind, choose `Storage`:

```shell
$ az storage account create --name myboshstore --resource-group bosh-res-group --location "Central US"

$ az storage account show --name myboshstore --resource-group bosh-res-group
{
  "accessTier": null,
  "creationTime": "2017-11-21T03:36:36.568159+00:00",
  "customDomain": null,
  "enableHttpsTrafficOnly": false,
  "encryption": {
    "keySource": "Microsoft.Storage",
    "keyVaultProperties": null,
    "services": {
      "blob": {
        "enabled": true,
        "lastEnabledTime": "2017-11-21T03:36:36.571160+00:00"
      },
      "file": {
        "enabled": true,
        "lastEnabledTime": "2017-11-21T03:36:36.571160+00:00"
      },
      "queue": null,
      "table": null
    }
  },
  "id": "/subscriptions/my-subscription-id/resourceGroups/bosh-res-group/providers/Microsoft.Storage/storageAccounts/myboshstore",
  "identity": null,
  "kind": "Storage",
  "lastGeoFailoverTime": null,
  "location": "centralus",
  "name": "myboshstore",
  "networkRuleSet": {
    "bypass": "AzureServices",
    "defaultAction": "Allow",
    "ipRules": [],
    "virtualNetworkRules": []
  },
  "primaryEndpoints": {
    "blob": "https://myboshstore.blob.core.windows.net/",
    "file": "https://myboshstore.file.core.windows.net/",
    "queue": "https://myboshstore.queue.core.windows.net/",
    "table": "https://myboshstore.table.core.windows.net/"
  },
  "primaryLocation": "centralus",
  "provisioningState": "Succeeded",
  "resourceGroup": "bosh-res-group",
  "secondaryEndpoints": {
    "blob": "https://myboshstore-secondary.blob.core.windows.net/",
    "file": null,
    "queue": "https://myboshstore-secondary.queue.core.windows.net/",
    "table": "https://myboshstore-secondary.table.core.windows.net/"
  },
  "secondaryLocation": "eastus2",
  "sku": {
    "capabilities": null,
    "kind": null,
    "locations": null,
    "name": "Standard_RAGRS",
    "resourceType": null,
    "restrictions": null,
    "tier": "Standard"
  },
  "statusOfPrimary": "available",
  "statusOfSecondary": "available",
  "tags": {},
  "type": "Microsoft.Storage/storageAccounts"
}
```

<p class="note">Note: Even if create command returns an error, check whether the storage account is created successfully via `storage account show` command.</a>

Once storage account is created you can retrieve primary storage access key:

```shell
$ az storage account keys list --account-name myboshstore --resource-group bosh-res-group
[
  {
    "keyName": "key1",
    "permissions": "Full",
    "value": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  },
  {
    "keyName": "key2",
    "permissions": "Full",
    "value": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
]
```

---
### <a id="storage-account-container"></a> Storage Account Containers

CPI expects to find `bosh` and `stemcell` containers within a default storage account:

- `bosh` container is used for storing root and persistent disks.
- `stemcell` container is used for storing uploaded stemcells.

<p class="note">Note: If you are planning to use multiple storage accounts, make sure to set stemcell container permissions to "Public read access for blobs only".</a>

```shell
$ az storage container create --name bosh --account-name myboshstore --account-key xxx
$ az storage container create --name stemcell --account-name myboshstore --account-key xxx --public-access blob

$ az storage container list --account-name myboshstore --account-key xxx
[
  {
    "metadata": null,
    "name": "bosh",
    "properties": {
      "etag": "\"0x8D53091C3074416\"",
      "lastModified": "2017-11-21T03:41:34+00:00",
      "lease": {
        "duration": null,
        "state": null,
        "status": null
      },
      "leaseDuration": null,
      "leaseState": "available",
      "leaseStatus": "unlocked",
      "publicAccess": null
    }
  },
  {
    "metadata": null,
    "name": "stemcell",
    "properties": {
      "etag": "\"0x8D53091FB97748E\"",
      "lastModified": "2017-11-21T03:43:09+00:00",
      "lease": {
        "duration": null,
        "state": null,
        "status": null
      },
      "leaseDuration": null,
      "leaseState": "available",
      "leaseStatus": "unlocked",
      "publicAccess": "blob"
    }
  }
]
```

---
### <a id="storage-account-tables"></a> Storage Account Tables

To support multiple storage accounts, you need to create the following tables in the default storage account:

- `stemcells` is used to store metadata of stemcells in multiple storage accounts

```shell
$ az storage table create --name stemcells --account-name myboshstore --account-key xxx

$ az storage table list --account-name myboshstore --account-key xxx
[
  {
    "name": "stemcells"
  }
]
```
