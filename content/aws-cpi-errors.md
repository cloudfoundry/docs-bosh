## Incorrect Region

>     Stemcell does not contain an AMI for this region (us-west-2c)

Make sure that your [`region`](aws-cpi.md#options-region) is one of the [official AWS regions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-regions). AWS regions typically end with a number, so in the example above region is erroneously specified (it's set to an AZ since each region is divided into multiple AZ which end with a letter.)


## Elastic IP Requires an Internet Gateway

>     Network vpc-a09e18c5 is not attached to any internet gateway

You need to create and attach an internet gateway to your VPC so that VMs can connect to the Internet.


## Incorrect Subnet

>     The subnet ID 'subnet-c3051fad' does not exist

Make sure that the [`region`](aws-cpi.md#options-region) matches the region where your specified subnet resides.


## Incorrect System Time

>     Signature expired: 20141106T010406Z is now earlier than 20141106T011252Z (20141106T011752Z - 5 min.)

This error is usually caused by out-of-sync system time. Use `ntpdate` to sync the clock on the machine where BOSH CLI is run: `sudo ntpdate pool.ntp.org`. Alternatively make sure that `ntpd` is correctly configured and running.


## Multiple VMs Using an Elastic IP

>     resource eipalloc-6a45950f is already associated with associate-id eipassoc-427beb26

This error indicates that elastic IP specified in the manifest to be associated to the VM is in use by another VM. Check AWS console and decide whether other VM should be deleted to make elastic IP available for use.


## Missing Subnet

>     Specifying an IP address is only valid for VPC instances and thus requires a subnet in which to launch

Make sure that each manual network subnet has `cloud_properties` key and its contents include `subnet` key with the AWS Subnet ID. (You may have accidentally specified `cloud_properties` on the network itself.)


## Incorrect Arguments

>     Arguments are not correct

This error may be raised when:

* `instance_type` is missing from the compilation or one of the resource pools' `cloud_properties` section
* the deployment job instance is not assigned a static IP


## Address is In Use

>     Address 10.10.16.251 is in use.

This error indicates that unknown VM took up the IP that the Director is trying to assign to a new VM. Either let the Director know to not use this IP by including it in the reserved section of a subnet in your manual network, or make that IP available by terminating the unknown VM.


## Consistent Security Groups

>     When specifying a security group you must specify a group id for each item.

Make sure all security groups in the CPI configuration and networks' `cloud_properties` sections are specified in the same format, as IDs (e.g. `sg-384fher`) or names (e.g. `cf-public`).


## Insufficient IAM Permissions

>     You are not authorized to perform this operation. Encoded authorization failure message: vHU-KncL6Yo4pG5J9p...

See [IAM instance profiles errors](aws-iam-instance-profiles.md#errors).


## Unsupported Instance Type Virtualization

>     Non-Windows instances with a virtualization type of 'hvm' are currently not supported for this instance type.

You cannot use HVM stemcells with certain instance types. Review which instance type is specified in a referenced resource pool.


## API Throttling

>     AWS::EC2::Errors::RequestLimitExceeded Request limit exceeded.

AWS API is throttling the number of request in your account. You can reduce the number of threads running in BOSH, or increase the value of `aws.max_retries` to let the AWS client library perform retries in a exponential backoff. Note that the more retries, the longer will take to fail.
