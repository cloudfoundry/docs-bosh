# info

Returns information about the CPI to help the Director to make decisions on which CPI to call for certain operations in a multi CPI scenario.


## Arguments

No arguments


## Result

 * `stemcell_formats` [Array of strings]: The list of stemcell formats this CPI supports.
 * `api_version` [int]: maximum version of the API contract supported by the CPI.

## Examples

### API Request

```json
{
 "method": "info",
 "arguments": [],
 "context": {
   "director_uuid": "<director-uuid>",
   "request_id": "<cpi-request-id>",
 },
}
```

### API Response

```json
{
 "log": "",
 "error": null,
 "result": {
   "api_version": 2,
   "stemcell_formats": [
     "dummy"
   ]
 }
}
```
The `api_version` is the version of the API contract that the CPI supports. New CPIs adopting the V2 contract must return `2`. If there is no version supplied, the Director assumes version 1 of the contract must be used.

## Related

 * [info V1](../cpi-api-v1-method/info.md)
