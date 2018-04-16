---
title: Recovery from a vSphere Network Partitioning Fault
---

!!! warning
    Do not follow this procedure if vSphere HA is enabled and bosh-vsphere-cpi is v30+; vSphere HA will automatically recreate VMs that were on the partitioned host.

This topic describes how to recreate VMs in the event of a network partition
that disrupts the following:

* the vCenter's ability to communicate with an ESXi host
* the BOSH Director's ability to communicate with the VMs on that host.

There are two options.

1. Power down the ESXi host. Follow the instructions to
[recover from an ESXi host failure](vsphere-esxi-host-failure.md) to recover
your BOSH deployment.

2. If you cannot power down your ESXi host, then you must shut down the VMs
running on the partitioned ESXi host:
  - Determine which VMs are affected by using the `bosh vms --details`;
     the output should resemble the following:

    ```
    +------------------------------------------------+--------------------+----+---------+-------------+-----------------------------------------+--------------------------------------+--------------+--------+
    | VM                                             | State              | AZ | VM Type | IPs         | CID                                     | Agent ID                             | Resurrection | Ignore |
    +------------------------------------------------+--------------------+----+---------+-------------+-----------------------------------------+--------------------------------------+--------------+--------+
    | dummy/0 (4f9b0722-d004-43a6-b258-adf5e2cc5c70) | running            | z1 | default | 10.85.57.7  | vm-073648a9-57da-4122-953b-5ccf5b74c563 | 98ee24dd-c7e5-4f4b-8e6f-4f3dfa4cb5b1 | active       | false  |
    | dummy/1 (df4732aa-9f4b-4635-aedb-54278b3fac31) | running            | z1 | default | 10.85.57.11 | vm-debbd710-8829-4484-9098-78a4410ed3cc | 4f3491bd-3ab8-4fa7-9930-cf0ec0a56fec | active       | false  |
    | dummy/2 (56957582-ca58-418d-a7e6-ea0151010302) | unresponsive agent | z1 | default |             | vm-c2d2a8ac-7afb-4875-9cf3-d69978c9e8c3 | d38569a5-389a-4de6-95a8-0790e8e5ede4 | active       | false  |
    | dummy/3 (60e0b351-6524-4f45-af12-953a47af5a29) | running            | z1 | default | 10.85.57.10 | vm-bf3bbeaf-3506-4fe1-9e7e-76e2c26ce5d8 | f98c9763-6518-4305-8f16-b451a36d1b91 | active       | false  |
    | dummy/4 (473a2bf2-7147-41d5-805a-532f27c6f833) | unresponsive agent | z1 | default |             | vm-2c520edb-9202-499f-a079-b3468633bd37 | 43ff0019-2af1-4c87-944b-76aa06f97b83 | active       | false  |
    +------------------------------------------------+--------------------+----+---------+-------------+-----------------------------------------+--------------------------------------+--------------+--------+
    ```
  - Connect to the partitioned ESXi host, and using the `CID` from the
  previous command find the Vmids of the VMs using the `CID` from the previous command,
    e.g.

    ```
    esxcli vm process list | grep -A 1 ^vm-c2d2a8ac-7afb-4875-9cf3-d69978c9e8c3
    esxcli vm process list | grep -A 1 ^vm-2c520edb-9202-499f-a079-b3468633bd37
    # We see that the WorldNumbers (World IDs) are 199401 &amp; 199751, respectively
    esxcli vm process kill --type=force --world-id=199401
    esxcli vm process kill --type=force --world-id=199751
    ```
  - Follow the instructions [Recover from an ESXi host failure](vsphere-esxi-host-failure.md).
