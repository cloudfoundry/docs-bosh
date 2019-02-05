# create_network

Creates a network that will be used to place VMs on.

## Arguments

Properties required for creating the network. It may contain `range` and `gateway` keys. A `cloud_properties` is required to provide information specific to the CPI and target IaaS. 

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

* Array with the following format: `[network_id (string), addresses (hash), cloud properties (hash)]`


## Examples

`cloud_properties` are IaaS-specific. See the current implementations below.

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

 * [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/blob/master/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L720-L725)


## Related

 * [delete_network](delete-network.md)
