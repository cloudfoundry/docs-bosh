# BOSH Disaster Recovery Process for AZ Outages

In it's current state, BOSH, not being a highly available service, does not support a multi-AZ deployment. This means that in the event of an AZ outage, it is not directly possible to fallback to another replica instance for example.
This has not always been necessary since BOSH is a deploytime-relevant service, and has less relevance during runtime. This, however, does not mean that large productive environments depending on BOSH for their deployments could do without BOSH in scenarios where AZ outages extend over longer time periods, since, for instance, relevant fixes and security updates should still be delivered in time.

However, it is possible that we externalize the state to the best possible extent to highly available infrastructure offerings, and fallback to another AZ in case of an AZ outage. This can be achieved if certain prerequisites are fulfilled.

## Prerequisites:

### 1. Using domain names
When an AZ outage happens, and we switch to a new director, it is important that BOSH's deployments are still able to reach the new director in the other AZ. The first step to make this posible is to use domain names for the director instead of IPs. This, however, does come with a challenge of updating the the certificates used by BOSH with alternative names (IPs being used to connect to the director and new hostname configured) for hostname validation.
### 2. Externalizing the database
BOSH should still be aware of its deployments, their instances, blob references etc. in the event of its redeployment to another AZ. This could be made possible by using an external database instead of the default colocated configuration. This can be done by consuming highly available RDS services by IaaS providers, and then configuring the director database properties and the UAA database properties to consume these external database instances. See [director db configuration](https://bosh.io/docs/director-configure-db) and [uaa configuration](https://bosh.io/docs/director-users-uaa) for further help in this regard.
### 3. Externalizing the blobstore
It would also make sense to use an external blobstore like AWS S3 which is highly available than consuming blobs from the colocated DAV blobstore. This would help to fail over to a new director with less worries of re-fetching the blobs (keeping in mind this is a time consuming process) when the need arises. As of now, it is already possible to use highly available blobstores provided by AWS, Azure, AliCloud and GCP. Switching over to a new blobstore can be smooth if there's a blobstore migration mechanism implemented using the existing BOSH Blobstore CLIs (by simply 'putting' the blobs using the s3cli from the director VM to the S3 bucket for example in case of AWS). Another way of doing this would be to recreate the blobstore externally by uploading the blobs with [--fix](https://bosh.io/docs/cli-v2/#upload-release) or running the deploy commands with [--fix-releases](https://bosh.io/docs/cli-v2/#deploy). This however is costly in terms of time required to re-fetch the blobs.
See [this](https://bosh.io/docs/director-configure-blobstore) to start configuring the director to use an external blobstore.

## Steps for recovering a bosh director in the event of an AZ outage:

### 1. Isolating the director
To isolate the director in `zone_1` from the database to prevent it from modifying the state when the zone is up, it is important that:\
a. The database passwords via terraform are rotated\
b. All existing database connections are killed via psql
### 2. Deploying another director
There might be differences in deploying BOSH directors in another AZ based on whether we use the `create-env` approach or the `bosh deploy` approach.

After isolating the director deployed by `create-env` in `zone_1` the process to deploy a second one in `zone_2` can be treated similar to a scratch installation. That means that the zone used in the director's deployment manifest to is changed to `zone_2` and the `bosh-state.json` is dropped before calling [create-env](https://bosh.io/docs/cli-v2/#create-env) and setting up the second director in `zone_2`.

For directors deployed by `bosh deploy`, the deployment manifest should be updated the used zone in the manifest should be set to `zone_2`. Next,the number of [instances](https://bosh.io/docs/manifest-v2/#instance-groups) in the `instance_group` has to be increased to 2 and a second static ip (available in `zone_2`) should be configured.

However, while redeploying thi director with the updated manifest, the director which this drector is the deployment of would
first try to delete the old `bosh` in `zone_1`. This will most probably fail in case of a zone outage. This can be prevented by invoking [ignore](https://bosh.io/docs/cli-v2/#ignore) on the deployed `bosh`
in `zone_1`.
### 3. Disabling resurrection
After `bosh` is successfully deployed in `zone_2` it will now take care for repairing its deployments. Most of them would
be in error situation since they would have instances in the failing zone. The director would continuously trigger `scan_and_fix`
tasks which would then also fail. 
Therefore, an option would be to deploy the new directors with with disabled resurrection with other monitoring techniques in place.
After the zone outage is over, the directors in `zone_1` can be dropped and the ones in `zone_2` can be used further.
Of course with enabled resurrection.


[>Here<](https://www.youtube.com/watch?v=0oMrGu9XuBY&list=PLhuMOCWn4P9jUHBucZBkSjmkwEbvx8vxf&index=12) is a video presentation on the topic from the 2023 CF Day at Heidelberg.
