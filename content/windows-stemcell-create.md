# Creating a Windows Stemcell for vSphere Using stembuild

This topic describes how to create a Windows Stemcell for vSphere.

## Overview

To create a BOSH stemcell for Windows on vSphere, do the following:

1. [Create a Base VM for the BOSH Stemcell](#create-base-vm)
2. [Install Windows Updates](#install-windows-updates)
3. [Clone the Base VM](#clone-vm)
4. [Construct the BOSH Stemcell](#construct-stemcell)
5. [Package the BOSH Stemcell](#package-stemcell)

!!! note

    **If you already have a BOSH stemcell for Windows on vSphere,
    see [Monthly Stemcell Upgrades](#upgrade-stemcell)**

## Prerequisites

- A vSphere environment
- A Windows Server, version 1709, Windows Server, version 1803 or Windows Server, version 2019 ISO
- `stembuild` from a release in [stembuild](https://github.com/cloudfoundry/stembuild/releases) that corresponds to the operating system of your local host and the stemcell version that you want to build
- Microsoft [Local Group Policy Object Utility (LGPO)](https://www.microsoft.com/en-us/download/details.aspx?id=55319) downloaded to the same folder as your `stembuild`

## Step 1: Create a Base VM for the BOSH Stemcell {: #create-base-vm }

This section describes how to create, configure, and verify a base VM for Windows
from a volume-licensed ISO.

### Upload the ISO

To upload the Windows Server ISO to vSphere, do the following:

1. Log in to the vSphere Web Client.
    - Note: The instructions in this topic are based on vSphere 6.0.
1. Click **Storage** and select a datastore.
1. Select or create a folder where you want to upload the Windows Server ISO.
1. Click **Upload a File** and select the Windows Server ISO.

You can use the `scp` utility instead of the vSphere Web Client to copy the file directly to the datastore server.

### Create and Customize a Base VM

To create and customize a base VM, do the following:

1. In the vSphere Web Client, click the **VMs and Templates** view to display the inventory objects.
1. Right-click an object and select **New Virtual Machine** > **New Virtual Machine**.
1. On the **Select a creation type** page, select **Create a new virtual machine** and click **Next**.
1. On the **Select a name and folder** page, do the following:
    1. Enter a name for the VM.
    1. Select a location for the VM.
    1. Click **Next**.
1. On the **Select a compute resource** page, select a compute resource to run the VM and click **Next**.
1. On the **Select storage** page, do the following:
    1. Select a **VM Storage Policy**.
    1. Select the destination datastore for the VM configuration files and virtual disks.
    1. Click **Next**.
1. On the **Select compatibility** page, for the **Compatible with** configuration setting, select **ESXi 6.0 and later** and click **Next**.
1. On the **Select a guest OS** page, do the following step:
    1. For **Guest OS Family**, select **Windows**.
    1. For **Guest OS Version**, select **Microsoft Windows Server 2019**. If **Microsoft Windows Server 2019** is not
     available, select **Microsoft Windows Server 2016**.
    1. Click **Next**.
1. On the **Customize hardware** page, configure the VM hardware using the information below and click **Next**.
    1. For **New Hard disk**, specify 30 GB or greater.
    1. For **New CD\DVD Drive**, do the following:
		  1. Select **Datastore ISO File**.
		  1. Select the Windows Server ISO file you uploaded to your datastore and click **OK**.
		  1. Enable the **Connect At Power On** checkbox.
1. Review the configuration settings on the **Ready to complete** page and click **Finish**.

### Install Windows Server

To install Windows Server on the base VM, do the following:

1. After creating the VM, click **Power** > **Power On** in the **Actions** tab for your VM.
1. Select **Windows Server Standard**.
1. Select **Custom installation**.
1. Complete the installation process and enter a password for the Administrator user.

### Verify OS

To verify that you are using the correct OS version, run the following PowerShell command on the base VM:

```powershell
[System.Environment]::OSVersion.Version
```

The output should display the following:

```powershell
[System.Environment]::OSVersion.Version
Major    Minor    Build    Revision
----     ----     -----    --------
10        0       17763    0
```

### Install VMware Tools

To install VMware Tools on the base VM, do the following:

1. In the vSphere Web Client, right-click the base VM and select **Guest OS** > **Install VMware Tools**.
1. Navigate to the `D:` drive and run `setup64.exe`.
1. Restart the VM to complete the installation.

## Step 2: Install Windows Updates {: #install-windows-updates }

Install Windows updates on the base VM using your preferred procedure.
For example, you can install Windows updates by following the steps below. This procedure requires internet access.

1. On the base VM, run the **SConfig** utility.
1. Select **Download and Install Updates**.
1. Enter **A** to search for all updates.
1. For **Select an option**, enter **A** to install all updates.

You may need to restart the base VM while installing the updates.

## Step 3: Clone the Base VM {: #clone-vm }

To clone the base VM, do the following in the vSphere Web Client:

1. Power down the base VM.
1. Right-click the base VM.
1. Select **Clone** > **Clone to Virtual Machine**. This clone is your target VM.
1. Save the base VM. You will run Windows updates on this VM for future stemcells.

## Step 4: Construct the BOSH Stemcell {: #construct-stemcell }

!!! note
    The target VM must be routable from your local host. Before running the `construct` command, ensure you are logged out of the target VM.</p>

To construct the BOSH stemcell, run the following command from your local host:

```powershell
./STEMBUILD-BINARY construct -vm-ip 'TARGET-VM-IP' -vm-username 'TARGET-USERNAME' -vm-password 'TARGET-VM-PASSWORD' -vcenter-url 'VCENTER-URL' -vcenter-username 'VCENTER-USERNAME' -vcenter-password 'VCENTER-PASSWORD' -vm-inventory-path 'INVENTORY-PATH'
```

Where:

- `STEMBUILD-BINARY` is the `stembuild` file for the version of your local host operating system and the
version of the stemcell that you want to build. For example, `stembuild-windows-2019-2`.
- `TARGET-VM-IP` is the IP address of your target VM.
- `TARGET-USERNAME` is the username of an account with Administrator privileges.
- `TARGET-VM-PASSWORD` is the password for the Administrator account. The password must be enclosed in single quotes.
- `VCENTER-URL` is the URL of your vCenter.
- `VCENTER-USERNAME` is the username of your account in vCenter.
- `VCENTER-PASSWORD` is your password. The password must be enclosed in single quotes.
- `INVENTORY-PATH` is the vCenter inventory path to the target VM.

!!! warning
    This operation may take up to an hour to complete and results in a powered-off target Windows VM in your vSphere environment.
    During `construct` execution, the WinRM connection terminates. This behavior is expected, and the `construct` command is still being executed.
    Do not attempt to re-run the `construct` command.

If you want to view the status of `construct`, you can log in to the target VM and do the following:

1. Start PowerShell.
1. Run the following command:

    ```powershell
    Get-Content -Path "C:\provision\log.log" -Wait
    ```

## Step 5: Package the BOSH Stemcell {: #package-stemcell }

To package the BOSH stemcell, run the following command from your local host:

```powershell
./STEMBUILD-BINARY package -vcenter-url 'VCENTER-URL' -vcenter-username 'VCENTER-USERNAME' -vcenter-password 'VCENTER-PASSWORD' -vm-inventory-path 'INVENTORY-PATH'
```

Where:

- `STEMBUILD-BINARY` is the `stembuild` file for the version of your local host operating system and the
version of the stemcell that you want to build. For example, `stembuild-windows-2019-2`.
- `VCENTER-URL` is the URL of your vCenter.
- `VCENTER-USERNAME` is the username of your account in vCenter.
- `VCENTER-PASSWORD` is your password. The password must be enclosed in single quotes.
- `INVENTORY-PATH` is the vCenter inventory path to the target VM.

!!! note

    This command creates a stemcell on your local host in the folder where you
    ran the command and may take up to 30 minutes to complete.

## Monthly Stemcell Upgrades {: #upgrade-stemcell }

After Microsoft releases operating system updates, you should upgrade your BOSH stemcell. Microsoft typically
releases Windows updates on the second Tuesday of each month.

To upgrade your BOSH stemcell, do the following:

1. [Install Windows Updates](#install-windows-updates) on the base VM.
2. [Clone the Base VM](#clone-vm).
3. [Construct the BOSH Stemcell](#construct-stemcell).
4. [Package the BOSH Stemcell](#package-stemcell).
5. Deploy the updated stemcell with BOSH.
