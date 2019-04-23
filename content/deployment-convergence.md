During deployment, bosh tries to converge to the _intended_ state, _i.e._ the state described in the deployment manifest, from the current state.

When a VM recreation is triggered by using `bosh cck` or `bosh restart`/`bosh recreate`, leads to different _intended_ states.

## bosh cck

`bosh cck` will always recreate the instance with the **current** deployed instance state. This means that the desired instance plan is based off of the information that is encoded in the instances' **current** deployment spec that is present in the database.

## bosh restart and bosh recreate

`bosh restart` and `bosh recreate` will always recreate the instance with the last **successfully** deployed desired state. This means that the desired instance plan is based off of the information that is persisted in the last **successfully** deployed manifest. These commands will also detect any changes on other instances that conflict with the last deployed successful state, and attempt to converge the deployment to the desired state.

