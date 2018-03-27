---
title: BOSH Lite
---

BOSH Lite v2 is a Director VM running in VirtualBox (typically locally). It is managed via [CLI v2](cli-v2.md). Internally CPI uses containers to emulate VMs which makes it an excellent choice for:

- General BOSH exploration without investing time and resources to configure an IaaS
- Development of releases (including BOSH itself)
- Testing releases locally or in CI

---
## Install <a id="install"></a>

Follow below steps to get it running on locally on VirtualBox:

1. Check that your machine has at least 8GB RAM, and 100GB free disk space. Smaller configurations may work.

1. Install [CLI v2](cli-v2.md#install)

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

    Known working version:

    ```shell
    $ VBoxManage --version
    5.1...
    ````

    Note: If you encounter problems with VirtualBox networking try installing [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) as suggested by [Issue 202](https://github.com/cloudfoundry/bosh-lite/issues/202). Alternatively make sure you are on VirtualBox 5.1+ since previous versions had a [network connectivity bug](https://github.com/concourse/concourse-lite/issues/9).

1. Install Director VM

    ```shell
    $ git clone https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment

    $ mkdir -p ~/deployments/vbox

    $ cd ~/deployments/vbox
    ````

    Below command will try automatically create/enable Host-only network 192.168.50.0/24 ([details](https://github.com/cppforlife/bosh-virtualbox-cpi-release/blob/master/docs/networks-host-only.md)) and NAT network 'NatNetwork' with DHCP enabled ([details](https://github.com/cppforlife/bosh-virtualbox-cpi-release/blob/master/docs/networks-nat-network.md)).

    ```shell
    $ bosh create-env ~/workspace/bosh-deployment/bosh.yml \
      --state ./state.json \
      -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
      -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
      -o ~/workspace/bosh-deployment/bosh-lite.yml \
      -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
      -o ~/workspace/bosh-deployment/jumpbox-user.yml \
      --vars-store ./creds.yml \
      -v director_name="Bosh Lite Director" \
      -v internal_ip=192.168.50.6 \
      -v internal_gw=192.168.50.1 \
      -v internal_cidr=192.168.50.0/24 \
      -v outbound_network_name=NatNetwork
    ````

1. Alias and log into the Director

    ```shell
    $ bosh alias-env vbox -e 192.168.50.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)
    $ export BOSH_CLIENT=admin
    $ export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`
    ````

1. Confirm that it works

    ```shell
    $ bosh -e vbox env
    Using environment '192.168.50.6' as '?'

    Name: ...
    User: admin

    Succeeded
    ````

1. Optionally, set up a local route for `bosh ssh` commands or accessing VMs directly

    ```shell
    $ sudo route add -net 10.244.0.0/16     192.168.50.6 # Mac OS X
    $ sudo ip route add   10.244.0.0/16 via 192.168.50.6 # Linux (using iproute2 suite)
    $ sudo route add -net 10.244.0.0/16 gw  192.168.50.6 # Linux (using DEPRECATED route command)
    $ route add           10.244.0.0/16     192.168.50.6 # Windows
    ````


---
## Deploy example Zookeeper deployment <a id="deploy"></a>

Run through quick steps below or follow [deploy workflow](basic-workflow.md) that goes through the same steps but with more explanation.

1. Update cloud config

    ```shell
    $ bosh -e vbox update-cloud-config ~/workspace/bosh-deployment/warden/cloud-config.yml
    ````

1. Upload stemcell

    ```shell
    $ bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.17 \
      --sha1 1dad6d85d6e132810439daba7ca05694cec208ab
    ````

1. Deploy example deployment

    ```shell
    $ bosh -e vbox -d zookeeper deploy <(wget -O- https://raw.githubusercontent.com/cppforlife/zookeeper-release/master/manifests/zookeeper.yml)
    ````

1. Run Zookeeper smoke tests

    ```shell
    $ bosh -e vbox -d zookeeper run-errand smoke-tests
    ````


## Tips <a id="tips"></a>

* In case you need to SSH into the Director VM, see [Jumpbox](jumpbox.md).
* In case VirtualBox VM shuts down or reboots, you will have to re-run `create-env` command from above with `--recreate` flag. The containers will be lost after a VM restart, but you can restore your deployment with `bosh cck` command. Alternatively *Pause* the VM from the VirtualBox UI before shutting down VirtualBox host, or making your computer sleep.
