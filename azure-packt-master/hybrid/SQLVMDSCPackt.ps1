#
# SQL VM DSC
#

Configuration SQLVMDSCPackt
{
    param 
    (
        [String]$SystemTimeZone
    )

    $DefaultTimezone = Get-AutomationVariable -Name "ServerTimezone"

    if(!$SystemTimeZone) {
        $SystemTimeZone = $DefaultTimezone
    }

    Import-DscResource -Name MSFT_xSmbShare
    Import-DscResource -Name xTimezone

	Node "localhost" {

		# Process Timezone Change
        xTimeZone SetEST {
            IsSingleInstance = "Yes"
            TimeZone = $SystemTimeZone
        }

        # Install necessary Windows Features / Services
		WindowsFeature InstallDotNet45 {
			Name = "Web-Asp-Net45"
			Ensure = "Present"
		}
		WindowsFeature InstallSNMP {
			Name = "SNMP-Service"
			Ensure = "Present"
		}

		# Modify required Registry entries
		Registry WindowsErrorReporting {
			Ensure = "Present"
			Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
			ValueName = "Disabled"
			ValueType = "Dword"
			ValueData = "1"
			Hex = $true
		}
		Registry ExeStoppedWorking {
			Ensure = "Present"
			Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
			ValueName = "DontShowUI"
			ValueType = "Dword"
			ValueData = "1"
			Hex = $true
		}

		# Create Directories and SMB Shares
		File TempDirectory {
			Ensure = "Present"
			Type = "Directory"
			DestinationPath = "D:\Temp"
		}
		xSmbShare TempSMBShare
        {
			DependsOn = "[File]TempDirectory"
            Ensure = "Present" 
            Name   = "Temp"
            Path = "D:\Temp"
            FullAccess = "Everyone"
            Description = "Temp Share for Customer SQL Server"
        } 
		File FourRSysDirectory {
			Ensure = "Present"
			Type = "Directory"
			DestinationPath = "D:\4RSystems"
		}
		xSmbShare FourRSysSMBShare
        {
			DependsOn = "[File]FourRSysDirectory"
            Ensure = "Present" 
            Name   = "4RSystems"
            Path = "D:\4RSystems"
            FullAccess = "Everyone"
            Description = "4R Systems Share for Customer SQL Server"
        } 
	}
}


