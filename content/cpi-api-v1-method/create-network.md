# create_network

Creates a network that will be used to place VMs on.

## Arguments

* `network_definition` [Hash]: network_definition properties required for creating network. May contain range and gateway keys. Has to have cloud_properties - properties required for creating this network  specific to a CPI.


## Result

* network_info [Hash]: key has unique id of network, cloud_properties are properties required for placing VMs


## Examples

### API request

```json
{
  "method": "create_network",
  "arguments": [
    {
      "type": "manual",
      "cloud_properties": {
        "a": "b",
        "t0_id": "123456"
      },
      "range": "192.168.10.0/24",
      "gateway": "192.168.10.1"
    }
  ],
  "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
  },
  "api_version": 1
}
```

### API response

```json
{
  "result": [
    "<network_id>",
    {
      "range": "192.168.10.0/24",
      "gateway": "192.168.10.1",
      "reserved": ["192.168.10.2"]
    },
    {
      "name": "<network_name>"
    }
  ],
  "error": null,
  "log": ""
}
```


### Implementations

 * [cloudfoundry-incubator/bosh-vsphere-cpi-release](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release/blob/master/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L720-L725)


## Related

 * [delete_network](delete-network.md)
