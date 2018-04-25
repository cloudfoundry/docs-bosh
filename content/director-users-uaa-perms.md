All UAA users can log into all Directors which can verify the access token. However, user actions will be limited based on the presence of the following scopes in their UAA token:

!!! warning
    If you use the same private key to sign keys on different UAAs, users might obtain a token from one UAA and use it on the Director configured with a different UAA. It is therefore highly recommended to lock down scopes to individual Directors and not re-use your private key used for signing on the UAA.

## Anonymous {: #anon }

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
## Team Admin {: #team-admin }

!!! note
    This feature is available with bosh-release v255.4+.

The Director has a concept of a team so that set of users can only manage specific deployments. When a user creates a deployment, created deployment will be *managed* by the teams that that user is part of. There is currently no way to assign or reassign deployment's teams.

Scopes:

- `bosh.teams.<team>.admin`: user has admin access for deployments managed by the team

Can modify team managed deployments' associated resources:

- `bosh deploy`: create or update deployment
- `bosh delete deployment`: delete deployment
- `bosh start/stop/recreate`: manage VMs
- `bosh cck`: diagnose deployment problems
- `bosh ssh`: SSH into a VM
- `bosh logs`: fetch logs from a VM
- `bosh run errand`: run an errand

Can view shared resources:

- `bosh deployments`: list of team managed deployments and releases/stemcells used
- `bosh releases`: list of *all* releases and their versions
- `bosh stemcells`: list of *all* stemcells and their versions
- `bosh vms`: list of team managed deployments' VMs which includes job names, IPs, vitals, details, etc.
- `bosh tasks`: list of team managed deployments' tasks and their full details

Team admin cannot upload releases and stemcells.

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
