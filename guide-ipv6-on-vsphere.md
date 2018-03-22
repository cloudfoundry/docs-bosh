---
title: IPv6 on vSphere
---

<p class="note">BOSH supports IPv6 on vSphere since version bosh-release v264+, stemcell 3468.11+ and CLI v2.0.45+.</p>

In this guide we explore how to configure BOSH in an IPv6-enabled environment.

Two possible deployment options:

- pure IPv6 configuration: both Director and deployed VMs use IPv6 addresses exclusively (currently being worked on)

- hybrid IPv6 configuration: Director is on IPv4 and deployed VMs use IPv4 and IPv6 addresses

---
## <a id="hybrid"></a> Hybrid IPv6 configuration

In this example, we use the BOSH CLI and `bosh-deployment` to deploy a Director with an IPv4 address and then deploy VMs with IPv4 and IPv6 addresses.

### Prerequisites

- All IPv6 address *must* be specified in expanded format, leading zeroes, no double-colons. This applies to all variables, deployment manifests, cloud config, etc.

- Use Simple DNS's [generator](http://simpledns.com/private-ipv6) to obtain a _private_ IPv6 address range.

### Steps

1. To deploy the Director use `bosh create-env` command with additional IPv6-specific ops files. See [Creating environment on vSphere](init-vsphere.html) for more details on initializing Director on vSphere.

    <pre class="terminal">
    # Create directory to keep state
    $ mkdir ipv6 && cd ipv6

    # Clone Director templates
    $ git clone https://github.com/cloudfoundry/bosh-deployment

    $ bosh create-env bosh-deployment/bosh.yml \
        --state=state.json \
        --vars-store=creds.yml \
        -o bosh-deployment/vsphere/cpi.yml \
        -o bosh-deployment/vsphere/resource-pool.yml \
        -o bosh-deployment/jumpbox-user.yml \
        -o bosh-deployment/uaa.yml \
        -o bosh-deployment/credhub.yml \
        -v director_name=ipv6 \
        -v internal_cidr=10.0.9.0/24 \
        -v internal_gw=10.0.9.1 \
        -v internal_ip=10.0.9.111 \
        -v network_name="VM Network" \
        -v vcenter_dc=dc \
        -v vcenter_cluster=cl \
        -v vcenter_rp=IPv6 \
        -v vcenter_ds=SSD-0 \
        -v vcenter_ip=10.0.9.105 \
        -v vcenter_user=administrator@vsphere.local \
        -v vcenter_password=TheClothesMakethTheMan \
        -v vcenter_templates=bosh-ipv6-templates \
        -v vcenter_vms=bosh-ipv6-vms \
        -v vcenter_disks=bosh-ipv6-disks
    </pre>

1. Connect to the Director:

    <pre class="terminal">
    $ bosh alias-env ipv6 -e 10.0.9.111 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)
    $ export BOSH_CLIENT=admin
    $ export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`
    </pre>

1. Confirm that it works:

    <pre class="terminal">
    $ bosh -e ipv6 env
    Using environment '10.0.9.111' as '?'

    Name: ...
    User: admin

    Succeeded
    </pre>

### <a id="pure-deploy"></a> Deploy example Zookeeper deployment

Follow steps below or the [deploy workflow](basic-workflow.html) that goes through the same steps but with more explanation.

1. Update configs

    ```yaml
    # ipv6-net.yml

    networks:
    - name: ipv6
      type: manual
      subnets:
      - azs: [z1, z2, z3]
        cloud_properties:
          name: VM Network
        dns:
        - 2001:4860:4860:0000:0000:0000:0000:8888
        - 2001:4860:4860:0000:0000:0000:0000:8844
        gateway: 2601:646:100:69f0:20d:b9ff:fe48:9249
        range: 2601:0646:0100:69f0:0000:0000:0000:0000/64
        reserved:
        - 2601:0646:0100:69f0:0000:0000:0000:0000-2601:0646:0100:69f0:0000:0000:0000:0020
    ```

    <pre class="terminal">
    $ bosh -e ipv6 update-cloud-config ~/workspace/bosh-deployment/vsphere/cloud-config.yml \
        -v vcenter_cluster=cl \
        -v internal_cidr=10.0.9.0/24 \
        -v internal_gw=10.0.9.1 \
        -v network_name="VM Network" \

    $ bosh -e ipv6 update-config cloud --name ipv6 ipv6-net.yml

    $ bosh -e ipv6 update-runtime-config ~/workspace/bosh-deployment/runtime-configs/dns.yml
    </pre>

1. Upload stemcell

    <pre class="terminal">
    $ bosh -e ipv6 upload-stemcell https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent?v=3468.17 \
      --sha1 1691f18b9141ac59aec893a1e8437a7d68a88038
    </pre>

    Note that IPv6 is currently only available for Ubuntu Trusty stemcells.

1. Deploy example deployment and see IPv6 addresses

    ```yaml
    # ipv6-net-use.yml

    - type: replace
      path: /features?/use_dns_addresses
      value: true

    - type: replace
      path: /instance_groups/name=zookeeper/networks/0/default?
      value: [dns, gateway]

    - type: replace
      path: /instance_groups/name=zookeeper/networks/-
      value:
        name: ipv6

    - type: replace
      path: /instance_groups/name=smoke-tests/jobs/name=smoke-tests/consumes?/conn/network
      value: ipv6
    ```

    <pre class="terminal">
    $ bosh -e ipv6 -d zookeeper deploy <(wget -O- https://raw.githubusercontent.com/cppforlife/zookeeper-release/master/manifests/zookeeper.yml) \
      -o ipv6-net-use.yml

    $ bosh -e ipv6 -d zookeeper instances
    </pre>

1. Run Zookeeper smoke tests

    <pre class="terminal">
    $ bosh -e ipv6 -d zookeeper run-errand smoke-tests
    </pre>
