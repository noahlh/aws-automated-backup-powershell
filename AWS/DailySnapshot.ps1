############## C O N F I G ##############
."C:\AWS\AWSConfig.ps1"

############## F U N C T I O N S ##############
."C:\AWS\AWSUtilities.ps1"

#Environment
$ENVIRONMENT_NAME = "My Environment"
$ENVIRONMENT_TYPE = "Development"
$BACKUP_TYPE = "Daily"
$backupTag = "Backed Up?"
$stagingInstanceIDs= GetBackedUpInstances $backupTag

############## M A I N ##############

try
{
    $start = Get-Date
    WriteToLogAndEmail "$ENVIRONMENT_NAME $ENVIRONMENT_TYPE $BACKUP_TYPE Backup Starting" -excludeTimeStamp $true

    CreateSnapshotsForInstances $stagingInstanceIDs

    CleanupDailySnapshots

    WriteToLogAndEmail "$ENVIRONMENT_NAME $ENVIRONMENT_TYPE $BACK_UPTYPE Backup Complete" -excludeTimeStamp $true   
    
    $end = Get-Date
    $timespan = New-TimeSpan $start $end
    $hours=$timespan.Hours
    $minutes=$timespan.Minutes    
    WriteToEmail "Backup took $hours hr(s) and $minutes min(s)"
    
    SendStatusEmail -successString "SUCCESS"
}
catch
{
    SendStatusEmail -successString "FAILED"
}
