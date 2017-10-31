---
title: Multi-CPI on AWS
---

This guide will help you to understand, setup the IaaS and configure you BOSH Director `cpi-config` and `cloud-config` to have a properly configure multi-cloud environment on AWS.

## Multi-CPI

In this guide we want to have BOSH configured to deploy VMs to two different regions from separate AWS Accounts, and have them securely connected through a VPN using IPSec. For simplicity reasons we're going to allow all internal traffic between the two VPCs, however this can be configured as desired by the operator.

<%= image_tag("images/multi-cpi/aws-iaas-topology.png") %>

## <a id="setup-iaas"></a> Setup the IaaS

Let's start by initializing the main AZ (AZ-1) to US West (N. California) following steps 1 through 2 [here](init-aws.html). This will give you a working BOSH Director in `us-west-1` region. You can perform deployments and everything should work fine.
To add a second AZ (AZ-2) to EU (Frankfurt) you only need to perform [step 1](init-aws.html#prepare-aws).

<p class="note">Note: If you want to use AWS VPC Peering make sure the aforementioned AZs are in the same region.</p>

## Connecting VPCs

The VMs on one AZ need to be able to talk to VMs on the other AZ. We're going to describe two ways this can be achieved. If both VPCs are in the same region you can simply use [AWS VPC Peering](multi-cpi-aws.html#vpc-peering) however if they are in different regions you will need to connect them through a [VPN](multi-cpi-aws.html#openvpn).

#### <a id="openvpn"></a> OpenVPN using IPSec

Here we are going to use the [OpenVPN BOSH Release](https://github.com/dpb587/openvpn-bosh-release) to connect both OpenVPN Server and client in each region like shown in the [topology image](multi-cpi-aws.html#aws-iaas-topology).

Let's start by creating the IaaS credentials and configuration files of each VPN deployment.

0. Setup local Multi-CPI directories:

    ```
    mkdir -p ~/workspace/multi-cpi-vpn

    pushd ~/workspace
      # Clone OpenVPN BOSH Release
      git clone git@github.com:dpb587/openvpn-bosh-release.git
      pushd openvpn-bosh-release
        git checkout v4.1.0
      popd

      # Clone Multi-CPI Knowledge-Base
      git clone git@github.com:cdutra/bosh-multi-cpi-kb.git
    popd

    cd ~/workspace/multi-cpi-vpn
    ```

0. Allocate AWS Elastic IPs for each VPN Server on their respective regions.

0. Create the the following files `~/workspace/multi-cpi-vpn/creds-az1.yml` and `~/workspace/multi-cpi-vpn/creds-az2.yml` with the following properties. You should have all this information from the [Setup the IaaS](multi-cpi-aws.html#setup-iaas) step.

    ```
    access_key_id: <aws-access-key-id>
    secret_access_key: <aws-secret-access-key>
    region: <aws-region>
    availability_zone: <aws-availability-zone>
    subnet_id: <subnet-id>
    wan_ip: <aws-elastic-public-ip> # Used by OpenVPN Server
    default_security_groups: <security-group-name>
    bootstrap_ssh_key_name: <ssh-key-name>
    bootstrap_ssh_key_path: <ssh-private-key>
    route_table_id: <aws-route-table-id> # e.g. rtb-4127673b
    ```

0. Generate Certificates for each server and client.

    ```
    bosh int \
      ~/workspace/bosh-multi-cpi-kb/templates/vpn-ca.yml \
      -l ~/workspace/multi-cpi-vpn/creds-az1.yml \
      --vars-store=~/workspace/multi-cpi-vpn/certs-vpn-az1.yml

    bosh int \
      ~/workspace/bosh-multi-cpi-kb/templates/vpn-ca.yml \
      -l ~/workspace/multi-cpi-vpn/creds-az2.yml \
      --vars-store=~/workspace/multi-cpi-vpn/certs-vpn-az2.yml
    ```

0. Deploy OpenVPN Servers for each AZ.

    ```
    # Create VPN Server on AZ-1
    bosh create-env \
      --vars-store ~/workspace/multi-cpi-vpn/certs-vpn-az1.yml \
      --state ./openvpn-az1-state.json \
      -o ~/workspace/openvpn-bosh-release/deployment/init-aws.yml \
      -o ~/workspace/openvpn-bosh-release/deployment/with-pushed-routes.yml \
      -o ~/workspace/bosh-multi-cpi-kb/templates/vpn-server-ops.yml \
      -o ~/workspace/bosh-multi-cpi-kb/templates/vpn-client-ops.yml \
      -l ~/workspace/multi-cpi-vpn/creds-az1.yml \
      -v "server_key_pair=$( bosh int ~/workspace/multi-cpi-vpn/certs-vpn-az1.yml --path /server_key_pair )" \
      -v 'push_routes=["10.0.0.0 255.255.255.0"]' \
      -v "lan_gateway=10.0.0.1" \
      -v "lan_ip=10.0.0.7" \
      -v "lan_network=10.0.0.0" \
      -v "lan_network_mask_bits=24" \
      -v "vpn_network=192.168.0.0" \
      -v "vpn_network_mask=255.255.255.0" \
      -v "vpn_network_mask_bits=24" \
      -v "remote_network_cidr_block=10.0.1.0/24" \
      -v "remote_vpn_ip=<az2-vpn-external-ip>" \
      -v "client_key_pair=$( bosh int ~/workspace/multi-cpi-vpn/certs-vpn-az2.yml --path /client_key_pair )" \
      ~/workspace/openvpn-bosh-release/deployment/openvpn.yml

    # Create VPN Server on AZ-2
    bosh create-env \
      --vars-store ~/workspace/multi-cpi-vpn/certs-vpn-az2.yml \
      --state ./openvpn-az2-state.json \
      -o ~/workspace/openvpn-bosh-release/deployment/init-aws.yml \
      -o ~/workspace/openvpn-bosh-release/deployment/with-pushed-routes.yml \
      -o ~/workspace/bosh-multi-cpi-kb/templates/vpn-server-ops.yml \
      -o ~/workspace/bosh-multi-cpi-kb/templates/vpn-client-ops.yml \
      -l ~/workspace/multi-cpi-vpn/creds-az2.yml \
      -v "server_key_pair=$( bosh int ~/workspace/multi-cpi-vpn/certs-vpn-az2.yml --path /server_key_pair )" \
      -v 'push_routes=["10.0.1.0 255.255.255.0"]' \
      -v "lan_gateway=10.0.1.1" \
      -v "lan_ip=10.0.1.7" \
      -v "lan_network=10.0.1.0" \
      -v "lan_network_mask_bits=24" \
      -v "vpn_network=192.168.1.0" \
      -v "vpn_network_mask=255.255.255.0" \
      -v "vpn_network_mask_bits=24" \
      -v "remote_network_cidr_block=10.0.0.0/24" \
      -v "remote_vpn_ip=<az1-vpn-external-ip>" \
      -v "client_key_pair=$( bosh int ~/workspace/multi-cpi-vpn/certs-vpn-az1.yml --path /client_key_pair )" \
      ~/workspace/openvpn-bosh-release/deployment/openvpn.yml
    ```

#### <a id="vpc-peering"></a> VPC Peering (Only work for VPCs in the same region)

Setting up a Peering Connection should be fairly simply, you need to create a Peering Connection between each region you want to connect. In our case, we have two VPCs so only one connection is required.

Steps:
1. Create the Peering Connection as shown in the image:

<%= image_tag("images/multi-cpi/peering-connection-creation.png") %>

2. From the Accepter VPC Account go into the console and click Accept Request. After accepting the request it will recommend you to edit the route tables from each VPC to allow traffic between them through the peering connection.

<%= image_tag("images/multi-cpi/peering-connection-accept.png") %>

3. Modify each VPC Route Table and add the other VPC's CIDR block with the Peering Connection as the target.

For AZ-1:
<%= image_tag("images/multi-cpi/route-table-az-1.png") %>

For AZ-2:
<%= image_tag("images/multi-cpi/route-table-az-2.png") %>

<p class="note">Note: If you want IPv6 traffic to be routed you also need to add the corresponding IPv6 CIDR blocks.</p>

## BOSH Director `cpi-config` and `cloud-config`

BOSH supports Multi-CPI since version v261+. You can find more information about cpi-config [here](cpi-config.html).

The final steps are to update your `cpi-config`:

```
bosh update-cpi-config <( \
cat <<EOF
cpis:
- name: CPI-AZ-1
  type: aws
  properties:
    access_key_id: ((az1_access_key_id))
    secret_access_key: ((az1_secret_access_key))
    default_key_name: az-1
    default_security_groups:
    - ((az1_security_group))
    region: us-west-1
- name: CPI-AZ-2
  type: aws
  properties:
    access_key_id: ((az2_access_key_id))
    secret_access_key: ((az2_secret_access_key))
    default_key_name: az-2
    default_security_groups:
    - ((az2_security_group))
    region: us-west-1
EOF
)
```

And `cloud-config`:

<p class="note">Note: The `azs` section of your `cloud-config` now contains the `cpi` key which available values are defined in your `cpi-config`.</p>

```
bosh update-cloud-config <( \
cat <<EOF
azs:
- cloud_properties:
    availability_zone: us-west-1a
  cpi: CPI-AZ-1
  name: AZ-1
- cloud_properties:
    availability_zone: us-west-1a
  cpi: CPI-AZ-2
  name: AZ-2

compilation:
  az: AZ-1
  network: private
  reuse_compilation_vms: true
  vm_type: default
  workers: 1

networks:
- name: private
  type: manual
  subnets:
  - az: AZ-1
    cloud_properties:
      subnet: subnet-f529c6da
    gateway: 10.0.0.1
    range: 10.0.0.0/24
    reserved:
    - 10.0.0.2-10.0.0.9
  - az: AZ-2
    cloud_properties:
      subnet: subnet-452ec16a
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.2-10.0.1.9

vm_types:
- cloud_properties:
    instance_type: t2.medium
  name: default

EOF
)
```
