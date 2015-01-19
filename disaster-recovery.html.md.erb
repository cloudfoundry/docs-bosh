---
title: Disaster Recovery with BOSH
---

Disaster recovery procedures require that you rebuild the architecture of a
system and restore its data.
BOSH automates and simplifies the task of rebuilding the architecture in the
following ways:

* BOSH automatically rebuilds unresponsive VMs when possible
* BOSH provides interactive tools to assist you with manual recovery
* BOSH recreates your architecture in a consistent and repeatable manner, if
necessary

BOSH does not back up data.
Your IaaS provider or third-party backup vendor handles data storage and backup.

<p class="note"><strong>Note</strong>: To minimize risks associated with colocation, install your <a href="./terminology.html#deployment">deployment</a>, <a href="./index.html">BOSH</a>, <a href="./terminology.html#microbosh">MicroBOSH</a>, and the BOSH <a href="./deployment-manifest.html">deployment manifest</a> in physically separate systems.</p>

## <a id="monitoring"></a>Monitoring Issues ##

In the event of an issue with your deployment, the BOSH [Health Monitor](./bosh-components.html#health-monitor) can send alerts and
notifications to email and third-party services.
The Health Monitor stops sending alerts and notifications after all issues are
resolved.

To enable alerts and notifications, configure your manifest as follows:

1. Locate the `hm` section of the Properties block of your deployment manifest.

1. Identify or add a notification recipient key and all required subkeys. The table lists supported recipients:

    <table border="1" class="nice" >
  <tr>
    <th>Recipient</th>
    <th>Key</th>
    <th>Subkey</th>
  </tr>
  <tr>
    <td>Email</td>
	<td><code>email_notifications:</code></td>
	<td><code>smtp:</code>
		<br />
  	  	<code>from:</code>
		<br />
  	  	<code>host:</code>
		<br />
  	  	<code>port:</code>
		<br />
  	  	<code>domain:</code>
		<br />
	</td>
  </tr>
  <tr>
    <td>DataDog.com</td>
	<td><code>datadog_enabled:</code></td>
	<td><code>api_key:</code>
		<br />
		<code>application_key:</code>
	</td>
  </tr>
  <tr>
    <td>PagerDuty.com </td>
	<td><code>pagerduty_enabled:</code></td>
	<td><code>service_key:</code></td>
  </tr>
  <tr>
    <td>Amazon CloudWatch </td>
	<td><code>cloud_watch_enabled:</code></td>
	<td><code>access_key_id:</code>
		<br />
		<code>secret_access_key:</code></td>
  </tr>
</table>

1. Set the value of the recipient key to `true` and add appropriate values for each subkey.
1. Redeploy.

This manifest excerpt example shows how to enable Amazon CloudWatch
notifications:

~~~yaml
hm:
  http:
    user: hm
    password: hm
  director_account:
    user: admin
    password: secretpassword
  cloud_watch_enabled:
    access_key_id: xxxTHISISNOTAREALACCESSKEYxxx
    secret_access_key: xxxTHISISANOTAREALSECRETKEYxxx
~~~

## <a id="resolving"></a>Resolving Issues ##

The following sections discuss when BOSH can automatically recover and what
steps to take if automatic measures fail.

## <a id="automatic"></a>Automatic Recovery ##

BOSH uses the BOSH [Resurrector](./resurrector.html) to help it recover
from many issues.
The Resurrector automatically instructs the BOSH
[Director](./terminology.html#director) to rebuild unresponsive VMs unless the
system is in meltdown.

Meltdown occurs when the number of unresponsive VM alerts within a specified
time period exceeds a specified threshold.
This threshold is a percentage of the total number of VMs in the deployment.
You specify the `time_threshold` and `percent_threshold` properties in your
manifest.

For example, in a deployment with 40 VMs, `percent_threshold` set to 20%, and `time_threshold` set to 60 seconds, automatic recovery fails if the Resurrector
receives eight or more unresponsive VM alerts within 60 seconds.

## <a id="manual"></a>Manual Recovery ##

An automatic recovery failure usually indicates an issue with your
infrastructure.
If your infrastructure is functioning correctly, you might be able to resolve
the issue using the `bosh cloudcheck` troubleshooting command. If using this
command does not resolve the issues, you might need to edit the manifest or
recreate the architecture of your system.

### <a id="running"></a>Running BOSH Cloudcheck ###

`bosh cloudcheck` scans for differences between the VM state database that the
Director maintains and the actual state of the VMs.
For each difference detected, `bosh cloudcheck` offers the following possible
repair options:

* `Reboot VM`: Instructs BOSH to reboot a VM, which can resolve many transient
errors.
* `Ignore problem`: Instructs BOSH to do nothing. Select this option if you
plan to troubleshoot directly on a VM.
* `Reassociate VM with corresponding instance`: Updates the Director state
database.
Select this option if you believe that the Director state database is in error
and that a VM is correctly associated with a job.
* `Recreate VM using last known apply spec`: Instructs BOSH to destroy the VM
and recreate it. Select this option if you determine a VM is corrupted.
* `Delete VM reference`: Instructs BOSH to delete a VM reference in the
Director state database.
If a VM reference exists in the state database, BOSH expects to find an agent
running on the VM.
Select this option only if you know this reference is in error.
Once you delete the VM reference, BOSH can no longer control the VM.

### <a id="editing"></a>Editing the Manifest ###

Review the log files, alerts, and notifications for more information about issues that persist after you run`bosh cloudcheck`.
For example, an alert might show that a VM does not have enough memory. In this
case, edit the manifest to allocate more memory and redeploy.

### <a id="recreating"></a>Recreating Your Architecture ###

In some situations, you might need to recreate some part of the system
architecture depending on which part has failed:

* If you receive error notifications from your deployment but not from BOSH,
redeploy your deployment using BOSH.
* If you receive error notifications from BOSH, redeploy BOSH using MicroBOSH.
* If you receive error notifications from MicroBOSH, redeploy MicroBOSH using
your manifest.