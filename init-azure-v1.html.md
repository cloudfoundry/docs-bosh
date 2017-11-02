---
title: Creating environment on Azure
---

<p class="note">Note: See <a href="init-azure.html">Creating environment on Azure</a> with CLI v2. (Recommended)</p>

This document shows how to initialize new [environment](terminology.html#environment) on Microsoft Azure.

If you do not have an Azure account, [create one](https://azure.microsoft.com/en-us/pricing/free-trial/).

Then follow this [guide](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/get-started/create-service-principal.md) to create your Azure service principal.

We strongly recommend you to use Azure template [bosh-setup](https://azure.microsoft.com/en-us/documentation/templates/bosh-setup/) to initialize the new environment on Microsoft Azure.

## <a id="create-manifest"></a>Step 1: Create a Deployment Manifest

1. Create a deployment directory.

    <pre class='terminal'>
    $ mkdir ~/my-bosh
    </pre>

1. Create a deployment manifest file named `bosh.yml` in the deployment directory based on the template below.

    In the template, you must fill in the relevant properties of your Azure account. We describe replacing these properties in the section [Prepare an Azure Environment](#prepare).

    <p class="note"><strong>Note</strong>: The example below uses several predefined passwords. We strongly recommend replacing them with uniquely generated passwords.</p>

<pre id="manifest">
---
name: bosh

releases:{{ range .Releases }}
- name: {{ .Name }}
  url: {{ .UserVisibleDownloadURL }}
  sha1: {{ .TarballSHA1 }}{{ end }}

resource_pools:
- name: vms
  network: private
  stemcell:
    url: {{ .Stemcell.UserVisibleDownloadURL }}
    sha1: {{ .Stemcell.SHA1 }}
  cloud_properties:
    instance_type: Standard_D1 # Instance size must have 1.75GiB RAM or greater (do not use Standard_A0).

disk_pools:
- name: disks
  disk_size: 20_000

networks:
- name: private
  type: manual
  subnets:
  - range: 10.0.0.0/24
    gateway: 10.0.0.1
    dns: [168.63.129.16]
    cloud_properties:
      virtual_network_name: VNET-NAME # <--- Replace
      subnet_name: SUBNET-NAME # <--- Replace
- name: public
  type: vip

jobs:
- name: bosh
  instances: 1

  templates:
  - {name: nats, release: bosh}
  - {name: postgres, release: bosh}
  - {name: blobstore, release: bosh}
  - {name: director, release: bosh}
  - {name: health_monitor, release: bosh}
  - {name: registry, release: bosh}
  - {name: azure_cpi, release: bosh-azure-cpi}

  resource_pool: vms
  persistent_disk_pool: disks

  networks:
  - name: private
    static_ips: [10.0.0.4]
    default: [dns, gateway]
  - name: public
    static_ips: [PUBLIC-IP] # <--- Replace

  properties:
    nats:
      address: 127.0.0.1
      user: nats
      # password: nats-password # <--- Uncomment & change

    postgres: &db
      listen_address: 127.0.0.1
      host: 127.0.0.1
      user: postgres
      # password: postgres-password # <--- Uncomment & change
      database: bosh
      adapter: postgres

    registry:
      address: 10.0.0.4
      host: 10.0.0.4
      db: *db
      http:
        user: admin
        # password: admin # <--- Uncomment & change
        port: 25777
      username: admin
      password: admin
      port: 25777

    blobstore:
      address: 10.0.0.4
      port: 25250
      provider: dav
      director:
        user: director
        # password: director-password # <--- Uncomment & change
      agent:
        user: agent
        # password: agent-password # <--- Uncomment & change

    director:
      address: 127.0.0.1
      name: my-bosh
      db: *db
      cpi_job: azure_cpi
      max_threads: 10
      user_management:
        provider: local
        local:
          users:
          # - {name: admin, password: admin} # <--- Uncomment & change
          # - {name: hm, password: hm-password} # <--- Uncomment & change

    hm:
      director_account:
        user: hm
        # password: hm-password # <--- Uncomment & change
      resurrector_enabled: true

    azure: &azure
      environment: AzureCloud
      subscription_id: SUBSCRIPTION-ID # <--- Replace
      tenant_id: TENANT-ID # <--- Replace
      client_id: CLIENT-ID # <--- Replace
      client_secret: CLIENT-SECRET # <--- Replace
      resource_group_name: RESOURCE-GROUP-NAME # <--- Replace
      storage_account_name: STORAGE-ACCOUNT-NAME # <--- Replace
      default_security_group: DEFAULT-SECURITY-GROUP # <--- Replace
      ssh_user: vcap
      ssh_public_key: SSH-PUBLIC-KEY # <--- Replace
      use_managed_disks: USE-MANAGED-DISKS # <--- Replace

    # agent: {mbus: "nats://nats:nats-password@10.0.0.4:4222"} # <--- Uncomment & change

    ntp: &ntp [0.pool.ntp.org, 1.pool.ntp.org]

cloud_provider:
  template: {name: azure_cpi, release: bosh-azure-cpi}

  ssh_tunnel:
    host: PUBLIC-IP # <--- Replace
    port: 22
    user: vcap
    private_key: ./bosh # Path relative to this manifest file

  # mbus: "https://mbus:mbus-password@PUBLIC-IP:6868" # <--- Uncomment & change

  properties:
    azure: *azure
    # agent: {mbus: "https://mbus:mbus-password@0.0.0.0:6868"} # <--- Uncomment & change
    blobstore: {provider: local, path: /var/vcap/micro_bosh/data/cache}
    ntp: *ntp
</pre>

---
## <a id="prepare"></a> Step 2: Prepare an Azure Environment

To prepare your Azure environment find out and/or create any missing resources in Azure used in the manifest. If you are not familiar with Azure take a look at [Creating Azure resources](azure-resources.html) page for more details on how to create and configure necessary resources:

- Replace `SUBSCRIPTION-ID` (e.g. '3c39a033-c306-4615-a4cb-260418d63879')

- Replace `TENANT-ID` (e.g. '0412d4fa-43d2-414b-b392-25d5ca46561da')

- Replace `CLIENT-ID` (e.g. '33e56099-0bde-8z93-a005-89c0f6df7465')

- Replace `CLIENT-SECRET` (e.g. 'client-secret')

- Replace `RESOURCE-GROUP-NAME` (e.g. 'bosh-res-group')

- Replace `STORAGE-ACCOUNT-NAME` (e.g. 'boshstore')

- Replace `VNET-NAME` (e.g. 'boshnet') with a name of created Virtual Network.

- Replace `SUBNET-NAME` (e.g. 'bosh'). Deployment manifest assumes that the subnet is `10.0.0.0/24` and Director VM will be placed at `10.0.0.4`.

- Replace `DEFAULT-SECURITY-GROUP` (e.g. 'nsg-bosh') with the name of created network security group for BOSH.

- Replace `PUBLIC-IP` (e.g. '12.34.56.78') with the IP address of created public IP for BOSH.

- Replace `SSH-PUBLIC-KEY` with a generated SSH public key (found in `./bosh.pub`):

    <pre class="terminal">
    $ ssh-keygen -t rsa -f ~/bosh -P "" -C ""
    $ chmod 400 ~/bosh
    </pre>

    Keep `bosh` next to `bosh.yml` as it will be used by bosh-init during the deploy.

- Replace `USE-MANAGED-DISKS` with `true` or `false`.

    Using managed disks, you don't need to create [the default storage account](azure-resources.html#storage-account).

    The following properties should be changed:

    <pre class="terminal">
    azure:
      use_managed_disks: true

    disk_pools:
      cloud_properties:
        storage_account_type # New parameter: Standard_LRS or Premium_LRS

    resource_pools:
      cloud_properties:
        storage_account_name # Remove it if it exists
        storage_account_max_disk_number # Remove it if it exists
        storage_account_type # Remove it if it exists
    </pre>


---
## <a id="deploy"></a> Step 3: Deploy

1. Install [bosh-init](./install-bosh-init.html).

1. Run `bosh-init deploy ./bosh.yml` to start the deployment process.

    <pre class='terminal'>
    $ bosh-init deploy ./bosh.yml
    ...
    </pre>

    See [Azure CPI errors](azure-cpi.html#errors) for list of common errors and resolutions.

1. Install the [BOSH Command Line Interface (CLI)](./bosh-cli.html).

1. Use `bosh target 10.0.0.4` to log into your new BOSH Director. Above manifest specifies username and password as `admin`.

    <pre class="terminal">
    $ bosh target 10.0.0.4

    Target set to 'bosh'
    Your username: admin
    Enter password: *****
    Logged in as 'admin'

    $ bosh vms

    No deployments
    </pre>

1. Save the deployment state file and `bosh` left in your deployment directory so you can later update/delete your Director. See [Deployment state](using-bosh-init.html#deployment-state) section of 'Using bosh-init' for more details.

---
[Back to Table of Contents](index.html#install)

Previous: [Bootstrapping an environment](init.html)
