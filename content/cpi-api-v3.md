# Cloud Provider Interface (Version 3)

For an overview of the sequence of the CPI calls, please have a look at the following resources:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)


If you're looking to get started on building a CPI, this [short guide](build-cpi.md) may be helpful. To learn more about the technical implementation, continue reading or refer to the [RPC Interface](cpi-api-rpc.md) for more details.


Libraries:

- Ruby: `bosh-cpi-ruby` gem [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)
- GoLang: `bosh-cpi-go` [library](https://github.com/cloudfoundry/bosh-cpi-go)

---

## Changes (comparing to V2)

- If the `"api_version` of a cpi release equals or is greater than 3 the bosh director sends an additional parameter with the listed methods.
- The corresponding CPI method must expect an additional parameter of type hash.

## Methods

This list of methods to expect an additional parameter:

* Stemcell Management
    * [create_stemcell](cpi-api-v3-method/create-stemcell.md)