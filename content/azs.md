!!! note
    This feature is available with bosh-release v241+. Once you opt into using cloud config all deployments must be converted to use new format. There is no way to opt out of the cloud config once you opt in.

Previously to spread resources over multiple AZs, deployment jobs, resource pools, and networks had to be duplicated and named differently in the deployment manifest. By convention all of these resources were suffixed with `_z1` or `zX` to indicate which AZ they belonged to.

With first class AZs support in the Director it's no longer necessary to duplicate and rename resources. This allows the Director to eliminate and/or simplify manual configuration for balancing VMs across AZs and IP address management.

---
## Defining AZs {: #config }

To use first class AZs, you have to opt into using [cloud config](cloud-config.md).

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

!!! note
    Note that IaaS specific cloud properties related to AZs should now be *only* placed under `azs`. Make sure to remove them from `resource_pools`/`vm_types` cloud properties.

AZs schema:

* **azs** [Array, required]: List of AZs.

* **name** [String, required]: Name of an AZ within the Director.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to associated with AZ; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#azs-cloud-properties) below. Example: `availability_zone`. Default is `{}` (empty Hash).

### CPI Specific `cloud_properties` {: #azs-cloud-properties }

- [See AWS CPI AZ cloud properties](aws-cpi.md#azs)
- [See Azure CPI AZ cloud properties](azure-cpi.md#azs)
- [See OpenStack CPI AZ cloud properties](openstack-cpi.md#azs)
- [See SoftLayer CPI AZ cloud properties](softlayer-cpi.md#azs)
- [See Google Cloud Platform CPI AZ cloud properties](google-cpi.md#azs)
- [See vSphere CPI AZ cloud properties](vsphere-cpi.md#azs)
- [See vCloud CPI AZ cloud properties](vcloud-cpi.md#azs)

---
## Assigning AZs to deployment instance groups {: #assigning-azs }

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
- existing instances in a removed AZ will be removed and their [persistent disks will be orphaned](persistent-disks.md)
- if static IPs are specified on one or more networks, AZ selection is focused to satisfy IPs' AZ assignment

!!! note
    We are planning to eventually introduce `bosh rebalance` command to forcefully rebalance instances with persistent disks.

---
## Listing VMs in AZs {: #listing-vms-in-azs }

While deploy is in progress or after it finishes, `bosh instances` and `bosh vms` commands can be used to view instances and their associated AZs.

```shell
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
```
