---
title: Events
---

!!! note
    This feature is available in bosh-release v256+.

In addition to keeping a historical list of [Director tasks](terminology.md#director-task) for debugging history, the Director keeps detailed list of actions user and system took during its operation. Events are recorded into the Director database.

Currently following events are recorded:

- cloud config update
- runtime config update
- deployment create/update/delete
- VM create/delete
- disk create/delete
- `bosh ssh` events

Run [`bosh events` command](sysadmin-commands.md#events) to view 200 recent events:

```shell
$ bosh events

+--------------+------------------------------+-------+-------------+-------------+------------------------------------------------+------+-----------+------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| ID           | Time                         | User  | Action      | Object type | Object ID                                      | Task | Dep       | Inst                                           | Context                                                                                                                                            |
+--------------+------------------------------+-------+-------------+-------------+------------------------------------------------+------+-----------+------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| 5223         | Thu May 12 23:49:41 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1084 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_d05e94d02fd049c0                                                                                                                        |
| 5222         | Thu May 12 23:49:38 UTC 2016 | admin | cleanup ssh | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1083 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: ^bosh_87ad9a84d61c4e57                                                                                                                       |
| 5221         | Thu May 12 23:49:16 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1082 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_87ad9a84d61c4e57                                                                                                                        |
| 5220         | Thu May 12 23:46:26 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1081 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_41c768618e734a72                                                                                                                        |
| 5219 <- 5216 | Thu May 12 23:43:34 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1079 | slow-nats | -                                              | before: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}, |
|              |                              |       |             |             |                                                |      |           |                                                | after: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}   |
| 5218 <- 5217 | Thu May 12 23:43:34 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1079 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | -                                                                                                                                                  |
| 5217         | Thu May 12 23:42:52 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1079 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | az: z3,                                                                                                                                            |
|              |                              |       |             |             |                                                |      |           |                                                | changes: ["configuration", "job"]                                                                                                                  |
| 5216         | Thu May 12 23:42:51 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1079 | slow-nats | -                                              | -                                                                                                                                                  |
| 5215         | Thu May 12 21:43:14 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1076 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_e54b9915d292428e                                                                                                                        |
| 5214 <- 5211 | Thu May 12 20:53:11 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1074 | slow-nats | -                                              | before: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}, |
|              |                              |       |             |             |                                                |      |           |                                                | after: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}   |
| 5213 <- 5212 | Thu May 12 20:53:11 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1074 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | -                                                                                                                                                  |
| 5212         | Thu May 12 20:51:35 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1074 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | az: z3,                                                                                                                                            |
|              |                              |       |             |             |                                                |      |           |                                                | changes: ["configuration", "job"]                                                                                                                  |
| 5211         | Thu May 12 20:51:34 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1074 | slow-nats | -                                              | -                                                                                                                                                  |
| 5210         | Thu May 12 20:35:52 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1073 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_c5d3b51c29f14e03                                                                                                                        |
| 5209         | Thu May 12 20:34:53 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1072 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_3a86d5bfbdec4fba                                                                                                                        |
| 5208 <- 5205 | Thu May 12 20:32:20 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1068 | slow-nats | -                                              | before: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}, |
|              |                              |       |             |             |                                                |      |           |                                                | after: {"releases"=>["os-conf/5", "syslog/5", "bosh/256.2", "bosh-aws-cpi/44"], "stemcells"=>["bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3232.2"]}   |
| 5207 <- 5206 | Thu May 12 20:32:20 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1068 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | -                                                                                                                                                  |
| 5206         | Thu May 12 20:24:20 UTC 2016 | admin | update      | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1068 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | az: z3,                                                                                                                                            |
|              |                              |       |             |             |                                                |      |           |                                                | changes: ["dirty", "configuration", "state"]                                                                                                       |
| 5205         | Thu May 12 20:24:18 UTC 2016 | admin | update      | deployment  | slow-nats                                      | 1068 | slow-nats | -                                              | -                                                                                                                                                  |
| 5204         | Thu May 12 20:19:24 UTC 2016 | admin | cleanup ssh | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1067 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: ^bosh_59b01a03f3574812                                                                                                                       |
| 5203         | Thu May 12 20:19:18 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1066 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_59b01a03f3574812                                                                                                                        |
| 5202         | Thu May 12 20:17:47 UTC 2016 | admin | setup ssh   | instance    | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | 1064 | slow-nats | bosh/54fc51cb-32b9-41f6-9d16-538e4fed1ef0      | user: bosh_de1f9ba9ab444b6d                                                                                                                        |
| 5201 <- 5002 | Thu May 12 00:47:48 UTC 2016 | admin | delete      | deployment  | tiny                                           | 1059 | tiny      | -                                              | -                                                                                                                                                  |
| 5200 <- 5095 | Thu May 12 00:47:48 UTC 2016 | admin | delete      | instance    | zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc | 1059 | tiny      | zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc | -                                                                                                                                                  |
| 5199 <- 5096 | Thu May 12 00:47:48 UTC 2016 | admin | delete      | vm          | i-054a17a75c0c9b279                            | 1059 | tiny      | zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc | -                                                                                                                                                  |
| 5198 <- 5179 | Thu May 12 00:47:23 UTC 2016 | admin | delete      | instance    | zookeeper/c7741d2b-4f47-4e82-bf44-5226044da9a3 | 1059 | tiny      | zookeeper/c7741d2b-4f47-4e82-bf44-5226044da9a3 | -                                                                                                                                                  |
| 5197 <- 5180 | Thu May 12 00:47:23 UTC 2016 | admin | delete      | vm          | i-0609fb01d24bc9a31                            | 1059 | tiny      | zookeeper/c7741d2b-4f47-4e82-bf44-5226044da9a3 | -                                                                                                                                                  |
| 5196 <- 5175 | Thu May 12 00:47:22 UTC 2016 | admin | delete      | instance    | zookeeper/01f97065-6757-4c59-85e7-404c2e8418e9 | 1059 | tiny      | zookeeper/01f97065-6757-4c59-85e7-404c2e8418e9 | -                                                                                                                                                  |
| 5195 <- 5176 | Thu May 12 00:47:22 UTC 2016 | admin | delete      | vm          | i-0c9e15d1577a50d3a                            | 1059 | tiny      | zookeeper/01f97065-6757-4c59-85e7-404c2e8418e9 | -                                                                                                                                                  |
| 5194 <- 5167 | Thu May 12 00:47:16 UTC 2016 | admin | delete      | instance    | zookeeper/32b9aa25-0080-4a66-865a-777577e1727c | 1059 | tiny      | zookeeper/32b9aa25-0080-4a66-865a-777577e1727c | -                                                                                                                                                  |
| 5193 <- 5168 | Thu May 12 00:47:16 UTC 2016 | admin | delete      | vm          | i-04eccec6f844e862e                            | 1059 | tiny      | zookeeper/32b9aa25-0080-4a66-865a-777577e1727c | -

...
```

List of events can be also filtered by a deployment name (`--deployment`), a task ID (`--task`), and/or an instance (`--instance`). Additionally you can paginate by specifying `--before-id` flag to view next 200 events matching viewed criteria. In an upcoming release we will also include filtering based on an event timestamp to quickly identify events happened during specific timeframe.

Example query commands:

```shell
$ bosh events --deployment slow-nats
$ bosh events --deployment slow-nats --before-id 5208
$ bosh events --instance zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc
```

---
## Ending vs. Single Actions {: #ending-vs-single }

Each event represents an action. Some actions take time to perform (e.g. delete a VM), and other actions are just one-off events (e.g. set up SSH access). Actions that take time are represented by two events (starting and ending one) instead of just one. In the example below delete VM action is recorded as starting in event #5096 and finishing in event #5199.

```shell
| 5199 <- 5096 | Thu May 12 00:47:48 UTC 2016 | admin | delete | vm | i-054a17a75c0c9b279 | 1059 | tiny | zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc ...
| 5096         | Thu May 12 00:40:44 UTC 2016 | admin | delete | vm | i-054a17a75c0c9b279 | 1059 | tiny | zookeeper/ca5f695a-eb81-49fd-a577-33825cb1b5fc ...
```

---
## Enabling Event Collection {: #enable }

To enable this feature:

1. Add [director.events.record_events](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.events.record_events) deployment manifest for the Director:

    ```yaml
    properties:
      director:
        events:
          record_events: true
    ```

1. Optionally change frequency and number of events to keep.

1. Redeploy the Director.
