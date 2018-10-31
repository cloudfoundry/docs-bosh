BOSH Teams map to UAA scopes that restrict the set of deployments that a
user can manage. A user's or client's membership in a BOSH team is
determined by the scopes assigned to their UAA client.
When a user creates a deployment, that deployment
will be manageable by any user belonging to the same team. There is
currently no way to assign or reassign a deployment's teams.

!!! note
    This feature is available with bosh-release v255.4+.

## Add a client to a BOSH Team

Scopes can be added to existing clients in order to associate the
clients with BOSH Teams. You must be logged into UAA as [a privileged
user to grant and revoke scopes](director-users-uaa-scopes.md#user-login). All BOSH Team scopes follow the format:

```
bosh.teams.<TEAM-NAME>.<SCOPE>
```

To add a BOSH Team scope to an existing client:

```
uaac client update <CLIENT-ID> --scope bosh.teams.<TEAM-NAME>.admin
```

Currently, Team Admin is the only team-level scope.

## Team Admin {: #team-admin }

Scopes:

- `bosh.teams.<TEAM_NAME>.admin`: user has admin access for deployments managed by the team

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

Team admins cannot upload releases and stemcells. These are
[director-wide scopes](director-users-uaa-scopes.md#director-wide-scopes).
