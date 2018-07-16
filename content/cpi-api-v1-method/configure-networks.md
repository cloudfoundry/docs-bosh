# configure_networks

The recommended implementation is to raise `Bosh::Clouds::NotSupported` error. This method will be deprecated in API v2.

After the Director received NotSupported error, it will delete the VM (via `delete_vm`) and create a new VM with desired network configuration (via `create_vm`).


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM to modify; returned from `create_vm`.
 * `networks` [Hash]: Network hashes that specify networks VM must be configured.


## Result

No return value


## Examples

```json
[
  "i-238445",
  {
    "private": {
      "type": "manual",
      "netmask": "255.255.255.0",
      "gateway": "10.230.13.1",
      "ip": "10.230.13.6",
      "default": [ "dns", "gateway" ],
      "cloud_properties": { "net_id": "subnet-48rt54" }
      },
      "private2": {
      "type": "dynamic",
      "cloud_properties": { "net_id": "subnet-e12364" }
    },
    "public": {
      "type": "vip",
      "ip": "173.247.112.104",
      "cloud_properties": {}
    }
  }
]
```
