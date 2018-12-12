For the users using legacy SoftLayer CPI who want to move to SoftLayer CPI NG, please refer to this doc to do the migration.

**Note: SoftLayer CPI NG needs to work with Xenial stemcell. Please update to Xenial stemcell together with CPI NG.**

## Migrate bosh director

1. Use the following script to convert the director deploy manifest.

	```shell
	#!/bin/bash

	if [ $# -ne 1 ] || [ ! -f $1 ]
	then
	    echo "Usage: $0 director_yaml_file"
	    exit 1
	fi

	TARGET=$1

	cp  $TARGET $TARGET.origin
	echo "Original YAML file has been saved to $TARGET.origin"

	# cloud_properties
	sed -i 's/Domain:/domain:/g' $TARGET
	sed -i 's/VmNamePrefix:/hostname_prefix:/g' $TARGET
	sed -i 's/EphemeralDiskSize:/ephemeral_disk_size:/g' $TARGET
	sed -i 's/StartCpus:/cpu:/g' $TARGET
	sed -i 's/MaxMemory:/memory:/g' $TARGET
	sed -i 's/DeployedByBoshcli:/deployed_by_boshcli:/g' $TARGET
	sed -i ':a;$!{N;ba};s/Datacenter:.[ ]*Name:/datacenter:/g' $TARGET
	sed -i 's/HourlyBillingFlag:/hourly_billing_flag:/g' $TARGET
	sed -i ':a;$!{N;ba};s/PrimaryNetworkComponent:.[ ]*NetworkVlan:.[ ]*Id: /vlan_ids: [/g' $TARGET
	sed -i ':a;$!{N;ba};s/.[ ]*PrimaryBackendNetworkComponent:.[ ]*NetworkVlan:.[ ]*Id: /, /g' $TARGET
	sed -i 's/^.*vlan_ids.*/&]/' $TARGET
	sed -i 's/LocalDiskFlag:/local_disk_flag:/g' $TARGET    # need to add???
	sed -i ':a;$!{N;ba};s/NetworkComponents:.[ ]*- MaxSpeed:/max_network_speed:/g' $TARGET

	# cpi job properties
	sed -i 's/apiKey:/api_key:/g' $TARGET

	# remove featureOptions and update api_endpoint
	sed -i '/apiRetryCount:/d' $TARGET
	sed -i '/apiWaitTime:/d' $TARGET
	sed -i '/createIscsiVolumeTimeout:/d' $TARGET
	sed -i '/createIscsiVolumePollingInterval:/d' $TARGET
	sed -i '/apiEndpoint:/d' $TARGET
	sed -i 's/featureOptions:/api_endpoint: https:\/\/api.service.softlayer.com\/rest\/v3.1/g' $TARGET

	echo "$TARGET has been converted"
	```

2. Add registry job to director manifest

```yaml
    jobs:
    - name: bosh
      instances: 1
      templates:
      ...
      - name: registry
        release: bosh
      ...

      properties:
        ...
        postgres: &db
          ...
          additional_databases: [bosh_registry]
          ...
        registry: &registry
          db:
            adapter: postgres
            host: 127.0.0.1
            user: ((postgres_username))
            password: ((postgres_password))
            database: bosh_registry
          username: ((registry_username))
          password: ((registry_password))

    cloud_provider:
      ...
      properties:
        ...
        softlayer:
          api_key: ((api_key))
          ssh_public_key: ((ssh_public_key))
          ssh_public_key_fingerprint: ((ssh_public_key_fingerprint))
          username: ((username))
      ssh_tunnel:
        host: director-hostname.softlayer.com
        port: 22
        private_key: ((private_key))
        user: root
```

3. Move vlan info to network cloud_properties in director manifest

```yaml
networks:
- name: manual_network
  type: manual
  subnets:
  - range: 10.112.166.128/26
    gateway: 10.112.166.129
    azs: [z1, z2, z3]
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    reserved:
    - 10.112.166.128
    - 10.112.166.129
    - 10.112.166.130
    - 10.112.166.131
    static:
    - 10.112.166.132 - 10.112.166.162
    cloud_properties:
      vlan_ids: [524954, 524956]
- name: default      # Must define dynamic network in Softlayer
  type: dynamic
  subnets:
  - az: lon02
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    cloud_properties:
      vlan_ids: [524954, 524956]
```

4. Update the director manifest to use the latest [Softlayer CPI](https://bosh.io/releases/github.com/cloudfoundry/bosh-softlayer-cpi-release?all=1) and [Xenial stemcell](https://bosh.io/stemcells/bosh-softlayer-xen-ubuntu-xenial-go_agent)

5. Run `bosh create-env` command to upgrade bosh director with the new director manifest

## Convert cloud config

1. Download cloud config from bosh director

```bosh cloud-config >  cloud-config.yml```

2. Convert the cloud-config YAML file with the following script
	```shell
	#!/bin/bash

	if [ $# -ne 1 ] || [ ! -f $1 ]
	then
	    echo "Usage: $0 cloudconfig_yaml_file"
	    exit 1
	fi

	TARGET=$1

	cp  $TARGET $TARGET.origin
	echo "Original YAML file has been saved to $TARGET.origin"

	# azs cloud_properties
	sed -i ':a;$!{N;ba};s/Datacenter:.[ ]*Name:/datacenter:/g' $TARGET

	# networks cloud_properties
	sed -i ':a;$!{N;ba};s/PrimaryBackendNetworkComponent:.[ ]*NetworkVlan:.[ ]*Id: /vlan_ids: [/g' $TARGET
	sed -i ':a;$!{N;ba};s/.[ ]*PrimaryNetworkComponent:.[ ]*NetworkVlan:.[ ]*Id: /, /g' $TARGET
	sed -i 's/^.*vlan_ids.*/&]/' $TARGET

	# vm_types cloud_properties
	sed -i '/Bosh_ip:/d' $TARGET
	sed -i 's/EphemeralDiskSize:/ephemeral_disk_size:/g' $TARGET
	sed -i 's/HourlyBillingFlag:/hourly_billing_flag:/g' $TARGET
	sed -i 's/LocalDiskFlag:/local_disk_flag:/g' $TARGET
	sed -i 's/MaxMemory:/memory:/g' $TARGET
	sed -i 's/StartCpus:/cpu:/g' $TARGET
	sed -i 's/VmNamePrefix:/hostname_prefix:/g' $TARGET

	echo "$TARGET has been converted"
	```

3. Update cloud-config to bosh director

    ```bosh2 update-cloud-config cloud-config.yml```

## Upgrade deployments to Xenial stemcell

After bosh director is upgrade to Softlayer CPI NG, every bosh deployments need to be upgraded to [Xenial stemcell](https://bosh.io/stemcells/bosh-softlayer-xen-ubuntu-xenial-go_agent) before any other bosh deploy.
