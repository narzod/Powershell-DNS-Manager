# **Guide to Installing the `DnsManager` PowerShell Module**

This guide provides detailed instructions on how to install the **`DnsManager`** PowerShell module on your system. It covers both a preferred method and a manual alternative, and includes guidance on maintenance and updating.

-----

## **Preferred Method: Using `Install-Module`**

The recommended way to install **`DnsManager`** is by using the built-in `Install-Module` cmdlet. This method is the standard and most reliable approach for managing PowerShell modules. While this is the preferred method, some users in specific environments may encounter issues. If you run into problems, you can safely skip to the manual installation steps outlined below.

### **Installation Steps**

1.  **Open PowerShell as an Administrator**: You must have administrative privileges to install a module for all users on the system. Right-click the PowerShell icon and select **"Run as Administrator"**.

2.  **Navigate to the Module Directory**: Use the `Set-Location` (or `cd`) cmdlet to navigate to the directory where you have downloaded or cloned the module's source code. For example:

    ```powershell
    cd C:\Path\To\DnsManager
    ```

3.  **Run the `Install-Module` Command**: Execute the following command to install the module. The `-Scope AllUsers` parameter is crucial as it ensures the module is installed in a system-wide location, making it available to all users.

    ```powershell
    Install-Module -Name DnsManager -Scope AllUsers -Path "C:\Path\To\DnsManager"
    ```

    **Note**: The `-Path` parameter is essential for installing from a local directory. When installing from a public repository like the PowerShell Gallery, you would omit this parameter.

-----

## **Alternative Method: Manual Installation**

This method involves manually copying the module files to the correct system directory. It is a suitable alternative if you encounter issues with the `Install-Module` cmdlet or have special installation requirements.

### **Installation Steps**

1.  **Open PowerShell as an Administrator**: Just like the preferred method, this requires administrative access.

2.  **Locate the Module Path**: Determine the correct system-wide path for modules by running the following command. The output will list several paths; a common one is `C:\Program Files\PowerShell\Modules`.

    ```powershell
    $env:PSModulePath -split ';'
    ```

3.  **Copy the Module Folder**: Copy the entire `DnsManager` directory from its current location to one of the paths you identified in the previous step. The `Copy-Item` cmdlet can be used for this:

    ```powershell
    Copy-Item -Path "C:\Path\To\DnsManager" -Destination "C:\Program Files\PowerShell\Modules" -Recurse
    ```

    The `-Recurse` parameter ensures all subdirectories and files are copied correctly.

-----

## **Temporary Use: Using `Import-Module`**

If you don't need to permanently install the module but just want to use it for the current PowerShell session, you can use the `Import-Module` cmdlet directly with the module's path. This does **not** install the module system-wide.

### **How to Use**

1.  **Open a regular PowerShell session**. Administrator privileges are not needed unless the module's functions require them.

2.  **Import the module**: Run the following command, specifying the full path to the module folder.

    ```powershell
    Import-Module -Name DnsManager -Scope AllUsers -Path "C:\Path\To\DnsManager"
    ```

    The module's cmdlets will now be available for use until the PowerShell window is closed.

-----

## **Module Maintenance**

After installation, you can perform some basic checks and maintenance using these commands.

### **Checking the Module Version**

To see which version of `DnsManager` is installed, you can use `Get-Module` with the `-ListAvailable` parameter.

```powershell
Get-Module -Name DnsManager -ListAvailable
```

The output will show you details like the module's version and where it's installed.

### **Updating the Module**

When a new version of the module is released, you can update your installed version. While the `Update-Module` cmdlet is typically used for modules from a gallery, for a local installation, you will use `Install-Module` with the `-Force` parameter. This effectively overwrites the existing module with the new files.

1.  **Open PowerShell as an Administrator**.

2.  **Navigate to the new module directory**.

3.  **Run the `Install-Module` command again**: This will overwrite the existing module files with the newer ones, effectively updating the module.

    ```powershell
    Install-Module -Name DnsManager -Scope AllUsers -Path "C:\Path\To\NewDnsManager" -Force
    ```

### **Verification**

After performing any installation or update, you can verify that the module is installed and available by running the following command.

```powershell
Get-Module -ListAvailable DnsManager
```

The output should show **`DnsManager`** listed with the correct version and its installation directory.
