# RPC Interface

All CPIs are expected to implement a basic RPC interface through `STDIN`/`STDOUT`.


## Invocation

Since CPI is just an executable, following takes place for each CPI method call (where "caller" is often the director):

1. Caller starts a new CPI executable OS process (shells out)
1. Caller sends a [single JSON request](#request) over `STDIN`
   - CPI optionally sends logging debugging information to `STDERR`
1. CPI responds with a [single JSON response](#response) over `STDOUT`
1. CPI executable exits
1. Caller parses and interprets JSON response ignoring process exit code

For reference, there are two primary implementations of the "caller" which invoke the CPI...

 * BOSH Director - invokes the CPI through typical `deploy`/stemcell commands, internally using its [`external_cpi.rb`](https://github.com/cloudfoundry/bosh/blob/master/src/bosh-director/lib/cloud/external_cpi.rb) wrapper.
 * `bosh` CLI - invokes the CPI through `create-env`/`delete-env` commands, internally using its [`cpi_cmd_runner.go`](https://github.com/cloudfoundry/bosh-cli/blob/master/cloud/cpi_cmd_runner.go).


## API

### Request {: #request }

* `method` [String]: Name of the CPI method. Example: `create_vm`.
* `arguments` [Array]: Array of arguments that are specific to the CPI method.
* `context` [Hash]: Additional information provided as a context of this execution. Specified for backwards compatibility and should be ignored.

An example request for [`delete_disk`](cpi-api-v1-method/delete-disk.md) might look like:

```json
{
  "method": "delete_disk",
  "arguments": ["vol-1b7fb8fd"],
  "context": { "director_uuid":"fefb87c8-38d1-46a5-4552-9749d6b1195c" }
}
```


### Response {: #response }

* `result` [Null or simple values]: Single return value. It must be null if `error` is returned.
* `error` [Null or hash]: Occurred error. It must be null if `result` is returned.
  * `type` [String]: Type of the error.
    * `message` [String]: Description of the error.
    * `ok_to_retry` [Boolean]: Indicates whether callee should try calling the method again without changing any of the arguments.
* `log` [String]: Additional information that may be useful for auditing, debugging and understanding what actions CPI took while executing a method. Typically includes info and debug logs, error backtraces.

An example response to [`create_vm`](cpi-api-v1-method/create-vm.md) might look like:

```json
{
  "result": "i-384959",
  "error": null,
  "log": ""
}
```

An example error response to [`create_vm`](cpi-api-v1-method/create-vm.md) might look like:

```json
{
  "result": null,
  "error": {
    "type": "Bosh::Clouds::CloudError",
    "message": "Flavor `m1.2xlarge' not found",
    "ok_to_retry": false
  },
  "log": "Rescued error: 'Flavor `m1.2xlarge' not found'. Backtrace: ~/.bosh_init/ins..."
}
```


## Methods

 * [info](cpi-api-v1-method/info.md)
 * Stemcells
    * [create_stemcell](cpi-api-v1-method/create-stemcell.md)
    * [delete_stemcell](cpi-api-v1-method/delete-stemcell.md)
 * VM Management
    * [create_vm](cpi-api-v1-method/create-vm.md)
    * [delete_vm](cpi-api-v1-method/delete-vm.md)
    * [has_vm](cpi-api-v1-method/has-vm.md)
    * [reboot_vm](cpi-api-v1-method/reboot-vm.md)
    * [set_vm_metadata](cpi-api-v1-method/set-vm-metadata.md)
    * [calculate_vm_cloud_properties](cpi-api-v1-method/calculate-vm-cloud-properties.md)
 * Disk Management
    * [create_disk](cpi-api-v1-method/create-disk.md)
    * [delete_disk](cpi-api-v1-method/delete-disk.md)
    * [resize_disk](cpi-api-v1-method/resize-disk.md)
    * [has_disk](cpi-api-v1-method/has-disk.md)
    * [attach_disk](cpi-api-v1-method/attach-disk.md)
    * [detach_disk](cpi-api-v1-method/detach-disk.md)
    * [set_disk_metadata](cpi-api-v1-method/set-disk-metadata.md)
    * [get_disks](cpi-api-v1-method/get-disks.md)
    * Snapshot Management
        * [snapshot_disk](cpi-api-v1-method/snapshot-disk.md)
        * [delete_snapshot](cpi-api-v1-method/delete-snapshot.md)
 * Deprecated
    * [configure_networks](cpi-api-v1-method/configure-networks.md)
    * [current_vm_id](cpi-api-v1-method/current-vm-id.md)
