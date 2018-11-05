# Links API

!!! note
    The links API is available in bosh-release v266.0+

    This API reference assumes the director is deployed with UAA.

See [Links](links.md) for an introduction on links, link providers, and link consumers. This API is hosted on the director.

## Providers
### `GET /link_providers`: List Providers

Obtain an array of providers created in a deployment.

#### Request Query Params
* **deployment**: [String] Deployment name.

```shell
$ bosh curl /link_providers?deployment=zookeeper
[
  {
    "owner_object": {
      "info": {
        "instance_group": "zookeeper"
      },
      "name": "zookeeper",
      "type": "job"
    },
    "link_provider_definition": {
      "name": "peers",
      "type": "zookeeper_peers"
    },
    "deployment": "zookeeper",
    "shared": false,
    "name": "peers",
    "id": "2"
  },
  {
    "owner_object": {
      "info": {
        "instance_group": "zookeeper"
      },
      "name": "zookeeper",
      "type": "job"
    },
    "link_provider_definition": {
      "name": "conn",
      "type": "zookeeper"
    },
    "deployment": "zookeeper",
    "shared": true,
    "name": "conn",
    "id": "1"
  }
]
```

## Consumers

### `GET /link_consumers`: List Consumers

Obtain an array of consumers created for a deployment.

#### Request Query Params
* **deployment**: [String] Deployment name.

```shell
$ bosh curl /link_consumers?deployment=zookeeper
[
  {
    "link_consumer_definition": {
      "type": "zookeeper_peers",
      "name": "peers"
    },
    "owner_object": {
      "info": {
        "instance_group": "zookeeper"
      },
      "name": "zookeeper",
      "type": "job"
    },
    "deployment": "zookeeper",
    "optional": false,
    "name": "peers",
    "id": "1"
  },
  {
    "link_consumer_definition": {
      "type": "zookeeper",
      "name": "conn"
    },
    "owner_object": {
      "info": {
        "instance_group": "smoke-tests"
      },
      "name": "smoke-tests",
      "type": "job"
    },
    "deployment": "zookeeper",
    "optional": false,
    "name": "conn",
    "id": "2"
  }
]

```

## Links

### `GET /links`: List Links

Obtain an array of links created for a deployment.

#### Request Query Params
* **deployment**: [String] Deployment name.

```shell
$ bosh curl /links?deployment=zookeeper
[
  {
    "created_at": "2018-08-14 18:00:36 UTC",
    "link_provider_id": "4",
    "link_consumer_id": "3",
    "name": "peers",
    "id": "1"
  },
  {
    "created_at": "2018-08-14 18:00:36 UTC",
    "link_provider_id": "3",
    "link_consumer_id": "4",
    "name": "conn",
    "id": "2"
  }
]
```

### `POST /links`: Create Link

Create an external link with a user-defined consumer. Uses an existing provider.

!!! note
    The UAA client creating the link must have a **full admin** or **team admin** scope. See [Director Users and Permissions](https://bosh.io/docs/director-users-uaa-perms/) for details.

#### Request Headers
* `Content-Type: application/json`

#### Request Schema
* **link_provider_id**: [String] The id corresponding to the existing link provider.
* **link_consumer**:
    * **owner_object**:
        * **name**: [String] The name for the new consumer.
        * **type**: [String] Type is always "external".
* **network**: [String] Name of a network used by the provider (optional). See [custom network linking](links.md#custom-network).

```shell
$ bosh curl -X POST -H 'Content-Type: application/json' --body <(echo '{
  "link_provider_id": "1",
  "link_consumer": {
    "owner_object": {
      "name": "my_consumer",
      "type": "external"
    }
  }
}') /links
```

#### Response Schema
* **created_at**: [Date] Timestamp.
* **link_provider_id**: [String] ID of the provider used.
* **link_consumer_id**: [String] ID of the new consumer created for this link.
* **name**: [String] The name of the link, set from the provider.

```json
{
  "created_at": "2018-08-17 15:39:00 UTC",
  "link_provider_id": "1",
  "link_consumer_id": "3",
  "name": "zookeeper",
  "id": "3"
}
```

### `DELETE /links/link-id`: Delete

Delete links created with this API.

!!! note
    The UAA client deleting the link must have a **full admin** or **team admin** scope. See [Director Users and Permissions](https://bosh.io/docs/director-users-uaa-perms/) for details.

#### Request

* **link-id**: [String] ID of link to delete.

```shell
$ bosh curl -X DELETE /links/3
```

#### Response
* **HTTP 204**: Deleted successfully.
* **HTTP 404**: Link not found.
* **HTTP 400**: Bad request. Only links with type `external` can be deleted.

## Link Address

### `GET /link_address`: Link Address

Obtain the DNS address for a singular link. This is equivalent to using `link("my-link").address` in jobs templates.

#### Request Params
* **link_id**: [String] The link ID.
* **azs[]**: [String] Name of the AZ to filter by (optional). This parameter should be provided multiple times when specifying multiple availability zones; see example below.
* **status**: [String] Filter by health status. One of: healthy, unhealthy, all, default (optional).

```shell
$ bosh curl '/link_address?link_id=3&azs[]=z1'
```

#### Response Body
* **address**: [String] DNS address for the link.

```json
{
  "address": "q-a1s0.zookeeper.default.zookeeper.bosh"
}
```

#### Specifying Multiple AZs in the Same Request
The `azs[]` parameter should be provided multiple times when specifying multiple AZs in the query request. For example, to filter by availability zones **z1**, **z2**, and **z3**, the request will look like:

```shell
$ bosh curl '/link_address?link_id=3&azs[]=z1&azs[]=z2&azs[]=z3'
```
