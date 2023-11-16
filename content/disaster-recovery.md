# BOSH Disasters Recovery Process for AZ Outages

[>Video-Presentation on the CF Day Heidelberg<](https://www.youtube.com/watch?v=0oMrGu9XuBY&list=PLhuMOCWn4P9jUHBucZBkSjmkwEbvx8vxf&index=12)

Over the past months we invested a lot into a disaster recovery process, for our BOSH instances, that can be followed when
a whole AWS Availability Zone is in an outage situation. As the BOSH director itself does not support a multi AZ setup
it's a bit tricky to plug such a process from the outside into the director.

Since BOSH is not relevant for the runtime, we don't expect that this process is to be executed if a zone is down for few minutes/hours.
However after a while we most probably need to be able to deploy fixes for the existing BOSH deployments,
and it would make sense to share the ideas with the community.

In general, we deploy multiple BOSH directors per cloud. For simplicity, we assume two directors here. One of these
directors (we name it `bootstrap-bosh`) is deployed via the [create_env](https://bosh.io/docs/cli-v2/#create-env) command.
Its purpose is to deploy the second director (we name it `bosh`) instance, which is then used to deploy CF and other
services. All our directors are deployed to `zone_1` by default.

Our simple attempt in case of a zone outage is to deploy substitute `bootstrap-bosh` and `bosh` directors into one of the
still available zones (let's assume `zone_2`).

## Using domain names

The very fist step in our journey to deploy a bosh director in another AZ was to use domain names instead of static IPs.
Domain names would allow clients to use a static URL which is independent of the AZ. However, there were a few interesting scenarios
we stumbled upon. These scenarios included updating certificates with DNS names along with thinking about the actual switch with
which we would stop using static IPs and use URLs instead.

## State externalisation

Very early we decided to externalize as much state as possible before even thinking about a disaster recovery process.
This required us to run the director on top of an external database (for example AWS RDS) and an external blobstore (for example AWS S3).

- AWS RDS is replacing the Postgres database which is co-located on the director host by default.
- AWS S3 is replacing the Nginx based blobstore which is as well co-located on the director host.

Additionally, we decided that we don't care about the task logs that are stored on the persistent disk of the director
host, instead we accept to lose such logs in case of an Availability Zone Outage.

As we already use AWS RDS instances for all our relevant AWS Cloud installations, we just needed to start using an external blobstore.
There are two options normally, either we accept to recreate our blobstore while switching to the external blobstore and bear with the longer blobstore
recreation times and therefore longer duration for various bosh deployments for our production environments, or first migrate the blobs
we have co-located on the director to S3 and then switch to using the external blobstore without recreating it.

The first way is easy to implement, but costly with respect to the time it takes. It can easily be done by deploying 
all bosh deployments with a "--fix-releases" flag. Though there's a risk of losing the DNS records stored
locally as a blob within the director.

We chose to implement the required blob migration from local Nginx blobstore to S3. In combination with the usage of
signed URLs, doing the migration was tricky since one has to add the AWS Root CAs to the agent's blobstore
CAs so that the agent can communicate during the migration with the local blobstore and S3 both at once.

## Director isolation

Since we want to install a second director to `zone_2`, we have to prevent being in a situation where this
second director starts accessing the external database instance in parallel to the BOSH director in `zone_1`. Therefore, we have to lock
the first director from the database before the second director can be deployed and use it.

Otherwise, any kind of database inconsistencies can happen since you never know the status of the director in `zone_1`.
It could be e.g. still working but not be accessible from the outside anymore. Such kind of "partial" AZ outages have
already been experienced in the past.

To isolate the director in `zone_1` from the database we:
a) Auto-rotate the database passwords via terraform
b) Kill all existing database connections via psql

## Deploying a second bootstrap-bosh director

After isolating `bootstrap-bosh` in `zone_1` the process to deploy a second one in `zone_2` is very straight forward
since we treat it similar to a scratch installation. That means that we update the used zone in the `bootstrap-bosh`
deployment manifest to `zone_2` and drop the `bosh-state.json`. Afterwards we simply invoke
[create_env](https://bosh.io/docs/cli-v2/#create-env) and set up the second `bootstrap-bosh` director in `zone_2`.

## Deploying a second bosh director

After isolating `bosh` in `zone_1` and installing the second `bootstrap-bosh` in `zone-2`, we continue to set up a second
`bosh` in `zone-2`. That's a bit more tricky than the `bootstrap-bosh` setup, since we don't want to use the scratch
installation approach, as we would lose all deployment information about the deployed services in such a scenario.

Therefore, we update the deployment manifest of `bosh` and set the used zone in the to `zone_2`. Next we increase the
number of instances in the `instance_group` to 2 and configure a second static ip (available in `zone_2`) for `bosh`.

If we would now deploy the second `bosh` with the updated manifest via `bootstrap-bosh`, then `bootstrap-bosh` would
first try to delete the old `bosh` in `zone_1`. This will most probably fail in case of a zone outage. Therefore,
we prevent this deletion attempt by invoking [ignore](https://bosh.io/docs/cli-v2/#ignore) on the deployed `bosh`
in `zone_1`. Only afterwards we do run the `bosh` deployment.

## Disabling the resurrection

After `bosh` is successfully deployed in `zone_2` it will now take care for repairing its deployments. Most of them will
be in error situation since they do have instances in the failing zone. So BOSH will continuously trigger `scan_and_fix`
tasks which will then also fail. Another option would be that affected deployments end up in `meltdown` state
(depending on the deployment configuration).
Therefore, we decided to deploy the second `bootstrap-bosh` and `bosh` with disabled resurrection, since we anyhow expect
very high monitoring and operational efforts in case of an availability zone outage.

## After the outage

After the zone outage is over, we will simply drop the directors in `zone_1` and continue to use the ones in `zone_2`.
Of course with enabled resurrection.