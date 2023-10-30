# delete_stemcell

Deletes previously created stemcell. Assume that none of the VMs require presence of the stemcell.


## Arguments

 * `stemcell_cid` [String]: Cloud ID of the stemcell to delete; returned from `create_stemcell`.


## Result

No return value


## Examples


### Implementations

 * cppforlife/bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/delete_stemcell.go)


## Related

 * [create_stemcell](create-stemcell.md)
