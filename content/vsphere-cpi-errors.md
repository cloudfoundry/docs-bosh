## Field object_set is not optional

>     Field object_set is not optional

This error may occur when global CPI configuration references:

- cluster (via `clusters` key) that cannot be found in the datacenter
- stemcell that cannot be found in the templates folder


## Missing Properties Exception

>     ...should have the following properties: ["info.progress", "info.state", "info.result", "info.error"] (VSphereCloud::CloudSearcher::MissingPropertiesException), but they were missing these: #<Set: {"info.state"}>

Add `System.View` on vCenter server level so that persistent disks can be moved between the datastores.


## Field counter_id is not optional

>     Field counter_id is not optional
>     ...lib/cloud/vsphere/client.rb:270:in `fetch_perf_metric_names'

The CPI requires access to performance metrics from ESXi hosts. This error may be returned if one of the hosts in the cluster is not returning these metrics (e.g. `memory.usage.average`). Possible solution is to [restart management agents](http://www.running-system.com/no-cpu-and-memory-usage-data-from-host-available-in-vcenter/) on the hosts.


## Failed to add disk

>     Failed to add disk scsi0:2.

This error typically occurs when persistent disk is being attached to a second VM while it is attached to another VM. That may happen when first VM was not properly deleted and BOSH is no longer aware of its existence.


## Could not acquire HTTP NFC lease

>     Could not acquire HTTP NFC lease, message is: 'A specified parameter was not correct.' fault cause is: '', fault message is: [], dynamic type is '', dynamic property is []'

The [vCenter docs](https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.vm.DefaultPowerOpInfo.html) show that the value should be `preset` rather than `default` inside the OVF file. Switching `powerOpInfo.*` properties resolved the problem.
