This document shows how to set up new [environment](terminology.md#environment) on Alibaba Cloud (Alicloud)

## Step 1: Prepare an Alicloud Account {: #prepare-alicloud }

If you do not have an Alicloud account, [create one](https://account.alibabacloud.com/register/intl_register.htm).

To configure your Alicloud account:

* [Obtain Alicloud credentials](#credentials)
* [Create a Virtual Private Cloud (VPC)](#create-vpc)
* [Create an Elastic IP](#create-eip)
* [Create a Key Pair](#create-key-pair)
* [Create and Configure Security Group](#create-security)

---
### Obtain Alicloud Credentials {: #credentials }

Your Alicloud credentials consist of an Access Key ID and a Secret Access Key. Follow [Creating RAM Users](https://www.alibabacloud.com/help/doc-detail/28647.htm) to create a new RAM user.

---
### Create a Virtual Private Cloud (VPC) {: #create-vpc }

1. Log on to the [VPC console](https://vpcnext.console.aliyun.com).

1. Select the region of the VPC. The VPC and the cloud resources to deploy must be in the same region.

1. Click Create VPC, configure the VPC and the VSwitch according to the following information, and click OK.

See [Create a VPC](https://www.alibabacloud.com/help/doc-detail/65430.htm).

---
### Create an Elastic IP {: #create-eip }

1. On the VPC Dashboard, click **Elastic IPs** and click **Create EIP**.

1. Configure the EIP according to the following information, and then click **Buy Now** to complete the payment.

See [Create an EIP](https://www.alibabacloud.com/help/doc-detail/65203.htm).


---
### Create a Key Pair {: #create-key-pair }

1. Log on to the [ECS console](https://ecs.console.aliyun.com).

1. In the left-side navigation pane, choose **Networks & Security** > **Key Pairs**.

1. On the Key Pairs page, select a region, and click **Create Key Pair**.

1. On the Create Key Pair page, enter a name for the key pair, and select **Automatically Create a Key Pair**.

1. Save private key to `~/Downloads/bosh.pem`.

See [Create an SSH key pair](https://www.alibabacloud.com/help/doc-detail/51793.htm)

---
### Create and Configure Security Group {: #create-security }

Log on to the  ECS console.
In the left-side navigation pane, select Networks & Security > > Security group.


1. On the ECS Dashboard, select **Networks & Security** and then select **Security group**.

1. Select a region and then click **Create Security Group**.

1. Complete the Create Security Group form with the following information:
    * **Security group name**: bosh
    * **Description**: BOSH deployed VMs
    * **VPC**: Select the "bosh" VPC that you created in [Create a Virtual Private Cloud](#create-vpc).

1. Select the created security group with group name "bosh", in the Actions column click Configure Rules.

1. On the Security Group Rules page, click Add Security Group Rules.

1. Fill out the Edit inbound rules form and click **Save**.

    !!! note
        It highly discouraged to run any production environment with <code>0.0.0.0/0</code> source or to make any BOSH management ports publicly accessible.

    <table border="1" class="nice">
      <tr>
        <th>Type</th>
        <th>Port Range</th>
        <th>Source</th>
        <th>Purpose</th>
      </tr>

      <tr><td>Custom TCP Rule</td><td>22</td><td>(My IP)</td><td>SSH access from CLI</td></tr>
      <tr><td>Custom TCP Rule</td><td>6868</td><td>(My IP)</td><td>BOSH Agent access from CLI</td></tr>
      <tr><td>Custom TCP Rule</td><td>25555</td><td>(My IP)</td><td>BOSH Director access from CLI</td></tr>

      <tr><td>All TCP</td><td>0 - 65535</td><td>ID of this security group</td><td>Management and data access</td></tr>
      <tr><td>All UDP</td><td>0 - 65535</td><td>ID of this security group</td><td>Management and data access</td></tr>
    </table>

See [Creating a Security Group](https://www.alibabacloud.com/help/doc-detail/25468.htm)

See [Add security group rules](https://www.alibabacloud.com/help/doc-detail/25471.htm)

---
## Step 2: Deploy {: #deploy }

1. Install [CLI v2](cli-v2.md).

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
        -o bosh-deployment/alicloud/cpi.yml \
        -o bosh-deployment/jumpbox-user.yml \
        -o bosh-deployment/misc/powerdns.yml \
        -o bosh-deployment/credhub.yml \
        -o bosh-deployment/uaa.yml \
        -v dns_recursor_ip=8.8.8.8 \
        -v director_name=bosh-1 \
        -v internal_cidr=10.0.0.0/24 \
        -v internal_gw=10.0.0.1 \
        -v internal_ip=10.0.0.6 \
        -v access_key_id=AKI... \
        -v secret_access_key=wfh28... \
        -v region=us-east-1 \
        -v zone=us-east-1a \
        -v vswitch_id=vsw-rj9rio... \
        -v security_group_id=sg-rj9dtcbw... \
        -v key_pair_name=bosh \
        -v private_key=~/Downloads/bosh.pem
    ```

    If running above commands outside of an Alicloud VPC, refer to [Exposing environment on a public IP](init-external-ip.md) for additional CLI flags.

    See [Alicloud CPI errors](alicloud-cpi-errors.md) for list of common errors and resolutions.

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

1. Save the deployment state files left in your deployment directory `bosh-1` so you can later update/delete your Director. See [Deployment state](cli-envs.md#deployment-state) for details.
