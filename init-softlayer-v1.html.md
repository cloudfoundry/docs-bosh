---
title: Initializing BOSH environment on SoftLayer
---

<p class="note">Note: See <a href="init-softlayer.html">Creating environment on SoftLayer</a> with CLI v2. (Recommended)</p>

This document shows how to initialize new [environment](terminology.html#environment) on SoftLayer.

## <a id="create-manifest"></a>Step 1: Create a Deployment Manifest

1. Create a deployment directory.

    <pre class='terminal'>
    $ mkdir ~/my-bosh
    </pre>

1. Create a deployment manifest file named `bosh.yml` in the deployment directory based on the template below.

    <p class="note"><strong>Note</strong>: The example below uses several predefined passwords. We recommend replacing them with passwords of your choice.</p>

<pre id="manifest">
---
name: bosh

releases:{{ range .Releases }}
- name: {{ .Name }}
  url: {{ .UserVisibleDownloadURL }}
  sha1: {{ .TarballSHA1 }}{{ end }}

resource_pools:
- name: vms
  network: default
  stemcell:
    url: {{ .Stemcell.UserVisibleDownloadURL }}
    sha1: {{ .Stemcell.SHA1 }}
  cloud_properties:
    Domain: softlayer.com
    VmNamePrefix: bosh-softlayer
    EphemeralDiskSize: 100
    StartCpus: 4
    MaxMemory: 8192
    Datacenter:
      Name: SOFTLAYER-DATACENTER-NAME # <--- Replace with the datacenter (eg lon02)
    HourlyBillingFlag: true
    PrimaryNetworkComponent:
      NetworkVlan:
        Id: SOFTLAYER-PUBLIC-VLAN # <--- Replace with the public VLAN ID
    PrimaryBackendNetworkComponent:
      NetworkVlan:
        Id: SOFTLAYER-PRIVATE-VLAN # <--- Replace with the private VLAN ID
    NetworkComponents:
    - MaxSpeed: 1000

disk_pools:
- name: disks
  disk_size: 40_000

networks:
- name: default
  type: dynamic
  dns: [8.8.8.8]

jobs:
- name: bosh
  instances: 1

  templates:
  - {name: nats, release: bosh}
  - {name: postgres, release: bosh}
  - {name: blobstore, release: bosh}
  - {name: director, release: bosh}
  - {name: health_monitor, release: bosh}
  - {name: powerdns, release: bosh}
  - {name: softlayer_cpi, release: bosh-softlayer-cpi}

  resource_pool: vms
  persistent_disk_pool: disks

  networks:
  - name: default

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

    blobstore:
      address: 127.0.0.1
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
      name: bosh
      cpi_job: softlayer_cpi
      db: *db
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

    dns:
      address: 127.0.0.1
      domain_name: bosh
      db: *db
      webserver:
        port: 8081
        address: 0.0.0.0

    softlayer: &softlayer
      username: SOFTLAYER-USER-ID # <--- Replace with your softlayer user id
      apiKey: SOFTLAYER-API-KEY # <--- Replace with your softlayer api key

    # agent: {mbus: "nats://nats:nats-password@bosh-softlayer.softlayer.com:4222"} # <--- Uncomment & change

    ntp: &ntp [0.pool.ntp.org, 1.pool.ntp.org]

cloud_provider:
  template: {name: softlayer_cpi, release: bosh-softlayer-cpi}

  # mbus: https://admin:admin-password@bosh-softlayer.softlayer.com:6868 # <--- Uncomment & change

  properties:
    softlayer: *softlayer
    # agent: {mbus: "https://admin:admin-password@bosh-softlayer.softlayer.com:6868"} # <--- Uncomment & change
    blobstore: {provider: local, path: /var/vcap/micro_bosh/data/cache}
    ntp: *ntp
</pre>

We need to specify the director hostname ``bosh-softlayer.softlayer.com`` in ``mbus: "nats://nats:nats-password@bosh-softlayer.softlayer.com:4222”`` or ``mbus: https://admin:admin-password@bosh-softlayer.softlayer.com:6868``. This is Softlayer specific. Before the director is created, we don't know its IP. Softlayer CPI will change the hostname to IP after the director is created.

---
## <a id="prepare"></a> Step 2: Prepare a SoftLayer Environment

To prepare your SoftLayer environment:

* [Create a SoftLayer account](#account)
* [Generate an API Key](#api-key)
* [Access SoftLayer VPN](#vpn)
* [Order VLANs](#vlan)

---
### <a id="account"></a> Create a Softlayer account

If you do not have an SoftLayer account, [create one for one month free](https://www.softlayer.com/promo/freeCloud).

Use the login credentials received in your provided email to login to SoftLayer [Customer Portal](https://control.softlayer.com).

---
### <a id="api-key"></a> Generate an API Key

API keys are used to securely access the SoftLayer API. Follow [Generate an API Key](http://knowledgelayer.softlayer.com/procedure/generate-api-key) to generate your API key.

---
### <a id="vpn"></a> Access SoftLayer VPN

To access SoftLayer Private network, you need to access SoftLayer VPN. Follow [VPN Access](http://www.softlayer.com/vpn-access) to access the VPN. You can get your VPN password from your [user profile](https://control.softlayer.com/account/user/profile). Follow [VPN Access](http://www.softlayer.com/vpn-access) to access the VPN.

---
### <a id="vlan"></a> Order VLANs

VLANs provide the ability to partition devices and subnets on the network. To order VLANs, login to SoftLayer [Customer Portal](https://control.softlayer.com) and navigate to Network > IP Management > VLANs. Once on the page, click the "Order VLAN" link in the top-right corner. Fill in the pop-up window to order the VLANs as you need. The VLAN IDs are needed in the deployment manifest.

---

## <a id="deploy"></a> Step 3: Deploy

<p class="note">Note: See <a href="migrate-to-bosh-init.html">Migrating to bosh-init from the micro CLI plugin</a> if you have an existing MicroBOSH.</p>

1. Install [bosh-init](./install-bosh-init.html).

1. Establish VPN connection between your host and Softlayer. The machine where to run bosh-init needs to communicate with the target director VM over the SoftLayer private network.

1. Run `bosh-init deploy ./bosh.yml` with sudo to start the deployment process. The reason why need to run `bosh-init deploy` with sudo is that it needs to update `/etc/hosts` file which needs suffient permission. 

    <pre class='terminal'>
    $ sudo bosh-init deploy ./bosh.yml
    ...
    </pre>

1. Install the [BOSH Command Line Interface (CLI)](./bosh-cli.html).

1. Use `bosh target DIRECTOR-IP` to log into your new BOSH Director. You can get the DIRECTOR-IP from /etc/hosts on boshcli vm. The default username and password are `admin` and `admin` if no user is configured in manifest in advance when deploying director or created by `bosh create user` command.

    <pre class="terminal">
    $ bosh target DIRECTOR-IP

    Target set to 'bosh'
    Your username: admin
    Enter password: *****
    Logged in as 'admin'

    $ bosh vms

    No deployments
    </pre>

1. Save the deployment state file left in your deployment directory so you can later update/delete your Director. See [Deployment state](using-bosh-init.html#deployment-state) section of 'Using bosh-init' for more details.

---
[Back to Table of Contents](index.html#install)

Previous: [Bootstrapping an environment](init.html)
