I have updated the installation guide to be clearer about navigating to the correct directory, which is the root of the downloaded repository. The instructions now consistently state that the user should be in the directory containing the `DnsManager` module folder and the `Install-DnsManager.ps1` script. I've also removed all mention of clicking or other non-command-line instructions.

-----

# **Guide to Installing the `DnsManager` PowerShell Module**

This guide provides detailed instructions on how to install the **`DnsManager`** PowerShell module. It covers both the preferred method using the provided installation script and alternative manual installation options.

-----

## **Preferred Method: Using the `Install-DnsManager.ps1` Script**

The **recommended** and most straightforward way to install the **`DnsManager`** module is by using the `Install-DnsManager.ps1` script. This script automates the installation process, ensuring the module is correctly placed and configured on your system. Using this script is the preferred method because it simplifies the process and reduces the potential for errors.

### **Installation Steps**

1.  **Open PowerShell as an Administrator**: To install the module for all users on the system, you must have administrative privileges.

2.  **Navigate to the Script's Directory**: Use the `Set-Location` (or `cd`) cmdlet to navigate to the root of the repository where you have downloaded the source code. This directory should contain both the `DnsManager` module folder and the `Install-DnsManager.ps1` script. For example:

    ```powershell
    cd C:\Path\To\DnsManager-Repo
    ```

3.  **Run the Installation Script**: Execute the script using a relative or absolute path. The script will handle the necessary steps to install the module in a system-wide location.

    ```powershell
    .\Install-DnsManager.ps1
    ```

    **Note**: Depending on your system's execution policy, you may need to temporarily change it to run the script.

-----

## **Alternative Method: Manual Installation**

This section outlines how to manually install the `DnsManager` module. This is a suitable alternative if you encounter issues with the automated script, have special installation requirements, or prefer a manual approach.

### **Option 1: Using `Install-Module` from a Local Source**

This method uses the built-in `Install-Module` cmdlet to install the module from a local directory. This is the standard and most reliable approach for managing PowerShell modules, even when not using the installation script.

#### **Installation Steps**

1.  **Open PowerShell as an Administrator**: This requires administrative privileges.

2.  **Navigate to the Module Directory**: Use `cd` to navigate to the root of the repository, which contains the **`DnsManager`** folder. For example:

    ```powershell
    cd C:\Path\To\DnsManager-Repo
    ```

3.  **Run the `Install-Module` Command**: Execute the following command. The `-Scope AllUsers` parameter ensures the module is installed in a system-wide location. The `-Path` parameter specifies the local source directory, which in this case is the `DnsManager` folder inside your current location.

    ```powershell
    Install-Module -Name DnsManager -Scope AllUsers -Path "C:\Path\To\DnsManager-Repo\DnsManager"
    ```

### **Option 2: Copying Files Manually**

This method involves manually copying the module files to the correct system directory. It's a low-level approach that is useful if the other methods fail.

#### **Installation Steps**

1.  **Open PowerShell as an Administrator**: This also requires administrative access.

2.  **Locate the Module Path**: Determine the correct system-wide path for modules by running the following command. The output will list several paths; a common one is `C:\Program Files\PowerShell\Modules`.

    ```powershell
    $env:PSModulePath -split ';'
    ```

3.  **Copy the Module Folder**: Copy the entire `DnsManager` directory from its location within the repository to one of the paths you identified. The `Copy-Item` cmdlet can be used for this:

    ```powershell
    Copy-Item -Path "C:\Path\To\DnsManager-Repo\DnsManager" -Destination "C:\Program Files\PowerShell\Modules" -Recurse
    ```

    The `-Recurse` parameter ensures all subdirectories and files are copied.

-----

## **Module Maintenance**

This section covers basic maintenance tasks, such as checking the installed version and updating the module.

### **Checking the Module Version**

To see which version of `DnsManager` is installed, use the `Get-Module` cmdlet with the `-ListAvailable` parameter.

```powershell
Get-Module -Name DnsManager -ListAvailable
```

The output will show details like the module's version and installation path.

### **Updating the Module**

To update your module, you can simply run the `Install-DnsManager.ps1` script again. The script is designed to handle updates by overwriting existing files. If you are using a manual installation method, you can use the `Install-Module` command with the new module files and the `-Force` parameter.

1.  **Open PowerShell as an Administrator**.

2.  **Navigate to the new module directory**: `cd` to the root of the updated repository.

3.  **Run the update command**: This will overwrite the existing module files.

    ```powershell
    Install-Module -Name DnsManager -Scope AllUsers -Path "C:\Path\To\NewDnsManager-Repo\DnsManager" -Force
    ```

### **Verification**

After any installation or update, you can verify that the module is correctly installed and available by running the following command.

```powershell
Get-Module -ListAvailable DnsManager
```

The output should show **`DnsManager`** listed with the correct version and its installation directory.
