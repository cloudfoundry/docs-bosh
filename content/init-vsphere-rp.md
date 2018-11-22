If the BOSH director is required to be deployed within a vSphere Resource Pool, utilize the following additional CLI arguments when creating the BOSH env:

```shell
bosh create-env bosh-deployment/bosh.yml \
    -o ... \
    -o bosh-deployment/vsphere/resource-pool.yml \
    -v ... \
    -v vcenter_rp=my-bosh-rp
```

!!! note
    The vSphere resource pool must already be created before running the `bosh create-env` command.
