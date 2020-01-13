During a deployment, BOSH tries to converge to the _intended_ state, _i.e._ the
state described in the deployment manifest, from the current state.

When an update is triggered using `bosh cck` or `bosh
<start|stop|restart|recreate>`, they can lead to different _intended_ states.

## bosh cck

`bosh cck` will always recreate the instance with the **current** deployed
instance state. This means that the desired instance plan is based on the
information that is encoded in the instances' **current** deployment spec that
is present in the database.

## bosh <start|stop|restart|recreate\>

`bosh <start|stop|restart|recreate>` will always converge the instance to the
last **successfully** deployed desired state. This means that the desired
instance plan is based on the information that is persisted in the last
**successfully** deployed manifest. These commands will also detect any changes
on other instances that conflict with the last deployed successful state, and
attempt to converge the deployment to the desired state.

### --no-converge flag

As of [BOSH
v270.4.0](https://github.com/cloudfoundry/bosh/releases/tag/v270.4.0) and [BOSH
CLI v6.0.0](https://github.com/cloudfoundry/bosh-cli/releases/tag/v6.0.0), the
`start`, `stop`, `restart`, and `recreate` commands all support a
`--no-converge` flag. When this flag is specified, the corresponding command
will act **ONLY** on the specified instance. The instance will based on the
**current** deployed instance state that is recorded in the database.
