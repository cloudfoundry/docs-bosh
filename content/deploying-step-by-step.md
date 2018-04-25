The Director will do the following [steps](https://www.youtube.com/watch?v=ay6GjmiJTPM) when `bosh deploy` (or its related commands such as start, stop and recreate) command runs:

1. Check if there is a deployment with the name specified by the deployment manifest
    - if no, create a deployment
    - if yes, lock the deployment so that no other operation can modify it

1. Validate the deployment manifest syntactically and semantically
    - if invalid, return an error to the user describing the problem(s)

1. Contact all existing VMs associated with this deployment to determine their network, configuration, and job configurations
    - if the Director cannot contact all VMs, return an error to the user. This results in a "Timed out sending `get_state` error" during the 'Binding existing deployment' stage. At this point the operator is expected to use `bosh cck` command to determine why certain VMs are not accessible.

1. Determine requested networking changes to the existing and new VMs
    - if network changes cannot be resolved (e.g. currently the Director does not support swapping of static IP reservations), return an error to the user
    - if network changes require more IPs than the deployment's networks allow, return an error to the user

1. Delete instance groups that are no longer specified by the deployment manifest
    - issue unmount_disk Agent call for attached disks
    - issue delete_vm CPI call for each VM
    - orphan persistent disks
    - [Update and propagate DNS records](deploying-step-by-step.md#dns)

1. Create compilation worker VMs based on as specified by `compilation` section
    - issue create_vm CPI call

1. Determine release packages dependency graph and compile each package on compilation worker VMs
    - issue compile_package Agent call for each package

1. Delete all compilation worker VMs
    - issue delete_vm CPI call

1. Create empty VMs for new instance groups
    - [Update and propagate DNS records](deploying-step-by-step.md#dns)

1. Create empty VMs for instance groups that increased in instance size
    - [Update and propagate DNS records](deploying-step-by-step.md#dns)

1. Update each one of the instance groups:

    Subset of instances (within an instance group) is selected to be updated first based on the update options for the instance group or global update options. That group of instances are called canaries.

    Even if only one job or package changed in the instance group, stopping and starting procedure will apply to all of the jobs on the instances in that group. One of the future enhancements is to make this procedure more surgical and only affect jobs that have changed.

    1. Check if the instance previously existed
        - if no, select a VM and assign it to be this instance
        - if yes, check to see what has changed since last time it was updated

    1. Download updated jobs and packages onto the VM
        - issue prepare Agent call

    1. [run drain and stop scripts to safely stop processes on the VM](job-lifecycle.md#stop)
        - issue drain Agent call
        - issue stop Agent call

    1. Take persistent disks snapshot associated with the job instance
        - issue take_snapshot CPI call if Director has snapshotting enabled

    1. Check if the instance group still uses the same stemcell
        - if no, create a new VM based on a correct stemcell
            - issue delete_vm CPI call
            - issue create_vm CPI call
            - [Update and propagate DNS records](deploying-step-by-step.md#dns)
        - if yes, do nothing

    1. Check if the instance group's network configuration changed
        - if no, do nothing
        - if yes, reconfigure running VM to match new configuration
            - issue delete_vm CPI call
            - issue create_vm CPI call
            - [Update and propagate DNS records](deploying-step-by-step.md#dns)

    1. Update DNS A record for this instance with new IP

    1. Check if the instance group's persistent disk changed
        - if no, do nothing
        - if yes, create a new persistent disk with correct size and type and copy data from the old persistent disk
            - issue create_disk CPI call for the new disk
            - issue attach_disk CPI call on a new disk
            - issue mount_disk Agent call on a new disk
            - issue migrate_disk Agent call on a new disk
            - orphan the old disk

    1. Configure VM to have new set of jobs
        - issue apply Agent call

    1. [start processes on the VM and wait up to specified amount of time by the `update_watch_time` or `canary_watch_time`](job-lifecycle.md#start)
        - issue start Agent call
        - issue get_state Agent call until job state is running or times out

---
## Update and propagate DNS records {: #dns }

1. Create a new DNS records dataset and saves it to the blobstore
1. issues sync_dns Agent call to *all* VMs (in all deployments)
1. Each Agent downloads new DNS records dataset and updates `/var/vcap/instance/dns/records.json`
