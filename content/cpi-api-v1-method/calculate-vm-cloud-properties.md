# calculate_vm_cloud_properties

Returns a hash that can be used as VM `cloud_properties` when calling `create_vm`; it describes the IaaS instance type closest to the arguments passed.

The `cloud_properties` returned are IaaS-specific. For example, when querying the AWS CPI for a VM with the parameters `{ "cpu": 1, "ram": 512, "ephemeral_disk_size": 1024 }`, it will return the following, which includes a `t2.nano` instance type which has 1 CPU and 512MB RAM:

```json
{
  "instance_type": "t2.nano",
  "ephemeral_disk": { "size": 1024 }
}
```

`calculate_vm_cloud_properties` returns the minimum resources that satisfy the parameters, which may result in a larger machine than expected. For example, when querying the AWS CPI for a VM with the parameters `{ "cpu": 1, "ram": 8192, "ephemeral_disk_size": 4096}`, it will return an `m4.large` instance type (which has 2 CPUs) because it is the smallest instance type which has at least 8 GiB RAM.

If a parameter is set to a value greater than what is available (e.g. 1024 CPUs), an error is raised.


## Arguments

 * `desired_instance_size` [Hash]: Parameters of the desired size of the VM consisting of the following keys:
   * `cpu` [Integer]: Number of virtual cores desired
   * `ram` [Integer]: Amount of RAM, in MiB (i.e. `4096` for 4 GiB)
   * `ephemeral\_disk\_size` [Integer]: Size of ephemeral disk, in MB


## Result

 * `cloud_properties` [Hash]: an IaaS-specific set of cloud properties that define the size of the VM.


## Examples


### API Request

```json
{
  "ram": 1024,
  "cpu": 2,
  "ephemeral_disk_size": 2048
}
```


## Related

 * [`create_vm`](create-vm.md)
