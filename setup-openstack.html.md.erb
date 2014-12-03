---
title: Setting Up OpenStack for BOSH
---

This topic explains how to prepare OpenStack for deploying BOSH or MicroBOSH.

##<a id="hardware"></a>Step 1: Allocate Hardware Resources ##

Your intended use of BOSH determines what hardware resources you should allocate
in your IaaS.

For example:

* BOSH needs room to store the releases it deploys.
Larger applications or larger numbers of applications require more disk space.
* Larger numbers of active users require more RAM.

OpenStack describes hardware in terms of
[flavors](http://docs.openstack.org/trunk/openstack-ops/content/flavors.html).
Choose a flavor with at least three gigabytes of RAM.

##<a id="traffic"></a>Step 2: Restrict Network Traffic ##

Create and configure two security groups to restrict incoming network traffic to
the BOSH VMs.

<p class="note"><strong>Note</strong>: In <a href="https://www.openstack.org/software/grizzly/">OpenStack Grizzly</a>, there are settings for both <code>INGRESS</code> and <code>EGRESS</code> control.
Set all rules in the following instructions for <code>INGRESS</code> only.

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

##<a id="validate"></a>Step 3: Validate your OpenStack Instance ##

Follow the instructions to [validate your OpenStack instance](../deploying/openstack/validate_openstack.html).