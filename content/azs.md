First-class availability zones help expressing how VM instances, gathered into
instance groups, will span over one or many availability zones.

This feature was introduced with Bosh v241+ (released on
[2015-12-23](https://github.com/cloudfoundry/bosh/releases/tag/stable-3163))
and has been a major improvement heping Bosh deployment manifest to be more
expressive and less verbose.

Here we detail simple operations first, and then explain how the Bosh Director
behaves with more complex operations like adding or removing availability
zones to a deployment.

---

## Defining availability zones {: #config }

To use first-class availability zones (AZs), you have to opt into using
[Cloud Config](cloud-config.md).

Here is how AZ configuration looks like for two AZs on AWS.

```yaml
azs:
  - name: z1
    cloud_properties:
      availability_zone: us-east-1b
  - name: z2
    cloud_properties:
      availability_zone: us-east-1c
# ...
```

!!! Note
    IaaS-specific cloud properties related to AZs should now be *only* placed
    under `azs`. Make sure to remove them from `resource_pools`/`vm_types`
    cloud properties.

AZs schema:

* **azs** [Array, required]: List of availability zones.

* **name** [String, required]: Name of an AZ within the Director.

* **cloud_properties** [Hash, optional]: Describes any IaaS-specific
  properties needed to associated with AZ; for most IaaSes, some data here is
  actually required.
  See [CPI Specific `cloud_properties`](#azs-cloud-properties) below.
  Example: `availability_zone`.
  Default is `{}` (empty Hash).

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

Once availability zones are defined in the Cloud Config, each instance group
can be be placed into one or more AZs:

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

Given above configuration, 5 instances will be spread over `z1` and `z2`
availability zones, most likely creating 3 instances in `z1` and 2 instances
in `z2`.

The director considers several aspects when determining how instances should
be spread accoss availability zones:

- New instances will be spread as evenly as possible over the specified
  availability zones.
- Existing instances will be preserved if possible, but will be rebalanced if
  necessary to even out the distribution.
- Existing instances with persistent disks will not be rebalanced to avoid
  losing persistent data.
- Existing instances in a removed availability zone will be removed, and their
  [persistent disks](persistent-disks.md) will be orphaned.
- If static IP addresses are specified on one or more networks, then instances
  placement on availability zones will satisfy the IP addresses assignment on
  its availability zone.

---

## Listing instances (VMs) in availability zones {: #listing-vms-in-azs }

While deploy is in progress or after it finishes, `bosh instances` and
`bosh vms` commands can be used to view instances and their associated AZs.

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

## Adding and removing AZs to a deployment

!!! Note
    With some CPIs, availability zones (AZs) are tied to subnets, as specified
    by the `networks` section of the Cloud Config. This means that moving AZs
    can have networking implications. E.g. networks can be Zonal, like AWS
    Subnets that are associated to a Zone, or Regional like GCP Subnets that
    are associated with a Region. This is important to keep in mind when
    planning an AZ migration.


!!! General limitations
    - Bosh does not migrate persistent disk contents across availability
      zones. Persistent disks attached to an instance (VM) that is moved to
      another AZ will be orphaned and eventually deleted by Bosh.
    - Singleton instances will face downtime while being recreated. If they
      have persistent disks attached the data on the disk will not be
      migrated.
    - Moving an instance (VM) with a statically assigned IP address will fail.
      Bosh will create the new instance before deleting the old instance. This
      means that at the creation time of the new instance, the static IP will
      still be attached to the old instance.

### Adding new AZs to an existing deployment

#### Scenario #1: the instance group does not use any persistent disk

Given such a `dummy` instance group defined in a Bosh deployment manifest:

```
instance_groups:
  - name: dummy
    azs:
      - z1
      - z3
    instances: 3
```

And Bosh instances (VMs) spread over the above availability zone like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... z3
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... z1
dummy/7f30aae8-9f03-4b0b-88a1-2d0ab8a78fba ... z1
```

Then after adding the new `z2` availability zone to the instance group, the
`bosh deploy` operation will behave as follows:

```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - z2
...
...
Creating missing vms: dummy/e6764262-f032-4238-bfbe-d684934ece26 (3) (00:00:39)
Deleting unneeded instances dummy: dummy/7f30aae8-9f03-4b0b-88a1-2d0ab8a78fba (1) (00:00:34)
...
Updating instance dummy: dummy/e6764262-f032-4238-bfbe-d684934ece26
```

And after this operation is done, the resulting instances (VMs) will be placed
like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... z3
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... z1
dummy/e6764262-f032-4238-bfbe-d684934ece26 ... z2
```

As stated in the “[Assigning AZs](#assigning-azs)” section, Bosh follows
certain considerations when spreading instances (VMs) across AZs:

- Existing instances with persistent disks will not be rebalanced to avoid
  losing persistent data.
- Existing instances will be preserved if possible but will be rebalanced if
  necessary to even out distribution.
- New instances will be spread as evenly as possible over specified
  availability zones.
- Existing instances in a removed availability zone will be removed, and their
  persistent disks will be orphaned.
- If static IP addresses are specified on one or more networks, then instances
  placement on availability zones will satisfy the IP addresses assignment on
  its availability zone.

Since the the above scenario **_does not_** utilize persistent disks, adding
`z2` to the `azs` list of availability zones will:

1. Create a new instance (VM) in `z2` so that “_new instances will be spread
   as evenly as possible over specified AZs_”.
2. Delete a currently serving instance (VM) in `z1` so that “_instances will
   be rebalanced ... to even out distribution_”


#### Scenario #2: the instance group uses persistent disks

Given such a `dummy` instance group defined in a Bosh deployment manifest:

```
instance_groups:
  - name: dummy
    azs:
      - z1
      - z3
    instances: 3
    persistent_disk: 1024
# ...
```

And Bosh instances (VMs) spread over the above availability zones like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... z3
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... z1
dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 ... z1
```

Then after adding the new `z2` availability zone to the instance group, the
`bosh deploy` operation will behave as follows:

```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - z2
...
Updating instance dummy: dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce (0) (canary)
Updating instance dummy: dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 (1)
Updating instance dummy: dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b (2)
```

And after this is done, the resulting instances (VMs) will be placed like
this:

```
$ bosh instances
Instance                                   ... AZ
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... z3
dummy/63d450fc-a071-4e19-b0ba-c8fdb147dcce ... z1
dummy/528993ea-5e8b-4d7f-8844-98234bcb0575 ... z1
```

Since the the above scenario makes use of persistent disks, adding `z2` to the
list of availability zones will skip redeploying an instance (VM) from `z1` to
`z2`, in order to avoid recreating the persistent disk that could produce
prejudiciable data loss, depending on the deployed technology.

!!! Note
    Bosh is not aware about the capabilities, in terms of distributed state,
    of the software it deploys though. For some distributed software, losing a
    persistent disk will produce data loss, but for others not. Indeed some
    software architectures have internal features (like Nats that uses RAFT,
    or Galera using replication) that allow syncing state within the cluster
    nodes, and re-create the missing data, while other architectures rely on
    features provided by their host or additional software (e.g. distributed
    filesystems) to achieve a similar outcome. As Bosh is not aware of the
    deployed software architecture, it tries to avoid dataloss without
    preventing it, and still can recreate nodes with new disks when the
    deployment manifest instructs such changes.


### Rebalancing instances with persistent disks

Bosh's logic currently has a limitation in regards to balancing instances
(VMs) with persistent disks across availability zones, when deleting
unnecessary instances. Indeed the selection of the instance to delete is based
on the instance with greater index, whereas one could expect Bosh to select
the instance to delete in order to ensure an even distribution of instance
across availability zones.

Details can be found in this Github issue:
”[Unbalanced instance placement results](https://github.com/cloudfoundry/bosh/issues/2198)”.

In the “[Assigning AZs](#assigning-azs)” section, the documentation outlines
the considerations when spreading instances (VMs) across availability zones
when deploying. **_This does not fully apply when deleting instances_**.

#### Example

Starting with three instances spread over two availability zones as follows:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... z1
```

Adding one instance and one availability zone, will result in such placement
after `bosh deploy` has successfully finished:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... z1
dummy/3697cb63-5329-4b61-8251-6acd73fe5d8b ... z3
```

Removing one instance will result in such placement:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... z1
```

#### Problem statement and solutions

Bosh will remove the instance with greater index, which is the latest that has
been added, instead of removing one of the instances placed in `z1`.

To work around this, we discuss the two following approaches in the upcoming
sections:

1. Automatic approach, resulting in a temporarily reduced instance count
2. Manual approach, but never going below the current number of available instances


#### Approach #1: automatic, but resulting in a temporarily reduced instance count

If your distributed software supports syncing state between existing cluster
nodes and can tolerate temporary loss of some stateful instances (for the time
of the migration), the easiest approach is to scale-in (removing an instance),
add an availability zone, then scale out again.

##### Step #1: scale-in and add an AZ

Given a `dummy` instance group resulting in Bosh instances (VMs) spread over
two availability zones like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/b5b14411-f9ee-4ff8-95c6-b9c24b29b703 ... z1
```

Reducing the instance count by one will result in such diff when converging
the deployment with `bosh deploy`:

```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
+   - z3
-   instances: 3
+   instances: 2
```

And after the first `bosh deploy` operation has finished, the `dummy` instance
group will have the exceeding instance placed in `z1` removed, as shown below.

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
```

##### Step #2: scale-out

Increasing again the instance count by `1` will result in such output when
running `bosh deploy`:

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

And after the second `bosh deploy` operation has finished, the `dummy`
instance group will look have the removed instance back, and it will be
properly placed in `z3`, bringing back the expected balance in instance
placement.

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/8a57bad5-405d-47d9-abb0-65060167821c ... z3

```

#### Approach #2: manual, but never going below the current number of available instances

If your disctributed software cannot tolerate one missing node, even
temporarily, then you may opt for an alternative approach, involving one more
manual step, but never reducing the overall instance count compared to the
initial state.

##### Step #1: add an AZ and scale out

Given a `dummy` instance group resulting in Bosh instances (VMs) spread over
two availability zones like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 ... z1
```

Introducing a new `z3` availability zone and increasing the instance count by
one at the same time will result in the following `bosh deploy` task log:

```
  instance_groups:
  - name: dummy
    azs:
+   - z3
-   instances: 3
+   instances: 4
...
Creating missing vms: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 (2)
...
Updating instance dummy: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5
...
```

The resulting instances will be placed as shown below.

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 ... z1
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... z3
```

##### Step #2: manually delete a VM, and immediately scale in

At this point, we tell Bosh which instances we want to get rid off. Since we
have one exceeding instance placed in `z1`, we choose to delete this one, i.e.
`dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104`:

```shell
bosh stop dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 --hard
```

With the `--hard` flag above, Bosh will not only stop the jobs and all
possible daemon processes, but also delete the virtual machine (VM) from the
infrastructure. The task log for `bosh stop` will not state
`Deleting unneeded instances dummy...`, because `bosh stop --hard` doesn't
remove the instance from the deployment state. It only deletes the related VM
on the infrastruture and marks the instance in its internal representation
with a sticky “stopped” state.

```
Task 70345 | 13:09:03 | Updating instance dummy: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:03 | L executing pre-stop: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:03 | L executing drain: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:04 | L stopping jobs: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3)
Task 70345 | 13:09:05 | L executing post-stop: dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104 (3) (00:00:54)
```

The scale-in operation will produce an orphaned disk from the deleted stateful
instance, which can be listed as follows.

```
$ bosh disks --orphaned | grep 'dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104'
disk-147a80e4-72b0-4d77-7325-af28ae469d36       1.0 GiB dummy   dummy/7e433b3e-2db8-46bf-883a-1c5300dfe104      z1     Fri Nov 18 13:12:12 UTC 2022
```

And after the `bosh stop` operation has finished, the `dummy` instance group
will have the exceeding instance placed in `z1` removed, as shown below.

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... z3
```

##### Step #3: scale in

When scaling-in, Bosh does not delete the instance that was added last, since
we've already manually deleted an instance in `z1`. Instead, Bosh realizes it
has the expected amount of actual virtual machines (VMs) on the
infrastructure, matching the required instances in the deployment. As a
consequence, Bosh only deletes the reference to the instance that was just
stopped.

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

When decomissioning an availability zone (AZ) by removing it from the
deployment manifest, Bosh will delete all existing instances (VMs) in the
removed AZ. If these instances have persistent disks, these will be orphaned.
Any new instance created afterwards will be balanced to the remaining AZs.

#### Example

Considering a `dummy` instace group with 3 instances placed in 3 availability
zones as follows:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 ... z3
```

When removing one of the AZs and keeping the same instance count, the
`bosh deploy` operation will show the following output:

```
Using deployment 'dummy'

  instance_groups:
  - name: dummy
    azs:
-   - z3
...
Creating missing vms: dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 (3) (00:00:41)
Deleting unneeded instances dummy: dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5 (2) (00:00:34)
...

```

After the above operation is done, the instances will be placed as follows.

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 ... z1
```

And while the new instance in `z1` will get an empty new persistent disk, such
an orphaned disk will result from the former instance in `z3` being deleted:

```
bosh disks --orphaned | grep dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5
disk-ce15e36a-1eeb-45da-494a-7282a56f3b32       1.0 GiB dummy   dummy/93fd5c41-88e2-4b2f-97ae-b064d507f3d5      z3     Fri Nov 18 13:55:17 UTC 2022
```


### Replacing an AZ in an existing deployment

When replacing an AZ with another, Bosh will delete all existing instances
(VMs) in the removed AZ. If the deleted instances have persistent disks, these
will be orphaned. Replacement instances will be balanced into all AZs.

!!! Warning
    Removing an availability zone (AZ) will delete all related instances (VMs)
    _at the same time_. Even if you may have specified `canaries: 1` and
    `max_in_flight: 1` in some applicable `update` block of your deployment
    manifest, all instances will be deleted in parallel.

#### Example

Given a `dummy` instance group resulting in Bosh instances (VMs) spread over
two availability zones like this:

```
$ bosh instances
Instance                                   ... AZ
dummy/6488acf4-ea9d-4aab-aad5-95df06fc43a2 ... z1
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/c53e18df-1e47-44f9-9e41-3ee999aa4a87 ... z1
```

The `bosh deploy` operation will output such task logs:

```
  instance_groups:
  - name: dummy
    azs:
+   - z3
-   - z1
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

And the resulting instances will be placed on `z2` and `z3` like this:

```
Instance                                   ... AZ
dummy/4a1840a7-b239-4635-9d8e-1830567cd040 ... z3
dummy/6c002f9c-ab11-4468-9bcb-578819cf4b77 ... z2
dummy/cbb84b42-e6a6-4b4d-b560-e418177d2d6f ... z2
```

## Migrating from Bosh v1 to Bosh v2 first-class AZs

Previously with “_Bosh v1_” deployment manifests, to spread resources over
multiple availability zones (AZs), deployment jobs, resource pools, and
networks had to be duplicated and named differently in the deployment
manifest. By convention, all of these resources were suffixed with `_z1` or
`zX` to indicate which AZ they belonged to.

With first-class AZs support in the Director, “_Bosh v2_” deployment manifests
no longer need to duplicate and rename resources. This allows the Director to
eliminate and/or simplify manual configuration for balancing instances (VMs)
across AZs and IP address management.

!!! Caveat
    From a “_Bosh v1_” director, once you opt into using the “_Bosh v2_” Cloud
    Config, all deployments must be converted to use new format. There is no
    way back to “_Bosh v1_” deployment manifests after you've opted in to
    Cloud Config.
