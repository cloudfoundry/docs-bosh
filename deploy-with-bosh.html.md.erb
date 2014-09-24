---
title: Deploying Distributed Software with BOSH
---

There are many ways to use BOSH to deploy distributed software.

For example, you could:

* Use multi-VM BOSH to deploy a BOSH release of a key-value store.
* Use multi-VM BOSH to deploy Cloud Foundry.
* Use MicroBOSH to deploy a distributed messaging service.

In this tutorial, we focus on yet another example: using MicroBOSH to deploy multi-VM BOSH.
This use case is appropriate if, for example, you want to use multi-VM BOSH as
your primary toolset for deploying other distributed software and for managing the lifecycle of that software.

When you work through this tutorial, you experience what the BOSH development
team thinks of as a canonical example of using BOSH.
Even if you plan to use BOSH in a different way, this story should provide a useful sense of
how things are supposed to work.

## <a id="prep"></a> Preparing to Deploy ##

Preparation consists of thinking through how to orchestrate the environment you want to deploy,
and how to configure the network and instrument VMs.
You need to set up your IaaS instance and collect the networking information that goes in the manifest.
Then you create the manifest and obtain a release and a stemcell.

### <a id="plan"></a> Plan how you want to orchestrate your environment ###

For the sake of this example, let's assume that you have decided to deploy BOSH to an environment with two VMs.
One reason you might do this is to implement a security architecture where the data-storing parts of BOSH
(Blobstore, Redis, and Postgres) reside on one VM, while the "thinking" parts of BOSH
(Director, Health Monitor, NATS, and PowerDNS) reside on the other.
This would allow you to restrict access to data, while allowing deployment operators freer access to
the BOSH Director.

The IaaS used in this example is vSphere.

### <a id="set-iaas"></a> Set up the IaaS ###

Collect the information about your vSphere and vCenter that you need to configure the environment.

This includes:

* The names for your datacenter, datastore, cluster, resource pool, and network.
* The IP addresses for your vCenter and network gateway.
* The IP addresses for the VMs to be deployed, called static IP addresses.
* The range of IP addresses of your network.
* The range of IP addresses that you want to reserve.
These, and the static IPs, are off-limits to BOSH when BOSH needs to dynamically use an IP address for tasks like compilation.
Always reserve the IP of the MicroBOSH that deploys BOSH.

### <a id="create-manifest"></a> Create the manifest ###

The manifest should incorporate the network configuration information for your IaaS.
It should also reflect the way you want to orchestrate the deployment across the multiple VMs.

For a suggestion about where to create the manifest and run BOSH deployment commands, see [Deploying MicroBOSH](./deploy-microbosh.html).

BOSH deploys VMs in the order listed in the manifest.
In this case you need to list the data-storing VM first, because the other VM has the BOSH Director.
The Blobstore, Redis, and Postgres all need to be up and running before the Director.

Use the **properties** block in the manifest to specify ephemeral disk (this is a vSphere-specific usage).

