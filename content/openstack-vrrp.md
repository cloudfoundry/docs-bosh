!!! note
    This feature is available with bosh-openstack-cpi v37+.

Software like `keepalived` can use the [Virtual Router Redundancy Protocol (VRRP)](https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol) for failover in a master-slave setup and keep the IP address exposed to clients stable. Just like any other bosh deployment, master and slave VMs each have their own IP address. However, there exists a third "Virtual" IP address which clients will use to talk to the respective master node (called "VRRP IP" in the remaining part of this page, and corresponds to the "Virtual Router" IP in VRRP specs). The `keepalived` agent (e.g. provided by [cloudfoundry-community/haproxy-boshrelease](https://bosh.io/jobs/keepalived?source=github.com/cloudfoundry-community/haproxy-boshrelease)) installed on both master and slave VMs, uses the VRRP protocol to coordinate the two VMs, and ensures that the VRRP IP address is configured for the node currently selected as master.

In order for this to work, your OpenStack network needs to support VRRP and multicast. When creating a VM's network port, OpenStack neutron supports associating a secondary IP address with that the port's MAC address by using a property called [allowed_address_pairs](https://docs.openstack.org/api-ref/network/v2/#allowed-address-pairs) on the port object.

As the OpenStack CPI takes care of dynamically creating neutron ports attached to bosh vms for you, you cannot set this property yourself. Instead, you tell the OpenStack CPI to set this `allowed_address_pairs` property automatically on bosh vms's ports, using a `vm_extension`.

The following paragraph describes the steps to set up VRRP using the openstack cpi: 

* create a neutron port with the VRRP IP you want to expose to your clients. Neutron will not instantiate this port, it's rather a way to “reserve” the IP address that will later be allowed on the bosh VM ports. Following is a sample terraform script for automating such port creation. 
```
 resource "openstack_networking_port_v2" "vrrp_port" { 
   name       = "my_cluster_virtual_ip_port" 
   network_id = openstack_networking_network_v2.my_net.id 
   fixed_ip { 
     subnet_id = openstack_networking_subnet_v2.my_subnet.id
     ip_address = "x.x.x.x" #The VRRP IP 
   } 
   admin_state_up = "true" 
```
* create a `vm_extension` in your `cloud-config` as follows
```
vm_extensions:
  - name: vrrp-ip
    cloud_properties:
      allowed_address_pairs: <VRRP IP>
```
* Use the `vm_extension` in your deployment manifest like this, to select the instance groups on which it will apply. To ensure consistency and fail fast, the Openstack CPI will check the presence of the openstack port matching the VRRP IP. Also, all vms in this instance group will have their ports configured with the `allowed_address_pairs` property set to the VRRP IP and their mac address, actually asking openstack to allow the VM to send/receive traffic on this IP address.
```
instance_groups:
  - name: my-instance-group
    vm_extensions: [vrrp-ip]
```
* Co-locate the `keepalived` job of the `haproxy-boshrelease` and configure the VRRP IP as [`keepalived.ip`](https://bosh.io/jobs/keepalived?source=github.com/cloudfoundry-community/haproxy-boshrelease#p%3dkeepalived.vip)

When your master vm goes down, the VRRP IP will be attached to your slave vm and all clients don't need to be updated, they keep communicating to the VRRP IP.
