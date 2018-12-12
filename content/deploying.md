Once referenced stemcells and releases are uploaded to the Director and the deployment manifest is complete, Director can successfull make a deployment. The CLI has a single command to create and update a deployment: [`bosh deploy` command](cli-v2.md#deploy). From the perspective of the Director same steps are taken to create or update a deployment.

To create a Zookeeper deployment from `zookeeper.yml` deployment manifest run the deploy command:

```shell
bosh -e vbox -d zookeeper deploy zookeeper.yml
```

Should result in:

```text
Using environment '192.168.56.6' as '?'

Task 1133

08:41:15 | Preparing deployment: Preparing deployment (00:00:00)
08:41:15 | Preparing package compilation: Finding packages to compile (00:00:00)
08:41:15 | Creating missing vms: zookeeper/6b7a51c4-1aeb-4cea-a2da-fdac3044bdee (1) (00:00:10)
08:41:25 | Updating instance zookeeper: zookeeper/3f9980b4-d02f-4754-bb53-0d1458e447ac (0) (canary) (00:00:27)
08:41:52 | Updating instance zookeeper: zookeeper/b8b577e7-d745-4d06-b2b7-c7cdeb46c78f (4) (canary) (00:00:25)
08:42:17 | Updating instance zookeeper: zookeeper/5a901538-be10-4d53-a3e9-3e23d3e3a07a (3) (00:00:25)
08:42:42 | Updating instance zookeeper: zookeeper/c5a3f7e6-4311-43ac-8500-a2337ca3e8a7 (2) (00:00:26)
08:43:08 | Updating instance zookeeper: zookeeper/6b7a51c4-1aeb-4cea-a2da-fdac3044bdee (1) (00:00:39)

Started  Mon Jul 24 08:41:15 UTC 2017
Finished Mon Jul 24 08:43:47 UTC 2017
Duration 00:02:32

Task 1133 done

Succeeded
```

After the deploy command completes with either success or failure you can run a command to list VMs created for this deployment:

```shell
bosh -e vbox -d zookeeper instances
```

Should result in:

```text
Using environment '192.168.56.6' as '?'

Deployment 'zookeeper'

Instance                                          Process State  AZ  IPs
smoke-tests/42e003c1-1c05-453e-a946-c2e77935cff0  -              z1  -
zookeeper/3f9980b4-d02f-4754-bb53-0d1458e447ac    running        z2  10.244.0.2
zookeeper/5a901538-be10-4d53-a3e9-3e23d3e3a07a    -              z1  10.244.0.3
zookeeper/6b7a51c4-1aeb-4cea-a2da-fdac3044bdee    running        z3  10.244.0.6
zookeeper/b8b577e7-d745-4d06-b2b7-c7cdeb46c78f    running        z2  10.244.0.4
zookeeper/c5a3f7e6-4311-43ac-8500-a2337ca3e8a7    -              z1  10.244.0.5

6 instances

Succeeded
```