Refer to the [example manifest](#example-manifest) at the end of this topic.

### <a id="download-stemcell"></a> Download stemcell and release from public site ###

You [download](http://bosh-artifacts.cfapps.io/) the latest release of BOSH, and a stemcell suitable for your preferred combination of IaaS and VM type.
In this example, these are:

* The **bosh-2131** release
* The **vsphere esxi centos** stemcell

**Note**: Release numbers given in this example may be out of date by the time you read this.

### <a id="target"></a> Target and log into MicroBOSH ###

Ensure that the BOSH CLI runs on the MicroBOSH you want to use to deploy software.
(In some environments there might be more than one BOSH or MicroBOSH.)
You do this by passing the IP address of the MicroBOSH to the `bosh target` command.

<pre class="terminal">
$ bosh target 192.168.1.11
Target set to `boshtest-microbosh'
</pre>

Then log in on the MicroBOSH.
Run the `bosh vms` command which shows VMs that the (Micro)BOSH has deployed.
For now, `bosh vms` shows no VMs deployed.

<pre class="terminal">
$ bosh login admin ********
Logged in as `admin'

$ bosh vms
No deployments
</pre>

## <a id="deploying"></a> Deploying ##

Enact the [familiar pattern](./workflow.html#deploying) _upload stemcell, upload release, set deployment, deploy_.

### <a id="stemcell"></a> Upload the Stemcell ###

Pass the path to the stemcell you downloaded to the `bosh upload stemcell` command:

<pre class="terminal">
$ bosh upload stemcell ~/Downloads/bosh-stemcell-2131-vsphere-esxi-centos.tgz

Verifying stemcell...
File exists and readable                                     OK
Verifying tarball...

...

Uploading stemcell...

bosh-stemcell: 100% |ooooooooooooooooooooooooooooooooooooo| 558.9MB  39.4MB/s Time: 00:00:14
</pre>

### <a id="release"></a> Upload the Release ###

Pass the path to the release of BOSH you downloaded to the `bosh upload release` command:

<pre class="terminal">
$ bosh upload release ~/Downloads/bosh-2131.tgz

Verifying release...
File exists and readable                                     OK
Extract tarball                                              OK
Manifest exists                                              OK
Release name/version                                         OK

....

Release has been created
  bosh/42 (00:00:00)
Done                    1/1 00:00:00

Task 18 done

Started		2014-03-07 06:16:09 UTC
Finished	2014-03-07 06:16:10 UTC
Duration	00:00:01

Release uploaded
</pre>

### <a id="manifest"></a> Set Deployment with a Manifest ###

Pass the path to the manifest to the `bosh deployment` command:

<pre class="terminal">
$ bosh deployment /home/boshtest/bosh/manifest.yml
Deployment set to `/home/boshtest/bosh/manifest.yml'
</pre>

### <a id="deploy"></a> Deploy ###

Run the `bosh deploy` command:

<pre class="terminal">
$ bosh deploy
Getting deployment properties from director...
Compiling deployment manifest...
Please review all changes carefully
Deploying `manifest.yml' to `boshtest-microbosh' (type 'yes' to continue): yes

...

Started		2014-03-07 06:38:12 UTC
Finished	2014-03-07 06:39:52 UTC
Duration	00:01:40

Deployed `manifest.yml' to `boshtest-microbosh'
</pre>

## <a id="verify"></a> Verifying the Deployment ##

While the output you have seen indicates that deployment was successful,
you can run some basic checks on your new multi-VM BOSH.

Verify that your MicroBOSH has successfully deployed two VMs,
and that they have the expected IP addresses:

<pre class="terminal">
$ bosh vms
Deployment `bosh2'

Director task 33

Task 33 done

+-------------+---------+---------------+---------------+
| Job/index   | State   | Resource Pool | IPs           |
+-------------+---------+---------------+---------------+
| bosh_api/0  | running | default       | 192.168.1.232 |
| bosh_data/0 | running | default       | 192.168.1.233 |
+-------------+---------+---------------+---------------+

VMs total: 2
</pre>

Set your local BOSH CLI to communicate with the new BOSH Director:

<pre class="terminal">
$ bosh target 192.168.1.232
Target set to `bosh2'
Your username: admin
Enter password: *****
Logged in as `admin'
</pre>

Run `bosh status` to verify that everything looks right:

<pre class="terminal">
$ bosh status
Config
             /Users/pivotal/.bosh_config

Director
  Name       bosh2
  URL        https://192.168.1.232:25555
  Version    1.2131.0 (release:bee75ed2 bosh:bee75ed2)
  User       admin
  UUID       d2ad4585-ea92-4652-8c07-1ba6625b9220
  CPI        vsphere
  dns        enabled (domain_name: bosh)
  compiled_package_cache disabled
  snapshots  enabled

Deployment
  not set
</pre>


## <a id="example-manifest"></a> Example Manifest ##

~~~yaml
---
name: bosh2

director_uuid: 6bcdfa35-5d51-4d39-8360-6e2b97cad2bc

release: {name: bosh, version: 106}

networks:
- name: default
  subnets:
  - range: 192.168.1.0/24
    gateway: 192.168.1.1
    static:
    - 192.168.1.232
    - 192.168.1.233
    reserved:
    # .1 is special
    - 192.168.1.2 - 192.168.1.230
    - 192.168.1.240 - 192.168.1.254
    # .255 is special
    dns: [8.8.8.8]
    cloud_properties:
      name: 'CF_2'

resource_pools:
- name: default
  stemcell:
    name: bosh-vsphere-esxi-centos
    version: 2131
  network: default
  cloud_properties:
    cpu: 2
    ram: 512
    disk: 2_000

compilation:
  reuse_compilation_vms: true
  workers: 1
  network: default
  cloud_properties:
    ram: 512
    disk: 6_000
    cpu: 2

update:
  canaries: 1
  canary_watch_time: 30000-90000
  update_watch_time: 30000-90000
  max_in_flight: 1

jobs:
- name: bosh_data
  template: [blobstore, postgres, redis]
  instances: 1
  resource_pool: default
  persistent_disk: 8_000
  networks:
  - name: default
    static_ips: [192.168.1.233]

- name: bosh_api
  template: [nats, director, health_monitor, powerdns]
  instances: 1
  resource_pool: default
  networks:
  - name: default
    static_ips: [192.168.1.232]

properties:
  ntp: ["pool.ntp.org"]

  nats:
    user: nats
    password: nats-password
    address: 192.168.1.232
    port: 4222

  blobstore:
    address: 192.168.1.233
    port: 25251
    backend_port: 25552
    agent:
      user: agent
      password: agent-password
    director:
      user: director
      password: director-password

  postgres: &bosh_db
    user: bosh
    password: bosh-password
    host: 192.168.1.233
    port: 5432
    database: bosh

  redis:
    password: redis-password
    address: 192.168.1.233
    port: 25255

  director:
    name: bosh2
    address: 192.168.1.232
    port: 25555
    encryption: false
    # Check if the CPI for your IaaS supports snapshots, otherwise disable it.
    # As an example vCloud CPI 0.5.2 does not support snapshots
    enable_snapshots: true
    max_tasks: 100
    db: *bosh_db
    # If needed, limit the number of threads used to concurrently instantiate new vms (32 by default)
    # max_threads: 1

  hm:
    http:
      port: 25923
      user: admin
      password: admin-password
    director_account:
      user: admin
      password: admin-password
    intervals:
      poll_director: 60
      poll_grace_period: 30
      log_stats: 300
      analyze_agents: 60
      agent_timeout: 180
      rogue_agent_alert: 180
    loglevel: info
    email_notifications: false
    tsdb_enabled: false
    cloud_watch_enabled: false
    resurrector_enabled: true

  dns:
    address: 192.168.1.232
    recursor: 8.8.8.8
    db: *bosh_db

  vcenter:
    address: 192.168.1.3
    user: root
    password: vmware
    datacenters:
      - name: TEST_DATACENTER
        vm_folder:       SYSTEM_MICRO_VSPHERE_VMs
        template_folder: SYSTEM_MICRO_VSPHERE_Templates
        disk_path:       SYSTEM_MICRO_VSPHERE_Disks
        datastore_pattern:            datastore1
        persistent_datastore_pattern: datastore1
        allow_mixed_datastores: true
        clusters:
          - TEST_CLUSTER:
              resource_pool: TEST_RP
~~~
