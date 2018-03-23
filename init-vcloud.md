---
title: Creating environment on vCloud
---

This document shows how to initialize new [environment](terminology.html#environment) on vCloud.

1. Install [CLI v2](./cli-v2.html).

1. Use `bosh create-env` command to deploy the Director.

    ```shell
    # Create directory to keep state
    $ mkdir bosh-1 && cd bosh-1

    # Clone Director templates
    $ git clone https://github.com/cloudfoundry/bosh-deployment

    # Fill below variables (replace example values) and deploy the Director
    $ bosh create-env bosh-deployment/bosh.yml \
        --state=state.json \
        --vars-store=creds.yml \
        -o bosh-deployment/vcloud/cpi.yml \
        -v director_name=bosh-1 \
        -v internal_cidr=10.0.0.0/24 \
        -v internal_gw=10.0.0.1 \
        -v internal_ip=10.0.0.6 \
        -v network_name="VM Network" \
        -v vcloud_url=https://jf629-vcd.vchs.vmware.com \
        -v vcloud_user=root \
        -v vcloud_password=vmware \
        -v vcd_org=VDC-M127910816-4610-275 \
        -v vcd_name=VDC-M127910816-4610-275
    ```

    To prepare your vCloud environment find out and/or create any missing resources listed below:
    - Configure `vcloud_url` (e.g. 'https://jf629-vcd.vchs.vmware.com') with the URL of the vCloud Director.
    - Configure `vcloud_user` (e.g. 'root') and `vcloud_password` (e.g. 'vmware') in your deployment manifest with vCloud user name and password. BOSH does not require user to be an admin; however, it does need certain user privileges.
    - Configure `network_name` (e.g. 'VM Network') with the name of the vCloud network. Above example uses `10.0.0.0/24` network and Director VM will be placed at `10.0.0.6`.
    - Configure `vcd_org` (e.g. 'VDC-M127910816-4610-275')
    - Configure `vcd_name` (e.g. 'VDC-M127910816-4610-275')

1. Connect to the Director.

    ```shell
    # Configure local alias
    $ bosh alias-env bosh-1 -e 10.0.0.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

    # Log in to the Director
    $ export BOSH_CLIENT=admin
    $ export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`

    # Query the Director for more info
    $ bosh -e bosh-1 env
    ```

1. Save the deployment state files left in your deployment directory `bosh-1` so you can later update/delete your Director. See [Deployment state](cli-envs.html#deployment-state) for details.

---
[Back to Table of Contents](index.html#install)

Previous: [Create an environment](init.html)
