## Invalid Service Principal

>     http_get_response - get_token - http error: 400

Service principal is most likely invalid. Verify that client ID, client secret and tenant ID successfully work:

```shell
azure login --username client-id --password client-secret --service-principal --tenant tenant-id
```

If your service principal worked and you get the above error suddenly, it may be caused by that your service principal expired. You need to go to Azure Portal to update client secret. By default, the service principal will expire in one year.

1. Go to [Azure Portal](https://manage.windowsazure.com/), select `active directory` -- > ORGANIZATION-NAME -- > `Applications` -- > search your service principal name.

2. Then choose your service principal, select `Configure` -- > `keys` -- > add a new key.


## Exceeding quota limits of Core

>     http_put - error: 409 message: {
>       "error": {
>         "code": "OperationNotAllowed",
>         "message": "Operation results in exceeding quota limits of Core. Maximum allowed: 4, Current in use: 4, Additional requested: 1."
>       }
>     }

Either upgrade your trial account, or file a support ticket in the Azure portal to raise account quotas.


## Network Interface In Use

>     http_delete - error: 400 message: {
>       "error": {
>         "code": "NicInUse",
>         "message": "Network Interface /.../networkInterfaces/dc0d3a9a-0b00-40d8-830d-41e6f4ac9809 is used by existing VM /.../virtualMachines/dc0d3a9a-0b00-40d8-830d-41e6f4ac9809.",
>         "details": []
>       }
>     }

This error indicates that unknown VM (to the Director) took up the IP that the Director is trying to assign to a new VM. Either let the Director know to not use this IP by including it in the reserved section of a subnet in your manual network, or make that IP available by terminating the unknown VM.


## Limits of Premium Storage blob snapshots

>     Error 100: Unknown CPI error 'Unknown' with message 'SnaphotOperationRateExceeded (409): The rate of snapshot blob calls is exceeded.

The BOSH snapshot operation may be throttled if you do all of the following:

 * Use Premium Storage for the Cloud Foundry VMs.

 * Enable snapshot in `bosh.yml`. For more information on BOSH Snapshots, please go to https://bosh.io/docs/snapshots.html.

    ```
    director:
      enable_snapshots: true
    ```

 * The time between consecutive snapshots by BOSH is less than **10 minutes**. The limits are documented in [Snapshots and Copy Blob for Premium Storage](https://azure.microsoft.com/en-us/documentation/articles/storage-premium-storage/#snapshots-and-copy-blob).

The workaround is:

 * Disable snapshot temporarily.

    ```
    director:
      enable_snapshots: false
    ```

 * Adjust the snapshot interval to more than 10 minutes.


## Version mismatch between CPI and Stemcell

>     Performing POST request:
>       Post https://mbus-user:<redacted>@10.0.0.4:6868/agent: dial tcp 10.0.0.4:6868: getsockopt: connection refused

For CPI v11 or later, the compatible stemcell version is v3181 or later. If the stemcell version is older than v3181, you may hit the following failure when deploying BOSH.

It is recommended to use the latest version. For example, Stemcell v3232.5 or later, and CPI v12 or later. You may hit the issue [#135](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/135) if you still use an older stemcell than v3232.5.


## Out of memory

If you hit `Out of memory` or `Virtual memory exhausted`, please check whether you use Standard_A0 as instance_type. You should change instance_type to a VM size with more memory.

Please reference the [issue #230](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/230).
