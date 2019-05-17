Login-AzureRmAccount

# Azure Region where the Backup resources will be deployed
$location = "South Central US"

# Backup Parameters
$backupVaultName = "Packt-Backup-Vault"
$numOfWeeksRetention = 52
$daysOfWeekBackup = "Monday","Wednesday","Friday"

# (OPTIONAL) Create a new Resource Group where the Backup Resources will be placed
$rgName = "PacktPublishing"
New-AzureRmResourceGroup -Name $rgName -Location $location -Verbose

# Create an Azure Backup Vault and then create a set of Policies
$backupVault = New-AzureRmRecoveryServicesVault -ResourceGroupName $rgName -Location $location -Name $backupVaultName -Verbose
Set-AzureRmRecoveryServicesBackupProperties -Vault $backupVault -BackupStorageRedundancy LocallyRedundant -Verbose

$newSchedPolicy = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureVM
$newSchedPolicy.ScheduleRunFrequency = "Weekly"
$newSchedPolicy.ScheduleRunDays = $daysOfWeekBackup
$today = Get-Date -Date "2016-12-14 04:00:00"
$newSchedPolicy.ScheduleRunTimes.Clear()
$newSchedPolicy.ScheduleRunTimes.Add($today.ToUniversalTime())

$newRetentionPolicy = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM
$newRetentionPolicy.IsDailyScheduleEnabled = $false
$newRetentionPolicy.IsWeeklyScheduleEnabled = $true
$newRetentionPolicy.IsMonthlyScheduleEnabled = $false
$newRetentionPolicy.IsYearlyScheduleEnabled = $false
$newRetentionPolicy.WeeklySchedule.DurationCountInWeeks = $numOfWeeksRetention
$newRetentionPolicy.WeeklySchedule.DaysOfTheWeek = $daysOfWeekBackup

Set-AzureRmRecoveryServicesVaultContext -Vault $backupVault -Verbose
$pol = New-AzureRmRecoveryServicesBackupProtectionPolicy -Name "DefaultWeeklyPolicy" -WorkloadType AzureVM -SchedulePolicy $newSchedPolicy -RetentionPolicy $newRetentionPolicy -Verbose

Get-AzureRmVM -ResourceGroupName $rgName | ForEach-Object {Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -ResourceGroupName $rgName -Name $_.Name}