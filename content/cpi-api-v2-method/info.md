# info

Returns information about the CPI to help the Director to make decisions on which CPI to call for certain operations in a multi CPI scenario.


## Arguments

No arguments


## Result

 * `stemcell_formats` [Array of strings]: Stemcell formats supported by the CPI. Currently used in combination with `create_stemcell` by the Director to determine which CPI to call when uploading a stemcell.
 * `api_version` [int]: maximum supported version by CPI.

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
   "api_version": 2, //cpi_api_version
   "stemcell_formats": [
     "dummy"
   ]
 }
}
```
