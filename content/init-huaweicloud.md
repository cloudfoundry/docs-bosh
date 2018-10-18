This document shows how to set up new [environment](terminology.md#environment) on HuaweiCloud Cloud (HuaweiCloud)

## Step 1: Prepare an HuaweiCloud Account {: #prepare-HuaweiCloud }

### Prerequisites {: #prerequisites }
 
 If you do not have an HuaweiCloud account, [create one](https://reg.huaweicloud.com/registerui/public/custom/register.html?locale=zh-cn#/register).
 To configure your HuaweiCloud account:

  * [Obtain HuaweiCloud credentials](#credentials)
  * [Create a Virtual Private Cloud (VPC)](#create-vpc)
  * [Create an Elastic IP](#create-eip)
  * [Create a Key Pair](#create-key-pair)
  * [Create and Configure Security Group](#create-security)

---
### Obtain HuaweiCloud Credentials {: #credentials }

 Follow [Creating Users](https://console.huaweicloud.com/iam/#/myCredential) to obtain the username and account.

---
### Create a Virtual Private Cloud (VPC) {: #create-vpc }

 1. Log on to the [VPC console](https://console.huaweicloud.com/vpc).
 1. Select the region of the VPC. The VPC and the cloud resources to deploy must be in the same region.
 1. Click Create VPC, configure the VPC according to the following information, and click OK.
 See [Create a VPC](https://console.huaweicloud.com/vpc/?region=cn-north-1&locale=en-us#/vpc/createVpc).

--- 
### Create an Elastic IP {: #create-eip }

 1. On the VPC Dashboard, click **Elastic IPs** and click **Create EIP**.
 1. Configure the EIP according to the following information, and then click **Buy Now** to complete the payment.
 See [Create an EIP](https://www.huaweicloud.com/en-us/product/eip.html).

---
### Create a Key Pair {: #create-key-pair }

 1. Log on to the [ECS console](https://auth.huaweicloud.com/authui/login.action?locale=en-us#/login).
 1. On the ECS Dashboard, In the left-side navigation pane, choose **Key Pairs**.
 1. On the Key Pairs page, click **Create Key Pair**.
 1. On the Create Key Pair page, enter a name for the key pair, and click **OK**.
 1. Save private key to `~/Downloads/bosh.pem`.
 See [Create an SSH key pair](https://support.huaweicloud.com/en-us/dew_faq/dew_01_0063.html)

---
### Create and Configure Security Group {: #create-security }

 Log on to the  VPC console.
In the left-side navigation pane, select Network > > Virtual Private Cloud > > Security group.
 1. On the VPC Dashboard, select **Security group**.
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
 See [Creating a Security Group](https://support.huaweicloud.com/usermanual-vpc/zh-cn_topic_0013748715.html)
 See [Add security group rules](https://support.huaweicloud.com/usermanual-vpc/zh-cn_topic_0030969470.html)

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
    $ bosh create-env bosh-deployment/bosh.yml --state=state.json \
 --vars-store=creds.yml \
 -o bosh-deployment/huaweicloud/cpi.yml \
 -v director_name=my-bosh \
 -v internal_cidr=192.168.0.0/24 \
 -v internal_gw=192.168.0.1 \
 -v internal_ip=192.168.0.2 \
 -v subnet_id=... \
 -v default_security_groups=[bosh] \
 -v region=cn-north-1 \
 -v auth_url=https://iam.cn-north-1.myhwclouds.com/v3 \
 -v az=cn-north-1a \
 -v default_key_name=bosh \
 -v huaweicloud_password=... \
 -v huaweicloud_username=... \
 -v huaweicloud_domain=... \
 -v huaweicloud_project=cn-north-1 \
 -v private_key=bosh.pem

    ```
     If running above commands outside of an HuaweiCloud VPC, refer to [Exposing environment on a public IP](init-external-ip.md) for additional CLI flags.
     See [HuaweiCloud CPI errors](huaweicloud-cpi-errors.md) for list of common errors and resolutions.
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
