############## C O N F I G ##############
."C:\AWS\AWSConfig.ps1"

############## F U N C T I O N S ##############
."C:\AWS\AWSUtilities.ps1"

#Environment
$ENVIRONMENT_NAME = "My Environment"
$ENVIRONMENT_TYPE = "Development"
$BACKUP_TYPE = "Daily"
$backupTag = "xxxxxxxx" #Make sure the value of this Tag is 'Yes', without the quotes, on the instances you want backed up

############## M A I N ##############

try
{
    $start = Get-Date
    WriteToLogAndEmail "$ENVIRONMENT_NAME $ENVIRONMENT_TYPE $BACKUP_TYPE Backup Starting" -excludeTimeStamp $true
    
    $stagingInstanceIDs= GetBackedUpInstances $backupTag

    CreateSnapshotsForInstances $stagingInstanceIDs

    CleanupDailySnapshots

    WriteToLogAndEmail "$ENVIRONMENT_NAME $ENVIRONMENT_TYPE $BACKUP_TYPE Backup Complete" -excludeTimeStamp $true   
    
    $end = Get-Date
    $timespan = New-TimeSpan $start $end
    $hours=$timespan.Hours
    $minutes=$timespan.Minutes    
    WriteToEmail "Backup took $hours hour(s) and $minutes minute(s)"
    
    SendStatusEmail -successString "SUCCESS"
}
catch
{
    SendStatusEmail -successString "FAILED"
}
