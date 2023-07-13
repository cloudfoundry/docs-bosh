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

- [See Alibaba Cloud CPI AZ cloud properties](alicloud-cpi.md#azs)
- [See AWS CPI AZ cloud properties](aws-cpi.md#azs)
- [See Azure CPI AZ cloud properties](azure-cpi.md#azs)
- [See OpenStack CPI AZ cloud properties](openstack-cpi.md#azs)
- [See SoftLayer CPI AZ cloud properties](softlayer-cpi.md#azs)
- [See Google Cloud Platform CPI AZ cloud properties](google-cpi.md#azs)
- [See vSphere CPI AZ cloud properties](vsphere-cpi.md#azs)
- [See vCloud CPI AZ cloud properties](vcloud-cpi.md#azs)

---
## Assigning AZs to deployment instance groups {: #assigning-azs }

Once AZs are defined, deployment instance_groups can be placed into one or more AZs:

```yaml
instance_groups:
- name: web
  instances: 5
  azs: [z1, z2]
  jobs:
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

---
## Listing VMs in AZs {: #listing-vms-in-azs }

While deploy is in progress or after it finishes, `bosh instances` and `bosh vms` commands can be used to view instances and their associated AZs.

```shell
bosh deploy
```

```text
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

---

## Adding and removing AZs to a deployment.

> **_NOTE:_**
>   With some CPIs AZS are referenced in the Subnet configuration of the cloud-config networks block. This means that moving AZs can have networking implications. E.g. networks can be Zonal ( e.g. AWS Subnets are associated to a Zone) or Regional ( e.g. GCP Subnets are associated with a Region). This is important to keep in mind when planning an AZ migration.


> **_GENERAL LIMITATIONS:_** 
> - bosh does not migrate persistent disk contents across AZs. Persistent disks attached to a vm that is moved to another AZ will be orphaned and eventually deleted by bosh.
> - singleton instances will face downtime while being recreated. If they have persistent disks attached the data on the disk will not be migrated.
> - moving a vm with a staticly assigned IP address will fail. Bosh will create the new instance before deleting the old instance. This means that at creation time of the new instance, the static IP is still attached to the old instance.

### Adding new AZs to an existing deployment

#### Scenario: the instance_group does not use persistent disks:
```
instance_groups:
- name: dummy
  azs:
  - az1
  - az3
  instances: 3
…
```
##### bosh vms
```
Instance                                   ... AZ  
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... az3 
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... az1 
dummy/7f30aae8-9f03-4b0b-88a1-2d0ab8a78fba ... az1 
```
##### bosh deploy ...
```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - az2
...
...
Creating missing vms: dummy/e6764262-f032-4238-bfbe-d684934ece26 (3) (00:00:39)
Deleting unneeded instances dummy: dummy/7f30aae8-9f03-4b0b-88a1-2d0ab8a78fba (1) (00:00:34)
...
Updating instance dummy: dummy/e6764262-f032-4238-bfbe-d684934ece26
```

##### Outcome:
```
Instance                                   ... AZ  
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... az3 
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... az1 
dummy/e6764262-f032-4238-bfbe-d684934ece26 ... az2
```

As stated in: [assigning-azs](https://bosh.io/docs/azs/#assigning-azs) bosh follows certain considerations when spreading VMs across AZs.
> * existing instances with persistent disks will not be rebalanced to avoid losing persistent data
> * existing instances will be preserved if possible but will be rebalanced if necessary to even out distribution
> * new instances will be spread as evenly as possible over specified AZs
> * existing instances in a removed AZ will be removed and their persistent disks will be orphaned
> * if static IPs are specified on one or more networks, AZ selection is focused to satisfy IPs' AZ assignment

Since the the above scenario **_does not_** utilize persistent disks, adding `az2` to the list of `azs` will:

1. create a new vm in az2 so `new instances will be spread as evenly as possible over specified AZs`
2. delete a currently serving vm in az1 so `instances will be rebalanced ... to even out distribution`


### Scenario: the instance_group uses persistent disks:

```
instance_groups:
- name: dummy
  azs:
  - az1
  - az3
  instances: 3
  persistent_disk: 1024
…
```
##### bosh vms
```
Instance                                   ... AZ  
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... az3 
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... az1 
dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 ... az1 
```
##### bosh deploy ...
```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - az2
...
Updating instance dummy: dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce (0) (canary)
Updating instance dummy: dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 (1)
Updating instance dummy: dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b (2)
```

##### Outcome:
```
Instance                                   ... AZ  
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... az3 
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... az1 
dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 ... az1 
```

Since the the above scenario does utilize persistent disks, adding az2 to the list of azs will:

1. Skip redeploying a vm from az1 to az2 to avoid recreating the persistent disk and potentially incur dataloss.

Bosh opts to keep the persistent disk to avoid dataloss. Bosh is not aware about the capabilities, in terms of distributed state, of the software it deploys. Some software architectures have internal features (e.g. Nats is utilizing RAFT) that allow syncing state within the cluster nodes. Other architectures rely on features provided by their host or additional software (e.g. distributed filesystems) to achieve a similar outcome.


### Rebalancing VMs with persistent disks

Bosh's logic currently has a limitation in regards to balancing VMs with persistent disks across AZs when deleting unnecessary instances.

Details can be found in this Github issue: 
> https://github.com/cloudfoundry/bosh/issues/2198

In [assigning-azs](https://bosh.io/docs/azs/#assigning-azs) the documentation outlines the considerations when spreading VMs across AZs when deploying. **_This does not fully apply when deleting instances_**.

##### The limitation can be formalized as:

Starting with 3 instances in 2 AZs
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... az1 
```

Adding 1 Instance and 1 AZ will result in

```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... az1 
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... az3
```

Removing 1 Instance will result in:

```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... az1 
```

**Bosh will remove the latest instance to be added instead of one instance currently deployed into `az1`**

To work around this there are several approaches that will be discussed below.

#### Automatic but resulting in a temporarily reduced instance count:

If your application supports syncing state between existing cluster nodes and it can tolerate the temporary loss of stateful instances (for the time of the migration), the easiest approach is to:

##### Scale In & Add AZ  => Scale Out

##### Initial State:
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... az1 
```

##### bosh deploy
```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - az3
-   instances: 3
+   instances: 2
```
##### Result:
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
```

##### Scale Out:
```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
-   instances: 2
+   instances: 3
...
Creating missing vms: dummy/8a57bad5-405d-47d9-abb0-65060167821c (2) (00:00:41)
...
```

##### Result:
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2
dummy/8a57bad5-405d-47d9-abb0-65060167821c ... az3

```


#### Manual but never going below the current number of available instances:

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 ... az1 
```

##### bosh deploy: Add AZ, Scale out
```
  instance_groups:
  - name: dummy
    azs:
+   - az3
-   instances: 3
+   instances: 4
...
Creating missing vms: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 (2)
...
Updating instance dummy: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5
...
```

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 ... az1 
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... az3
```

> At this point we need to tell bosh which instances we want to get rid off. Since we have two instances in az1, we choose to delete `dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104`

**bosh stop dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 --hard**

> When using the `--hard` flag bosh will additionally delete the vm after it stopped the jobs. The bosh task logs will not show `Deleting unneeded instances dummy...` because `--hard` will delete the actual vm but not the instance from the deployment state.

```
Task 70345 | 13:09:03 | Updating instance dummy: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:03 | L executing pre-stop: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:03 | L executing drain: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:04 | L stopping jobs: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:05 | L executing post-stop: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3) (00:00:54)
```

> This procedure will leave an orphaned disk:

```
bosh disks --orphaned | grep 'dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104'
disk-147a80e4-72b0-4d77-7325-af28ae469d36       1.0 GiB dummy   dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104      az1     Fri Nov 18 13:12:12 UTC 2022
```

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... az3 
```

##### bosh deploy

> Since we already manually deleted an instance in az1, bosh does not delete the instance that was added last. It realizes it has the required amount of actual vms in the deployment and just deletes the reference to the instance that was stopped.

```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
-   instances: 4
+   instances: 3
...
Deleting unneeded instances dummy: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3) (00:00:00)
...
```

### Removing an AZ from an existing deployment

When decomissioning an AZ by removing it from the manifest,
Bosh will delete all existing VMs in the removed AZ. If the VM had a persistent disk, that disk will be orphaned. New VMs will be rebalanced to still existing AZs.

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... az3 
```

##### bosh deploy
```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
-   - az3
...
Creating missing vms: dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 (3) (00:00:41)
Deleting unneeded instances dummy: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 (2) (00:00:34)
...

```

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 ... az1
```

```
bosh disks --orphaned | grep dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5
disk-ce15e36a-1eeb-45da-494a-7282a56f3b32       1.0 GiB dummy   dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5      az3     Fri Nov 18 13:55:17 UTC 2022
```

### Replacing an AZ in an existing deployment

When replacing an AZ with another, Bosh will delete all existing VMs in the removed AZ. If the deleted VM had a persistent disk, that disk will be orphaned. Replacement VMs will be balanced into all AZs.

##### bosh vms
```
Instance                                   ... AZ  
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... az1 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 ... az1
```

##### bosh deploy
```
  instance_groups:
  - name: dummy
    azs:
+   - az3
-   - az1
...
Creating missing vms: dummy/4a1840a7-b239-4635-9d8e-1830567cd040 (2) (00:00:35)
Creating missing vms: dummy/cbb84b42-e6a6-4b4d-b560-e418177d2d6f (4) (00:00:38)
Deleting unneeded instances dummy: dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 (0) (00:00:34)
Deleting unneeded instances dummy: dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 (3) (00:00:34)
...
Updating instance dummy: dummy/cbb84b42-e6a6-4b4d-b560-e418177d2d6f
Updating instance dummy: dummy/4a1840a7-b239-4635-9d8e-1830567cd040
...

```

> NOTE: as visible in the logs above, removing an AZ will delete ALL VMs in that AZ at the same time.  This can potentially circumvent the `update` block from your manifest:
```
update:
  canaries: 1
  canary_watch_time: 5000 - 90000
  max_in_flight: 1
  update_watch_time: 5000 - 15000
```

##### bosh vms
```
Instance                                   ... AZ  
dummy/4a1840a7-b239-4635-9d8e-1830567cd040 ... az3 
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... az2 
dummy/cbb84b42-e6a6-4b4d-b560-e418177d2d6f ... az2 
```
