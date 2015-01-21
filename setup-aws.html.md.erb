---
title: Setting Up AWS for BOSH
---

This topic explains how to prepare AWS for deploying BOSH or MicroBOSH.

##<a id="hardware"></a>Step 1: Allocate Hardware Resources ##

Your intended use of BOSH determines what hardware resources you should allocate
in your IaaS.

For example:

* BOSH needs room to store the releases it deploys.
Larger applications or larger numbers of applications require more disk space.
* Larger numbers of active users require more RAM.

AWS describes hardware in terms of [instance types](http://aws.amazon.com/ec2/instance-types/).
The **m2.medium** instance type provides a balance of computer, memory, and
network resources suitable for many deployments.
For MicroBOSH, the **t2.small** instance might provide sufficient resources for
testing purposes, but can prove insufficient for production deployments.

##<a id="traffic"></a>Step 2: Restrict Network Traffic ##

Create and configure two security groups to restrict incoming network traffic to
the BOSH VMs.

###<a id="ssh"></a>SSH Security Group ###

To create an SSH Security Group:

1. Create a security group named **SSH**.

1. Add the following rules to the SSH Security Group:

<table border="1" class="nice" >
  <tr><th>Type</th><th>Port</th><th>Source</th><th>User or Purpose</th></tr>
  <tr><td>UDP</td><td>68</td><td>0.0.0.0/0</td><td>BOOTP/DHCP</td></tr>
  <tr><td>TCP</td><td>22</td><td>0.0.0.0/0</td><td>SSH</td></tr>
  <tr><td>ICMP</td><td>-1</td><td>0.0.0.0/0</td><td>ping</td></tr>
</table>

###<a id="bosh"></a>BOSH Security Group ###

To create a BOSH Security Group:

1. Create a security group named **BOSH**.

1. Add the following rules to the BOSH Security Group:

<table border="1" class="nice" >
  <tr><th>Type</th><th>Port / Port Range</th><th>Source</th><th>User or Purpose</th></tr>
  <tr><td>TCP</td><td>1-65535</td><td>BOSH</td><td>Members of the BOSH Security Group</td></tr>
  <tr><td>UDP</td><td>53</td><td>0.0.0.0/0</td><td>Inbound DNS requests</td></tr>
  <tr><td>UDP</td><td>68</td><td>0.0.0.0/0</td><td>BOOTP/DHCP</td></tr>
  <tr><td>TCP</td><td>4222</td><td>0.0.0.0/0</td><td>NATS</td></tr>
  <tr><td>TCP</td><td>6868</td><td>0.0.0.0/0</td><td>BOSH Agent</td></tr>
  <tr><td>TCP</td><td>25250</td><td>0.0.0.0/0</td><td>BOSH Blobstore</td></tr>
  <tr><td>TCP</td><td>25555</td><td>0.0.0.0/0</td><td>BOSH Director</td></tr>
  <tr><td>TCP</td><td>25777</td><td>0.0.0.0/0</td><td>BOSH Registry</td></tr>
</table>

##<a id="bosh-cli"></a>Step 3: Install the BOSH CLI with MicroBOSH and AWS Plugins ##

<p class="note"><strong>Note</strong>: Installing the BOSH CLI requires the latest patched version of Ruby 1.9.3, 2.0.x, or 2.1.x.</p>

You must use the BOSH Command Line Interface (CLI) to interact with MicroBOSH
and BOSH.

Run this command to install the BOSH CLI with the MicroBOSH and AWS plugins:

`gem install bosh_cli bosh_cli_plugin_micro bosh_cli_plugin_aws`

##<a id="domain"></a>Step 4: (Optional) Prepare a Domain for Cloud Foundry Deployment ##

<p class="note"><strong>Note</strong>: Perform this step only if you want to deploy Cloud Foundry with BOSH.</p>

To prepare a domain:

1. Choose a domain name for your deployment.

    For example, if you choose **cloud.example.com**, services that you later
	deploy using BOSH become available as **service-name.cloud.example.com**.

1. Use the [Route 53 control panel](https://console.aws.amazon.com/route53) to
create an AWS Route 53 Hosted Zone for your domain.
Delegate DNS authority for your domain to the addresses in the **delegation set** field that appears in the control panel.

	For example, if your domain is **cloud.example.com**, create an NS record in
	the DNS server for `example.com` for each address in the delegation set.

##<a id="environment"></a>Step 5: Set Environment Variables ##

To set the environment variables required for deploying to AWS:

1. Create a text file named `bosh_environment`.

1. Add the following information, replacing the value for each line to match
your configuration.

	The values shown correspond to the earlier Route 53 **cloud.example.com**
	example.

    <p class="note"><strong>Note</strong>: <code>BOSH_VPC_DOMAIN</code> and
	<code>BOSH_VPC_SUBDOMAIN</code> must correspond to the domain name you set
	up when you configured Route 53. The only supported value for
	<code>BOSH_AWS_REGION</code> is <code>us-east-1</code>.</p>

    ```
	export BOSH_VPC_DOMAIN=example.com
	export BOSH_VPC_SUBDOMAIN=mycloud
	export BOSH_AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
	export BOSH_AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
	export BOSH_AWS_REGION=us-east-1
	export BOSH_VPC_SECONDARY_AZ=us-east-1a
	export BOSH_VPC_PRIMARY_AZ=us-east-1d
	```

1. Choose availability zones that are listed as “operating normally” on the [AWS Console Status Health Section](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1) for your
region.

1. In a terminal window, run `source bosh_environment` to set the new
environment variables for the current shell.

##<a id="infrastructure"></a>Step 6: (Optional) Create AWS Infrastructure ##

<p class="note"><strong>Note</strong>: The <code>bosh aws create</code> command was originally created to quickly set up development accounts. We do not recommend using this command for any long-lived environments.</p>

<p class="note"><strong>Note</strong>: Skip this step if you are only deploying MicroBOSH, not BOSH.</p>

1. In a terminal window, run `bosh aws create` to create your AWS infrastructure.

	The `bosh aws create` command generates the receipt files
	`aws_rds_receipt.yml` and `aws_vpc_receipt.yml`, a VPC Internet Gateway, VPC
	subnets, three RDS databases, and a NAT VM.
	Remove the NAT VM if you do not plan to deploy Cloud Foundry.

	<p class="note"><strong>Note</strong>: RDS database creation might take
		longer than twenty minutes to complete.</p>

    <pre class="terminal">
	$ bosh aws create
	Executing migration CreateKeyPairs
	allocating 1 KeyPair(s)
	Executing migration CreateVpc
	. . .
	details in S3 receipt: aws_rds_receipt and file: aws_rds_receipt.yml
	Executing migration CreateS3
	creating bucket xxxx-bosh-blobstore
	creating bucket xxxx-bosh-artifacts
	</pre>

##<a id="private-subnet"></a>Step 7: (Optional) Restrict Public Access with a Private Subnet ##

By default, you deploy the VMs in a BOSH deployment on AWS to a single public subnet.
Public subnet traffic on AWS routes through an Internet gateway.
Private subnet traffic on AWS does not, and any VMs that you deploy to a private
subnet cannot communicate directly with the Internet.
To restrict public access to your VMs, you can deploy them to a private subnet.

To allow a VM in a private subnet to access the Internet, you must do one of the
following:

* Route the private subnet traffic through a network address translation (NAT)
	VM that you deploy to a public subnet
* Route the private subnet traffic through an Elastic Load Balancer (ELB) that
	you deploy to a public subnet

###<a id="deploy-vms"></a>Deploy VMs to a Private Subnet ###

You can deploy any of the VMs listed in the `compilation`, `resource pools`, or
`jobs` block of your deployment manifest to a private subnet instead of a public
subnet.
Follow the steps below to deploy VMs to a private subnet.

1. From the Amazon Virtual Private Cloud (VPC) console, create a private subnet.

1. In the `networks` block of your BOSH deployment manifest, add a sub-block
referencing the private subnet.
The sub-block must contain the following information:
    * `name`: Name used by other entries in the manifest to reference this
subnet
    * `range`: Range of IP addresses in this subnet
    * `cloud_properties`: AWS identifier for this subnet
<br /><br />
1. Find a VM in the `compilation`, `resource pools`, or `jobs` block of your
deployment manifest.
Change the value of the `network` or `networks` key for this VM to the `name`
that you gave to your private subnet.
BOSH deploys a VM to the subnet that the `network` or `networks` key references.

1. Redeploy using your updated deployment manifest.

###<a id="nat"></a>Route through a Network Address Translation (NAT) VM ###

Routing through a NAT VM allows the VMs on a private subnet to initiate outbound
traffic to the Internet, but prevents the VMs from receiving inbound traffic
from the Internet.
Follow the steps below to route outbound traffic from the VMs on a private
subnet through a NAT VM.

1. From the Amazon Virtual Private Cloud (VPC) console, create a VM to use for
NAT on a public subnet in your VPC.
Configure the NAT VM with an Elastic IP address.

1. Create a custom route table and associate it with your private subnet.
Add the following entries to the route table:

<table border="1" class="nice" >
  <tr>
	<th>Destination</th>
	<th>Target</th>
	<th>Purpose</th>
  </tr>
  <tr>
    <td>IP address range of your VPC, specified as a CIDR block.<br />
		Example: <code>10.0.0.0/16</code>
	</td>
	<td><code>local</code></td>
	<td>Enables VMs in the private subnet to communicate with other VMs in
		the VPC
	</td>
  </tr>
  <tr>
    <td><code>0.0.0.0/0</code></td>
	<td>Your NAT VM, specified using AWS-assigned identifiers.<br />
		Example: <code>eni-1a2b3c4d / i-1a2b3c4d</code>
	</td>
	<td>Sends all non-local traffic to the NAT VM</td>
  </tr>
</table>

###<a id="nat"></a>Route through an Elastic Load Balancer (ELB) ###

Routing through an Elastic Load Balancer (ELB) allows the VMs on a private
subnet to receive inbound traffic from the Internet.
All traffic from the Internet for the private subnet routes through the ELB,
allowing you to handle access control and SSL decryption at the ELB level.

<p class="note"><strong>Note</strong>: Only traffic inbound from the Internet routes through an ELB. To allow the VMs on a private subnet to initiate outbound traffic to the Internet, you must <a href="#nat">route the outbound traffic through a NAT VM</a>.</p>

Follow the steps below to route traffic inbound from the Internet through an
Elastic Load Balancer to the VMs in a private subnet.

1. From the Amazon Virtual Private Cloud (VPC) console, create a public subnet
in the same Availability Zone as your private subnet.

1. In the route table for the public subnet you create, add a route to the
Internet Gateway.

1. In the AWS EC2 Dashboard, create an external Elastic Load Balancer on the
public subnet.

1. Set the ELB to service your private subnet.

1. Create a security group for your ELB that allows access from the Internet.

1. Add a rule to the security group used by the VMs in your private subnet that
allows access from the ELB security group.
