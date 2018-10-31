If UAA is used for identity management, UAA will automatically verify
a user's permissions when they log into the BOSH Director.

!!! warning
    If you use the same private key to sign keys on different UAAs, users might obtain a token from one UAA and use it on the Director configured with a different UAA. It is therefore highly recommended to restrict scopes to individual Directors and not re-use a private key used for authenticating into UAA.

---
## Logging into the Director as a user {: #user-login }

Depending on how the UAA is configured different prompts may be shown.
The UAA Admin user, or another user with `clients.admin` or
`clients.write` scope,  may grant or revoke scopes to users and clients using
the following steps. Further details are in the [uaac
documentation](https://www.rubydoc.info/gems/cf-uaac/4.1.0).

```shell
$ bosh login
Email: admin
Password: **************
```

### Adding and Removing Users {: #uaac }

An example of how to use [UAA CLI](https://rubygems.org/gems/cf-uaac) to add a new user that has readonly access on any Director. Enter the client secret provided for the UAA admin client in the manifest at `uaa.admin.client_secret`.

```shell
$ uaac target https://54.236.100.56:8443 --ca-cert certs/rootCA.pem
$ uaac token client get admin
Client secret:  **************
$ uaac user add some-new-user --emails new.user@example.com
```

When a user is deleted, all of their permissions are implicitly removed
as well:

```shell
$ uaac user delete some-new-user
```

!!! note
    Use UAA CLI v3.1.4+ to specify custom CA certificate.

#### Granting and Revoking User Permissions

You can add permissions to users by defining a group and adding users to that group:

```shell
$ uaac group add bosh.read
$ uaac member add bosh.read some-new-user
```

Remove permission by removing users from a group:

```shell
$ uaac member delete bosh.read some-new-user
```


!!! note
    Changing group membership will take effect when a new access token is created for that user. New access are granted when their existing access token expires or when user logs out and logs in again. It is recommended to set access token validity to a short interval such as one minute.

---
## Logging into the Director as a UAA client {: #client-login }

Non-interactive login, e.g. for scripts during a CI build is supported by the UAA by using a different UAA client allowing `client_credentials` grant type.

```shell
$ export BOSH_CLIENT=ci
$ export BOSH_CLIENT_SECRET=ci-password
$ bosh status
```

See [the resurrector UAA client configuration](resurrector.md#uaa-client) for an example to set up an additional client.

---
## Errors {: #errors }

```
HTTP 401: Not authorized: '/deployments' requires one of the scopes: bosh.admin, bosh.UUID.admin, bosh.read, bosh.UUID.read
```

This error occurs if the user doesn't have the right scopes for the requested command. It might be the case that you created a user without adding it to any groups. See [Adding/removing users and scopes](#uaac) above.

# Director-Wide Scopes

A scope defines a set of tasks that a user or client is permissioned to
perform. Scopes are distinct from authorities, which define a user or
client's ability to manage internal privileges for the UAA component, such as `uaa.admin`.
More on this distinction can be found [in the UAA documentation](https://docs.cloudfoundry.org/uaa/uaa-concepts.html#scopes).

In the context of BOSH UAA, the following scopes are supported. BOSH UAA
also supports [BOSH Teams](director-bosh-teams.md) for more granular
scope management.

---
## Anonymous {: #anon }

Users with no UAA scopes are considered anonymous.

Can access:

- `bosh status`: show general information about targeted Director (authentication is not required)

---
## Full Admin {: #full-admin }

Scopes:

- `bosh.admin`: user has admin access on any Director
- `bosh.<DIRECTOR-UUID>.admin`: user has admin access on the Director with the corresponding UUID

Can use all commands on all deployments.

---
## Full Read-only {: #full-read }

Scopes:

- `bosh.read`: user has read access on any Director
- `bosh.<DIRECTOR-UUID>.read`: user has read access on the Director with the corresponding UUID

Cannot modify any resource.

Can access in read-only capacity:

- `bosh deployments`: list of *all* deployments and releases/stemcells used
- `bosh releases`: list of *all* releases and their versions
- `bosh stemcells`: list of *all* stemcells and their versions
- `bosh vms`: list of all VMs which includes job names, IPs, vitals, details, etc.
- `bosh tasks`: list of all tasks summaries which includes task descriptions without access to debug logs

---
## Stemcell uploader {: #stemcell-uploader }

!!! note
    This feature is available with bosh-release v261.2+.

Scopes:

- `bosh.stemcells.upload`: user can upload new stemcells

Note that CLI will try to list stemcells before uploading given stemcell, hence `bosh upload stemcell` CLI command requires users/clients to have `bosh.read` scope as well.

---
## Release uploader {: #release-uploader }

!!! note
    This feature is available with bosh-release v261.2+.

Scopes:

- `bosh.releases.upload`: user can upload new releases

Note that CLI will try to list releases before uploading given release, hence `bosh upload release` CLI command requires users/clients to have `bosh.read` scope as well.

---
## Errors {: #errors }

```
HTTP 401: Not authorized: '/deployments' requires one of the scopes: bosh.admin, bosh.UUID.admin, bosh.read, bosh.UUID.read
```

This error occurs if the user doesn't have the right scopes for the requested command.
