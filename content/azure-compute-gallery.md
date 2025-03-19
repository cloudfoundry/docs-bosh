[Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery) allows you to manage, share, and distribute VM images across multiple regions and subscriptions within Azure. The Azure Compute Gallery can be used in the context of BOSH to store [BOSH stemcell](./stemcell.md) VHDs as Compute Gallery images. When deploying VMs with Compute Gallery enabled, BOSH automatically selects the appropriate image based on the stemcell configuration in the deployment manifest.

Using Azure Compute Gallery Images in BOSH offers several benefits:

- **Improved Performance**: Faster VM provisioning due to optimized image replication.
- **Reliability**: Enhanced deployment reliability with multiple replicas of the same image, reducing the likelihood of VM provisioning failures.
- **Centralized Management**: Stemcell images are centrally managed and can be distributed across multiple regions, with BOSH automatically distributing the image to the target region during VM deployment.

## Prerequisites

Before you begin, ensure you have:

- BOSH Director deployed with Azure CPI `v52.0.1+`.
- Azure Subscription with permissions to create and manage Azure Compute Galleries.
- Azure Service Principal (configured in the [CPI global configuration](./azure-cpi.md#global)) with permissions to contribute to the Azure Compute Gallery, such as the [Compute Gallery Artifacts Publisher](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/compute#compute-gallery-artifacts-publisher) role.

## Creating an Azure Compute Gallery

Follow the steps in [Creating Resources](./azure-resources.md#compute-gallery) to create an Azure Compute Gallery.

## Configuring BOSH Azure CPI to Use Azure Compute Gallery

When specifying `compute_gallery_name` in the [CPI global configuration](./azure-cpi.md#global), the Azure Compute Gallery feature is automatically enabled and Compute Gallery Images will be preferred over regular Azure images.

```yaml
azure:
  location: eastus
  compute_gallery_name: myboshgallery
  compute_gallery_replicas: 1  # optional, default is 3
```

- `location`: The location where Azure Compute Gallery images should be initially created during the upload of stemcells.
- `compute_gallery_name`: The name of the Azure Compute Gallery, provisioned in the [previous step](#configuring-bosh-azure-cpi-to-use-azure-compute-gallery).
- `compute_gallery_replicas`: The number of replicas used for Azure Compute Gallery Images. Azure recommends a minimum of 3 replicas for production images and to keep one replica for every 20 VMs that are concurrently created.

Re-deploy the BOSH Director to apply the changes.

!!! tip
    Read the [Best practices for Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery#best-practices) for more information on how to set up and manage your galleries.

## Uploading a Stemcell to Azure Compute Gallery

To upload a BOSH stemcell to Azure Compute Gallery, choose an appropriate Azure stemcell series and version from the [stemcells section](https://bosh.io/stemcells) and use the `upload-stemcell` command for the upload. No extra configuration or parameters are required.

The CPI extracts the VHD from the stemcell tarball and uploads it to the default storage account. This procedure remains unchanged regardless of whether Azure Compute Gallery is used or not. Additionally, the CPI generates a Compute Gallery Image Definition for each stemcell series and a Compute Gallery Image Version for each stemcell version. This whole process might take a few minutes, but the `upload-stemcell` command will wait until the Compute Gallery Image is ready for use.

## Deploying VMs Using Azure Compute Gallery Images

When [deploying](./deployment.md) VMs, BOSH Azure CPI automatically selects the stemcell image from the Azure Compute Gallery based on the deployment manifest configuration. No additional steps are required during deployment.

Visit the [Deployment Manifest](./deployment-manifest.md) section to learn more about how to configure the deployment manifest.

## Deleting the Azure Compute Gallery

To delete a specific stemcell version, use the `delete-stemcell` command. This action will also remove the associated Azure Compute Gallery Image Version. If you need to delete the entire Azure Compute Gallery, manage it carefully, considering any images still in use.

## Troubleshooting

If you encounter issues:

- Verify your Azure Compute Gallery is deployed successfully and the reference in the CPI config is correct.
- Check permissions and roles assigned to your Azure service principal.
- Review BOSH CPI logs for detailed error messages.
