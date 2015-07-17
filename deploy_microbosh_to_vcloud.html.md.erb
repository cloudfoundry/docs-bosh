---
title: Deploying MicroBOSH on vCloud
---

BOSH is a system used to deploy and manage a Cloud Foundry installation. Like Cloud Foundry, BOSH itself is a distributed system. MicroBOSH is a single VM that contains all BOSH components. For most installation purposes, MicroBOSH can be used to install Cloud Foundry.
If you are deploying a large, production instance of Cloud Foundry you may prefer to use a multi-VM deployment of BOSH for scale or resiliency purposes. To deploy this, you deploy MicroBOSH and then use MicroBOSH to deploy BOSH.

## <a id="bosh"></a>BOSH Configuration ##

BOSH deploys software from a subdirectory under a deployments directory.
Here we create both and name them appropriately. (In our example we named the subdirectory micro01).

	mkdir deployments
	cd deployments
	mkdir micro01

BOSH needs a deployment manifest for MicroBOSH.
It must be named `micro_bosh.yml`.

You will need to edit this file putting in various parameters like IP addresses, storage profile and network names, login credentials, the API URL and more. The example manifest above provides comments and examples to help this process.

## <a id="download"></a>Download a BOSH Stemcell for vCloud deployment ###

1. Open [https://bosh.io/stemcells](https://bosh.io/stemcells) in a web browser
to view a list of publicly available BOSH stemcells.
The list displays the most recent build numbers of BOSH stemcells, organized by operating system, target IaaS, and hypervisor.

1. Choose a BOSH stemcell for vCloud and click the build number to download.

## <a id="deploy-stemcell"></a> Deploy a Stemcell ###

Change to the deployments directory and set the deployment. This assumes you named the directory micro01.

	cd deployments
	bosh micro deployment micro01

This should give you output as follows:

<pre class="terminal">
$ cd deployments
$ bosh micro deployment micro01
Deployment set to '/var/vcap/deployments/micro01/micro_bosh.yml'
</pre>

Next, deploy a stemcell for MicroBOSH.

	bosh micro deploy bosh-stemcell-XXXX-vcloud-esxi-ubuntu.tgz


## <a id="verify"></a>Checking Status of a MicroBOSH Deploy ##

To check the status of the MicroBOSH, first **target** the MicroBOSH (specifically, the Director process)

	bosh target <ip_address_from_your_micro_bosh_manifest:25555>


Next **login** with user `admin` and password `admin` as follows:

	bosh login admin

Here's how it looks:
<pre class="terminal">
$ bosh login admin
Enter password: *****
Logged in as `admin'
</pre>

If you want to change the user id and password, use the `create user` command:

	bosh create user

Here's an example:

<pre class="terminal">
$ bosh create user
Enter new username: killian
Enter new password: ********
Verify new password: ********
User `killian' has been created
</pre>

After creating this user the original `admin` user is deleted and you can no longer login with admin / admin

The `status` command will show the persisted state for a given MicroBOSH
instance.

	bosh micro status

Here's an example:
<pre class="terminal">
$ bosh micro status
Stemcell CID   sc-1744775e-869d-4f72-ace0-6303385ef25a
Stemcell name  bosh-stemcell-1341-vsphere-esxi-ubuntu
VM CID         vm-ef943451-b46d-437f-b5a5-debbe6a305b3
Disk CID       disk-5aefc4b4-1a22-4fb5-bd33-1c3cdb5da16f
Micro BOSH CID bm-fa74d53a-1032-4c40-a262-9c8a437ee6e6
Deployment     /home/user/cloudfoundry/bosh/deployments/micro\_bosh/micro\_bosh.yml
Target         https://10.146.21.150:25555 #IP Address of the Director
</pre>

## <a id="listing"></a>Listing Deployments ##

The `deployments` command prints a table view of `bosh-deployments.yml`:

	bosh micro deployments

The files in your current directory need to be saved if you later want to be able to update your MicroBOSH instance. They are all text files, so you can commit them to a git repository to make sure they are safe in case your bootstrap VM goes away.

## <a id="send-message"></a>Sending Messages to the MicroBOSH Agent ##

The `bosh` CLI can send messages over HTTP to the agent using the `agent`
command.

	bosh micro agent ping

For example:

<pre class="terminal">
$ bosh micro agent ping
"pong"
</pre>

## <a id="ssh"></a>SSH to the MicroBOSH ##

If you want to SSH to the MicroBOSH you can do so using the default login credentials `vcap`, `c1oudc0w`

You can change the default userid & password by specifying it in the deployment manifest, as follows (we installed the `whois` package on the jump box earlier in order to get these tools):

<pre class="terminal">
env:
  bosh:
    password: < hashed password - Generate SHA hash using mkpasswd -m sha-512 >
</pre>



