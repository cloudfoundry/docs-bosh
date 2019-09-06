!!! note
    This feature is available with bosh-openstack-cpi v37+.

Software like `keepalived` can use the [Virtual Router Redundancy Protocol (VRRP)](https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol) for failover in a master-slave setup and keep the IP address exposed to clients stable. Just like any other bosh deployment, master and slave VMs each have their own IP address. However, there exists a third IP address which clients will use to talk to the respective master node. The `keepalived` agent ensures that this IP address is configured for the node currently selected as master.

In order for this to work, your OpenStack network needs to support VRRP and multicast. When creating a network port, OpenStack neutron allows to configure a secondary IP address that the port's MAC address can be associated with by using a property called [`allowed_address_pairs`](https://docs.openstack.org/api-ref/network/v2/#allowed-address-pairs).

The OpenStack CPI takes care of creating neutron ports for you, so you cannot set this property on a port yourself. Instead, you can use the OpenStack to set this property automatically:

* create a neutron port with the IP you want to expose to your clients. This will be the VRRP IP
* create a `vm_extension` in your `cloud-config` as follows
```
vm_extensions:
  - name: vrrp-ip
    cloud_properties:
      allowed_address_pairs: <VRRP IP>
```
* Use the `vm_extension` in your deployment manifest like this
```
instance_groups:
  - name: my-instance-group
    vm_extensions: [vrrp-ip]
```
* Co-locate the `keepalived` job of the `haproxy-boshrelease` and configure the VRRP IP as [`keepalived.ip`](https://bosh.io/jobs/keepalived?source=github.com/cloudfoundry-community/haproxy-boshrelease#p%3dkeepalived.vip)

When your master goes down, the VRRP IP will be attached to your slave and all clients don't need to be updated.