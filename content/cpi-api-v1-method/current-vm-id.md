# current_vm_id

Determines cloud ID of the VM executing the CPI code. Currently used in combination with `get_disks` by the Director to determine which disks to self-snapshot.

!!! note
    Do not implement; this method will be deprecated and removed.


## Arguments

No arguments


## Returned

 * `vm_cid` [String]: Cloud ID of the VM.
