!!! note
    Requires director v277.4.0 and CLI v7.3.0

BOSH provides the `create-recovery-plan` and `recover` CLI commands to repair IaaS resources used by a specific deployment. The underlying machinery is very similar to [Cloud Check](cck.md), with several exceptions:

1. There is a 2-step process: `create-recovery-plan` scans the deployment for problems and then prompts the user to generate a recovery plan, which is saved to a file.  The `recover` consumes that file.
1. Resolutions to problems are selected by instance group and problem type. The `cloud-check` command asks for a resolution for each particular problem.
1. When generating a recovery plan, `max_in_flight` can be overriden per instance group.  This can be handy to speed deployment recovery.  The `cloud-check` command uses the `max_in_flight` values in the deployment manfiest.


Otherwise, the types of [problems](cck.md#problems) and the mechanism by which they are repaired are the same as in the `cloud-check` command.


## Creating a recovery plan {: #create-recovery-plan }

To create a recovery plan, invoke the  `bosh create-recovery-plan` like:

```shell
bosh create-recovery-plan recovery-plan.yml
```

```text
Task 223

Task 223 | 17:17:43 | Scanning 9 VMs: Checking VM states (00:00:31)
Task 223 | 17:18:14 | Scanning 9 VMs: 3 OK, 2 unresponsive, 4 missing, 0 unbound (00:00:00)
Task 223 | 17:18:14 | Scanning 3 persistent disks: Looking for inactive disks (00:00:08)
Task 223 | 17:18:22 | Scanning 3 persistent disks: 2 OK, 0 missing, 0 inactive, 1 mount-info mismatch (00:00:00)

Task 223 Started  Tue Jul 11 17:17:43 UTC 2023
Task 223 Finished Tue Jul 11 17:18:22 UTC 2023
Task 223 Duration 00:00:39
Task 223 done

Instance Group 'cloud_controller_ng'


Problem type: missing_vm

#    Description
241  VM for 'cloud_controller_ng/fb4db9d0-3225-49e0-95f0-02926718554f (2)' with cloud ID 'vm-2c2df389-1d6c-4373-64ca-82950edc5595' missing.

1 missing_vm problems

1: Skip for now
2: Recreate VM without waiting for processes to start
3: Recreate VM and wait for processes to start
4: Delete VM reference
missing_vm (1): 2

Problem type: unresponsive_agent

#    Description
237  VM for 'cloud_controller_ng/6beb143e-055b-48ce-9eff-8236866b0dc7 (1)' with cloud ID 'vm-b457a975-73e0-4330-476c-86175eda1438' is not responding.

1 unresponsive_agent problems

1: Skip for now
2: Reboot VM
3: Recreate VM without waiting for processes to start
4: Recreate VM and wait for processes to start
5: Delete VM
6: Delete VM reference (forceful; may need to manually delete VM from the Cloud to avoid IP conflicts)
unresponsive_agent (1): 2

Override current max_in_flight value of '50%'? [yN]: N

Instance Group 'diego_cell'


Problem type: missing_vm

#    Description
239  VM for 'diego_cell/837faa6d-735b-4068-a201-944916c3c051 (1)' with cloud ID 'vm-4a68e03f-5eb5-41b8-5ce1-2eba1f62c873' missing.
242  VM for 'diego_cell/8a6186b1-1465-453b-b9dd-35de5dedfed9 (0)' with cloud ID 'vm-a80bf596-bf23-4e13-67c7-9219e75ca3da' missing.

2 missing_vm problems

1: Skip for now
2: Recreate VM without waiting for processes to start
3: Recreate VM and wait for processes to start
4: Delete VM reference
missing_vm (1): 2

Problem type: mount_info_mismatch

#    Description
243  Inconsistent mount information:
     Record shows that disk 'disk-cf4a1687-3399-4d61-4661-2974255e19c3' should be mounted on vm-bb29ea10-fe59-4feb-69dc-8917694f5ab3.
     However it is currently :
     	Not mounted in any VM

1 mount_info_mismatch problems

1: Ignore
2: Reattach disk to instance
3: Reattach disk and reboot instance
mount_info_mismatch (1): 3

Override current max_in_flight value of '2'? [yN]: y

max_in_flight override for 'diego_cell' (2): 3

Instance Group 'router'


Problem type: missing_vm

#    Description
240  VM for 'router/408d72b9-d5d9-455c-9e6e-75997d4e47e4 (1)' with cloud ID 'vm-3b6643c4-9ffe-4e6e-4759-d796db979b20' missing.

1 missing_vm problems

1: Skip for now
2: Recreate VM without waiting for processes to start
3: Recreate VM and wait for processes to start
4: Delete VM reference
missing_vm (1): 2

Problem type: unresponsive_agent

#    Description
238  VM for 'router/a84205fb-c6be-4c26-89f2-93f6019acaf1 (0)' with cloud ID 'vm-77fa8ee8-30cb-40cf-74f2-fa0716005322' is not responding.

1 unresponsive_agent problems

1: Skip for now
2: Reboot VM
3: Recreate VM without waiting for processes to start
4: Recreate VM and wait for processes to start
5: Delete VM
6: Delete VM reference (forceful; may need to manually delete VM from the Cloud to avoid IP conflicts)
unresponsive_agent (1): 2

Override current max_in_flight value of '1'? [yN]: y

max_in_flight override for 'router' (1): 100%

Succeeded
```

### Recovery plan {: #recovery-plan }

Each recovery plan has the following schema:

**instance_groups_plan** [Array, required]: The name of instance groups in the deployment to recover.

* **max_in_flight_override** [Integer or Percentage, required]: The `max_in_flight` value to use for problem resolution in the given instance group.
* **planned_resolutions** [Hash, optional]: Specifies which resolution to pick per problem type.  Example: `{missing_vm: recreate_vm_without_wait, unresponsive_agent: reboot}`

Here is an example of a complete recovery plan, generated from the above session:

```yaml
instance_groups_plan:
- name: cloud_controller_ng
  planned_resolutions:
    missing_vm: recreate_vm_without_wait
    unresponsive_agent: reboot_vm
- name: diego_cell
  max_in_flight_override: "3"
  planned_resolutions:
    missing_vm: recreate_vm_without_wait
    mount_info_mismatch: reattach_disk_and_reboot
- name: router
  max_in_flight_override: 100%
  planned_resolutions:
    missing_vm: recreate_vm_without_wait
    unresponsive_agent: reboot_vm
```

## Applying a recovery plan {: #recover }

Using the recovery plan above, invoking `bosh recover` looks like:

```shell
bosh recover recovery-plan.yml
```

```text
Task 225

Task 225 | 17:35:49 | Scanning 9 VMs: Checking VM states (00:00:31)
Task 225 | 17:36:20 | Scanning 9 VMs: 3 OK, 2 unresponsive, 4 missing, 0 unbound (00:00:00)
Task 225 | 17:36:20 | Scanning 3 persistent disks: Looking for inactive disks (00:00:00)
Task 225 | 17:36:20 | Scanning 3 persistent disks: 2 OK, 0 missing, 0 inactive, 1 mount-info mismatch (00:00:00)

Task 225 Started  Tue Jul 11 17:35:49 UTC 2023
Task 225 Finished Tue Jul 11 17:36:20 UTC 2023
Task 225 Duration 00:00:31
Task 225 done

Instance Group 'diego_cell' plan summary (max_in_flight override: 3)

#    Planned resolution                                  Description
244  Recreate VM without waiting for processes to start  VM for 'diego_cell/8a6186b1-1465-453b-b9dd-35de5dedfed9 (0)' with cloud ID 'vm-a80bf596-bf23-4e13-67c7-9219e75ca3da' missing.
247  Recreate VM without waiting for processes to start  VM for 'diego_cell/837faa6d-735b-4068-a201-944916c3c051 (1)' with cloud ID 'vm-4a68e03f-5eb5-41b8-5ce1-2eba1f62c873' missing.
250  Reattach disk and reboot instance                   Inconsistent mount information:
                                                         Record shows that disk 'disk-cf4a1687-3399-4d61-4661-2974255e19c3' should be mounted on vm-bb29ea10-fe59-4feb-69dc-8917694f5ab3.
                                                         However it is currently :
                                                         	Not mounted in any VM

Instance Group 'router' plan summary (max_in_flight override: 100%)

#    Planned resolution                                  Description
245  Recreate VM without waiting for processes to start  VM for 'router/408d72b9-d5d9-455c-9e6e-75997d4e47e4 (1)' with cloud ID 'vm-3b6643c4-9ffe-4e6e-4759-d796db979b20' missing.
249  Reboot VM                                           VM for 'router/a84205fb-c6be-4c26-89f2-93f6019acaf1 (0)' with cloud ID 'vm-77fa8ee8-30cb-40cf-74f2-fa0716005322' is not responding.

Instance Group 'cloud_controller_ng' plan summary

#    Planned resolution                                  Description
246  Recreate VM without waiting for processes to start  VM for 'cloud_controller_ng/fb4db9d0-3225-49e0-95f0-02926718554f (2)' with cloud ID 'vm-2c2df389-1d6c-4373-64ca-82950edc5595' missing.
248  Reboot VM                                           VM for 'cloud_controller_ng/6beb143e-055b-48ce-9eff-8236866b0dc7 (1)' with cloud ID 'vm-b457a975-73e0-4330-476c-86175eda1438' is not responding.

Continue? [yN]: y




Task 226

Task 226 | 17:37:02 | Applying problem resolutions: VM for 'router/a84205fb-c6be-4c26-89f2-93f6019acaf1 (0)' with cloud ID 'vm-77fa8ee8-30cb-40cf-74f2-fa0716005322' is not responding. (unresponsive_agent 62): Reboot VM
Task 226 | 17:37:02 | Applying problem resolutions: VM for 'router/408d72b9-d5d9-455c-9e6e-75997d4e47e4 (1)' with cloud ID 'vm-3b6643c4-9ffe-4e6e-4759-d796db979b20' missing. (missing_vm 63): Recreate VM without waiting for processes to start (00:02:15)Task 226 | 17:39:24 | Applying problem resolutions: VM for 'router/a84205fb-c6be-4c26-89f2-93f6019acaf1 (0)' with cloud ID 'vm-77fa8ee8-30cb-40cf-74f2-fa0716005322' is not responding. (unresponsive_agent 62): Reboot VM (00:02:22)
Task 226 | 17:39:24 | Applying problem resolutions: VM for 'diego_cell/837faa6d-735b-4068-a201-944916c3c051 (1)' with cloud ID 'vm-4a68e03f-5eb5-41b8-5ce1-2eba1f62c873' missing. (missing_vm 66): Recreate VM without waiting for processes to start
Task 226 | 17:39:24 | Applying problem resolutions: Inconsistent mount information:
Record shows that disk 'disk-cf4a1687-3399-4d61-4661-2974255e19c3' should be mounted on vm-bb29ea10-fe59-4feb-69dc-8917694f5ab3.
However it is currently :
	Not mounted in any VM (mount_info_mismatch 23): Reattach disk and reboot instance
Task 226 | 17:39:24 | Applying problem resolutions: VM for 'diego_cell/8a6186b1-1465-453b-b9dd-35de5dedfed9 (0)' with cloud ID 'vm-a80bf596-bf23-4e13-67c7-9219e75ca3da' missing. (missing_vm 65): Recreate VM without waiting for processes to start
Task 226 | 17:41:53 | Applying problem resolutions: Inconsistent mount information:
Record shows that disk 'disk-cf4a1687-3399-4d61-4661-2974255e19c3' should be mounted on vm-bb29ea10-fe59-4feb-69dc-8917694f5ab3.
However it is currently :
	Not mounted in any VM (mount_info_mismatch 23): Reattach disk and reboot instance (00:02:29)
Task 226 | 17:41:56 | Applying problem resolutions: VM for 'diego_cell/837faa6d-735b-4068-a201-944916c3c051 (1)' with cloud ID 'vm-4a68e03f-5eb5-41b8-5ce1-2eba1f62c873' missing. (missing_vm 66): Recreate VM without waiting for processes to start (00:02:32)
Task 226 | 17:41:58 | Applying problem resolutions: VM for 'diego_cell/8a6186b1-1465-453b-b9dd-35de5dedfed9 (0)' with cloud ID 'vm-a80bf596-bf23-4e13-67c7-9219e75ca3da' missing. (missing_vm 65): Recreate VM without waiting for processes to start (00:02:34)
Task 226 | 17:41:58 | Applying problem resolutions: VM for 'cloud_controller_ng/fb4db9d0-3225-49e0-95f0-02926718554f (2)' with cloud ID 'vm-2c2df389-1d6c-4373-64ca-82950edc5595' missing. (missing_vm 70): Recreate VM without waiting for processes to start (00:02:22)
Task 226 | 17:44:20 | Applying problem resolutions: VM for 'cloud_controller_ng/6beb143e-055b-48ce-9eff-8236866b0dc7 (1)' with cloud ID 'vm-b457a975-73e0-4330-476c-86175eda1438' is not responding. (unresponsive_agent 69): Reboot VM (00:02:26)

Task 226 Started  Tue Jul 11 17:37:02 UTC 2023
Task 226 Finished Tue Jul 11 17:46:46 UTC 2023
Task 226 Duration 00:09:44
Task 226 done

Succeeded
```