---
title: Creating environment on vSphere
---

<p class="note">Note: See <a href="init-vsphere-v1.html">Initializing BOSH environment on vSphere</a> for using bosh-init instead of CLI v2. (Not recommended)</p>

This document shows how to set up new [environment](terminology.html#environment) on vSphere.

1. Install [CLI v2](./cli-v2.html).

1. Use `bosh create-env` command to deploy the Director.

    <pre class='terminal'>
    # Create directory to keep state
    $ mkdir bosh-1 && cd bosh-1

    # Clone Director templates
    $ git clone https://github.com/cloudfoundry/bosh-deployment

    # Fill below variables (replace example values) and deploy the Director
    $ bosh create-env bosh-deployment/bosh.yml \
        --state=state.json \
        --vars-store=creds.yml \
        -o bosh-deployment/vsphere/cpi.yml \
        -v director_name=bosh-1 \
        -v internal_cidr=10.0.0.0/24 \
        -v internal_gw=10.0.0.1 \
        -v internal_ip=10.0.0.6 \
        -v network_name="VM Network" \
        -v vcenter_dc=my-dc \
        -v vcenter_ds=datastore0 \
        -v vcenter_ip=192.168.0.10 \
        -v vcenter_user=root \
        -v vcenter_password=vmware \
        -v vcenter_templates=bosh-1-templates \
        -v vcenter_vms=bosh-1-vms \
        -v vcenter_disks=bosh-1-disks \
        -v vcenter_cluster=cluster1
    </pre>

    If Resource Pools want to be utilized, refer to [Deploying BOSH into Resource Pools](init-vsphere-rp.html) for additional CLI flags.

    Use the vSphere Web Client to find out and/or create any missing resources listed below:
    - Configure `vcenter_ip` (e.g. '192.168.0.10') with the IP of the vCenter.
    - Configure `vcenter_user` (e.g. 'root') and `vcenter_password` (e.g. 'vmware') with vCenter user name and password.
      BOSH does not require user to be an admin, but it does require the following [privileges](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release/blob/master/docs/required_vcenter_privileges.md).
    - Configure `vcenter_dc` (e.g. 'my-dc') with the name of the datacenter the Director will use for VM creation.
    - Configure `vcenter_vms` (e.g. 'my-bosh-vms') and `TEMPLATES-FOLDER-NAME` (e.g. 'my-bosh-templates') with the name of the folder created to hold VMs and the name of the folder created to hold stemcells. Folders will be automatically created under the chosen datacenter.
    - Configure `vcenter_ds` (e.g. 'datastore[1-9]') with a regex matching the names of potential datastores the Director will use for storing VMs and associated persistent disks.
    - Configure `vcenter_disks` (e.g. 'my-bosh-disks') with the name of the VMs folder. Disk folder will be automatically created in the chosen datastore.
    - Configure `vcenter_cluster` (e.g. 'cluster1') with the name of the vSphere cluster. Create cluster under the chosen datacenter in the Clusters tab.
    - Configure `network_name` (e.g. 'VM Network') with the name of the vSphere network. Create network under the chosen datacenter in the Networks tab. Above example uses `10.0.0.0/24` network and Director VM will be placed at `10.0.0.6`.
    - [Optional] Configure `vcenter_rp` (eg. 'my-bosh-rp') with the name of the vSphere resource pool. Create resource pool under the choosen datacenter in the Clusters tab.

    See [vSphere CPI errors](vsphere-cpi.html#errors) for list of common errors and resolutions.

1. Connect to the Director.

    <pre class="terminal">
    # Configure local alias
    $ bosh alias-env bosh-1 -e 10.0.0.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

    # Log in to the Director
    $ export BOSH_CLIENT=admin
    $ export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`

    # Query the Director for more info
    $ bosh -e bosh-1 env
    </pre>

1. Save the deployment state files left in your deployment directory `bosh-1` so you can later update/delete your Director. See [Deployment state](cli-envs.html#deployment-state) for details.

---
[Back to Table of Contents](index.html#install)

Previous: [Create an environment](init.html)
