---
title: UAA Permissions
---

All UAA users can log into all Directors which can verify the access token. However, user actions will be limited based on the presence of the following scopes in their UAA token:

<p class="note">Warning: If you use the same private key to sign keys on different UAAs, users might obtain a token from one UAA and use it on the Director configured with a different UAA. It is therefore highly recommended to lock down scopes to individual Directors and not re-use your private key used for signing on the UAA.</p>

## <a id="anon"></a> Anonymous

Can access:

- `bosh status`: show general information about targeted Director (authentication is not required)

---
## <a id="full-admin"></a> Full Admin

Scopes:

- `bosh.admin`: user has admin access on any Director
- `bosh.<DIRECTOR-UUID>.admin`: user has admin access on the Director with the corresponding UUID

Can use all commands on all deployments.

---
## <a id="full-read"></a> Full Read-only

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
## <a id="team-admin"></a> Team Admin

<p class="note">Note: This feature is available with bosh-release v255.4+.</p>

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
## <a id="errors"></a> Errors

```
HTTP 401: Not authorized: '/deployments' requires one of the scopes: bosh.admin, bosh.UUID.admin, bosh.read, bosh.UUID.read
```

This error occurs if the user doesn't have the right scopes for the requested command.

---
[Back to Table of Contents](index.html#director-config)
