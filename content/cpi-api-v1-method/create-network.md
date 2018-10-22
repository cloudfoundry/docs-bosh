# create_network

Creates a network that will be used to place VMs on.

## Arguments

Properties required for creating network. May contain `range` and `gateway` keys. `cloud_properties` (required) are the properties required for creating this network specific to the CPI/IaaS.

```
{
  type: String (required)
  cloud_properties: Hash (required)
  range: String (optional)
  gateway: String (optional)
  netmask_bits: Integer (optional)
}
```

## Result

* Array with format `[network_id (string), addresses (hash), cloud properties (hash)]`


## Examples

`cloud_properties` are IaaS-specific. See implementations below.

### API request

```json
{
  "method": "create_network",
  "arguments": [
    {
      "type": "manual",
      "cloud_properties": {
        ...
      },
      "range": "192.168.10.0/24",
      "gateway": "192.168.10.1",
      "netmask_bits": 24,
    }
  ],
  "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
  }
}
```

### API response

```json
{
  "result": [

    // Network ID
    "<network_id>",

    // Address properties
    {
      "range": "192.168.10.0/24",
      "gateway": "192.168.10.1",
      "reserved": ["192.168.10.2"]
    },

    // Cloud Properties (IaaS specific)
    {
      ...
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
