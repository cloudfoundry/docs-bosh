## Incorrect KeyPair

>     SDK.ServerError
>     ErrorCode: InvalidKeyPairName.NotFound
>     Message: The specified parameter \"KeyPairName\" does not exist in our records

Make sure that your key_pair_name is correct and it is in the current region.


## Incorrect Private IP

>     SDK.ServerError
>     ErrorCode: InvalidPrivateIpAddress.Duplicated
>     Message: Specified private IP address is duplicated.

Your internal_ip has been used by other vm, and you can delete the vm or specify a new internal_ip.
