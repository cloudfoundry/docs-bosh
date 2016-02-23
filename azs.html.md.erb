---
title: First class AZs (Availability Zones)
---

<p class="note">Note: This feature is available with bosh-release v241+. Once you opt into using cloud config all deployments must be converted to use new format. There is no way to opt out of the cloud config once you opt in.</p>

Previously to spread resources over multiple AZs, deployment jobs, resource pools, and networks had to be duplicated and named differently in the deployment manifest. By convention all of these resources were suffixed with "_z1" or "zX" to indicate which AZ they belonged to.

With first class AZs support in the Director it's no longer necessary to duplicate and rename resources. This allows the Director to eliminate and/or simplify manual configuration for balancing VMs across AZs and IP address management.

---
## <a id='config'></a> Defining AZs

To use first class AZs, you have to opt into using [cloud config](cloud-config.html).

Here is how AZ configuration looks like for two AZs on AWS.

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: us-east-1b
- name: z2
  cloud_properties:
    availability_zone: us-east-1c
...
```

<p class="note">Note that IaaS specific cloud properties related to AZs should now be <em>only</em> placed under <code>azs</code>. Make sure to remove them from <code>resource_pools/vm_types</code>' cloud properties.</p>

AZs schema:

* **azs** [Array, required]: List of AZs.

* **name** [String, required]: Name of an AZ within the Director.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to associated with AZ; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#azs-cloud-properties) below. Example: `availability_zone`. Default is `{}` (empty Hash).

### <a id='azs-cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI AZ cloud properties](aws-cpi.html#azs)
- [See OpenStack CPI AZ cloud properties](openstack-cpi.html#azs)
- [See vSphere CPI AZ cloud properties](vsphere-cpi.html#azs)
- [See vCloud CPI AZ cloud properties](vcloud-cpi.html#azs)

---
## <a id='config'></a> Assigning AZs to deployment jobs

Once AZs are defined, deployment jobs can be placed into one or more AZs:

```yaml
jobs:
- name: web
  instances: 5
  azs: [z1, z2]
  templates:
  - name: web
  networks:
  - name: private
```

Given above configuration, 5 instances will be spread over "z1" and "z2" AZs, most likely creating 3 instances in "z1" and 2 instances in "z2". There are several consideration the Director takes into account while determining how instances should be spread:

- new instances will be spread as evenly as possible over specified AZs
- existing instances will be preserved if possible but will be rebalanced if necessary to even out distribution
- existing instances with persistent disks will not be rebalanced to avoid losing persistent data
- existing instances in a removed AZ will be removed and their [persistent disks will be orphaned](persistent-disks.html)
- if static IPs are specified on one or more networks, AZ selection is focused to satisfy IPs' AZ assignment

<p class="note">We are planning to eventually introduce <code>bosh rebalance</code> command to forcefully rebalance instances with persistent disks.</a>

---
## <a id='config'></a> Listing VMs in AZs

While deploy is in progress or after it finishes, `bosh instances` and `bosh vms` commands can be used to view instances and their associated AZs.

<pre class="terminal">
$ bosh deploy
Acting as user 'admin' on 'micro'

Deployment `underlay'

Director task 1442

Task 1442 done

+-----------------------------------------------+---------+----+---------+--------------+
| VM                                            | State   | AZ | VM Type | IPs          |
+-----------------------------------------------+---------+----+---------+--------------+
| etcd/6d529c12-bfbf-43ae-a232-07dd6e66aed2     | running | z1 | medium  | 10.10.0.64   |
| underlay/db9f8ff1-1ed8-4048-84c6-5bf664b94790 | running | z1 | medium  | 10.10.0.62   |
| underlay/b9d4175d-a621-4342-a31e-7ce943e84b26 | running | z1 | medium  | 10.10.0.63   |
| underlay/10b26859-e9a9-4581-b372-37dbb4f3666d | running | z2 | medium  | 10.10.64.121 |
+-----------------------------------------------+---------+----+---------+--------------+

VMs total: 4
</pre>
