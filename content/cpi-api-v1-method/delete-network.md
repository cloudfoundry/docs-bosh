# delete_network

Deletes a network that was created using `create_network`.

## Arguments

* `network_id` [String]: network_id of the network to delete.


## Result

No return value.


## Examples

### API request

```json
{
  "method": "delete_network",
  "arguments": ["<network_id>"],
  "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
  }
}
```


### Implementations

 * [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/blob/dfe878579cbab768af07a12bb5543cd016cbb762/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L690)


## Related

 * [create_network](create-network.md)
