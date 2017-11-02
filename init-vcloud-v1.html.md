---
title: Creating environment on vCloud
---

<p class="note">Note: See <a href="init-vcloud.html">Creating environment on vCloud</a> with CLI v2. (Recommended)</p>

This document shows how to initialize new [environment](terminology.html#environment) on vCloud.

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
  network: private
  stemcell:
    url: {{ .Stemcell.UserVisibleDownloadURL }}
    sha1: {{ .Stemcell.SHA1 }}
  cloud_properties:
    cpu: 2
    ram: 4_096
    disk: 20_000
  env:
    bosh:
      # c1oudc0w is a default password for vcap user
      password: "$6$4gDD3aV0rdqlrKC$2axHCxGKIObs6tAmMTqYCspcdvQXh3JJcvWOY2WGb4SrdXtnCyNaWlrf3WEqvYR2MYizEGp3kMmbpwBC6jsHt0"

disk_pools:
- name: disks
  disk_size: 20_000

networks:
- name: private
  type: manual
  subnets:
  - range: 10.0.0.0/24
    gateway: 10.0.0.1
    dns: [10.0.0.2]
    cloud_properties: {name: NETWORK-NAME} # <--- Replace with Network name

jobs:
- name: bosh
  instances: 1

  templates:
  - {name: nats, release: bosh}
  - {name: postgres, release: bosh}
  - {name: blobstore, release: bosh}
  - {name: director, release: bosh}
  - {name: health_monitor, release: bosh}
  - {name: vcloud_cpi, release: bosh-vcloud-cpi}

  resource_pool: vms
  persistent_disk_pool: disks

  networks:
  - {name: private, static_ips: [10.0.0.6]}

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
      address: 10.0.0.6
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
      cpi_job: vcloud_cpi
      max_threads: 4
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

    vcd: &vcd # <--- Replace values below
      url: VCLOUD-URL
      user: VCLOUD-USER
      password: VCLOUD-PASSWORD
      entities:
        organization: VDC-ORGANIZATION
        virtual_datacenter: VDC-NAME
        vapp_catalog: bosh-catalog
        media_catalog: bosh-catalog
        media_storage_profile: '*'
        vm_metadata_key: bosh-meta
      control: {wait_max: 900}

    # agent: {mbus: "nats://nats:nats-password@10.0.0.6:4222"} # <--- Uncomment & change

    ntp: &ntp [0.pool.ntp.org, 1.pool.ntp.org]

cloud_provider:
  template: {name: vcloud_cpi, release: bosh-vcloud-cpi}

  # mbus: "https://mbus:mbus-password@10.0.0.6:6868" # <--- Uncomment & change

  properties:
    vcd: *vcd
    # agent: {mbus: "https://mbus:mbus-password@0.0.0.0:6868"} # <--- Uncomment & change
    blobstore: {provider: local, path: /var/vcap/micro_bosh/data/cache}
    ntp: *ntp
</pre>

---
## <a id="prepare"></a> Step 2: Prepare a vCloud Environment

To prepare your vCloud environment find out and/or create any missing resources listed below:

- Replace `VCLOUD-URL` (e.g. 'https://jf629-vcd.vchs.vmware.com') with the URL of the vCloud Director.

- Replace `VCLOUD-USER` (e.g. 'root') and `VCLOUD-PASSWORD` (e.g. 'vmware') in your deployment manifest with vCloud user name and password. BOSH does not require user to be an admin; however, it does need certain user privileges.

- Replace `NETWORK-NAME` (e.g. 'VM Network') with the name of the vCloud network. Deployment manifest assumes that this network is `10.0.0.0/24` and Director VM will be placed at `10.0.0.6`.

- Replace `VDC-ORGANIZATION` (e.g. 'VDC-M127910816-4610-275')

- Replace `VDC-NAME` (e.g. 'VDC-M127910816-4610-275')

---
## <a id="deploy"></a> Step 3: Deploy

<p class="note">Note: See <a href="migrate-to-bosh-init.html">Migrating to bosh-init from the micro CLI plugin</a> if you have an existing MicroBOSH.</p>

1. Install [bosh-init](./install-bosh-init.html).

1. Run `bosh-init deploy ./bosh.yml` to start the deployment process.

    <pre class='terminal'>
    $ bosh-init deploy ./bosh.yml
    ...
    </pre>

1. Install the [BOSH Command Line Interface (CLI)](./bosh-cli.html).

1. Use `bosh target 10.0.0.6` to log into your new BOSH Director. The default username and password are `admin` and `admin`.

    <pre class="terminal">
    $ bosh target 10.0.0.6

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
