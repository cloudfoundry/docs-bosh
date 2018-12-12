# Changing VM Update Strategy

The `vm_strategy` property was added to the [`update` section](manifest-v2.md#update) of deployment manifests to control how VMs are updated during a deploy.

!!! note
    This feature was introduced in [bosh/267.2](https://github.com/cloudfoundry/bosh/releases/tag/v267.2).

Historically, when a VM needs to be replaced (e.g. stemcell update, networking change), the director takes time to: stop all processes, delete the VM in the IaaS, create a new VM, provision it, and start the processes. Depending on your IaaS, this process can take several minutes and, depending on your release deployment strategy, may cause downtime. This is still the default behavior, and it is called the `delete-create` strategy. The following diagram represents the process flow, with grey representing potential downtime.

--8<-- "snippets/diagrams/deployment-vm-strategy/delete-create.svg"

The new strategy is called `create-swap-delete`. This strategy shifts IaaS-related and most provisioning steps to occur before the running processes on a VM are stopped. The workflow of this strategy looks like: create a new VM, provision it, stop jobs on the old VM, reattach persistent disks (if present), start jobs. One of the most noticeable impacts this has is to reduce the duration of downtime since the deployment no longer needs to wait for IaaS VM resource management while jobs are stopped.

--8<-- "snippets/diagrams/deployment-vm-strategy/create-swap-delete.svg"

You can see that `create-swap-delete` introduces new functionality for deferring VM deletions as well. Old VMs will be "orphaned" (similar to disks) and scheduled for clean up. Typically cleanup starts within 5 minutes.


## Usage

To change this behavior in your deployment, add `vm_strategy` to your deployment's [`update` section](manifest-v2.md#update). For example...

    update:
      canaries: 4
      ...
      vm_strategy: create-swap-delete

!!! tip
    The `update` section can be overridden at the instance group level. This allows you to opt-in or opt-out specific instance groups which need different strategies.


## Use Cases

 * H/A Tradeoff - some deployments may consider ~20s of downtime through `create-swap-delete` to be acceptable when compared to the requirements of running a component with full H/A redundancy.
    * Persistent Disks - when using persistent disks, there is still a dependency on the IaaS for detaching and attaching the disk. Note: IaaSes take different periods of time for this operation, and even within the same IaaS, duration can vary.
 * Reduce Deployment Time - some deployments may benefit from bulk creating VMs up front rather than as part of the instance update process. Deployment time may remain roughly the same, however, once created, the time during which VMs are being updated and needing special monitoring should be noticeably reduced.


## Caveats

 * The `create-swap-delete` strategy will not be used for instances in instance groups that are using static IPs due to the exclusivity of the IPs in IaaSes.
 * When using `create-swap-delete`, your IaaS resource usage will inherently surge during the deploy while BOSH creates additional VMs in preparation for update. You may need to review any resource limits which are in effect for your IaaS and account.
