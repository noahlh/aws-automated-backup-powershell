# PowerShell Scripts for EC2 Backups

A set of Windows PowerShell scripts to enable automated daily/weekly backups (via snapshots) on AWS EC2 Windows instances.  I used these to setup a backup process on Windows Server 2012 R2.

## Credit

First and foremost, credit for the original versions of these goes to Chris Hettinger from the following post:

[AWS Disaster Recovery Automation w/ Powershell](http://messor.com/aws-disaster-recovery-automation-w-powershell/)

## Changes

However, the scripts presented in Chris' post use v1.0 of the AWS API, which is now deprecated.  I dusted off the 'ol API documents & debugger to get them working with the v2.3.33.0 API. This has now been updated to work with v3.1.12.0 (as of September 2015)

For the sake of completeness, I'm going to include the steps Chris outlined in his blog.

## Installation

### 1.  Setup Amazon Simple Email Service

The first thing you will want to do is apply for access to SES and setup a verified sender address; this may take several hours.

Optionally, you can use your own email server (see Configure AWSConfig.ps1).

### 2.  Get the AWS SDK for .NET

Download the [AWS SDK for .NET](http://aws.amazon.com/sdkfornet/)

### 3.  Install the scripts

After the SDK has been installed, pick a place to store the scripts (ex. C:\AWS). Next, copy the scripts into your AWS directory. Additionally, create a directory called “Logs” inside of your AWS directory.

## Configuration

### Configure AWSConfig.ps1

Change the AWS .NET SDK Path:

_(Note the latest version has the DLLs in the \Net35 and \Net45 subdirectories of \bin - I used the \Net45 version for my 2012 R2 setup)_

```PowerShell
# AWS SDK Path 
Add-Type -Path "C:\Program Files (x86)\AWS SDK for .NET\bin\Net45\AWSSDK.EC2.dll"
Add-Type -Path "C:\Program Files (x86)\AWS SDK for .NET\bin\Net45\AWSSDK.SimpleEmail.dll"
```

Add your AWS Access Key, Secret, and Account ID:

_(Account ID can be found under your AWS username dropdown -> Security Credentials -> Account Identifiers.  Remove the dashes for the config file)_

```PowerShell
# Access Keys
$accessKeyID="XXXXXXXXXXXXXXXXXXXX"
$secretAccessKey="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$accountID = "############"
```

Uncomment the region that your instances are running in:

```PowerShell
# EC2 Regions
# $serviceURL="https://ec2.us-east-1.amazonaws.com" # US East (Northern Virginia)
# $serviceURL="https://ec2.us-west-2.amazonaws.com" # US West (Oregon)
# $serviceURL="https://ec2.us-west-1.amazonaws.com" # US West (Northern California)
# $serviceURL="https://ec2.eu-west-1.amazonaws.com" # EU (Ireland)
# $serviceURL="https://ec2.ap-southeast-1.amazonaws.com" # Asia Pacific (Singapore)
# $serviceURL="https://ec2.ap-southeast-2.amazonaws.com" # Asia Pacific (Sydney)
# $serviceURL="https://ec2.ap-northeast-1.amazonaws.com" # Asia Pacific (Tokyo)
# $serviceURL="https://ec2.sa-east-1.amazonaws.com" # South America (Sao Paulo)
```

If you are using SES, uncomment the region you are using:

```PowerShell
# SES Regions
# $sesURL="https://email.us-east-1.amazonaws.com" # US East (Northern Virginia)
# $sesURL="https://email.us-west-2.amazonaws.com" # US West (Oregon)
# $sesURL="https://email.eu-west-1.amazonaws.com" # EU (Ireland)
```

Enter your log path:

```PowerShell
# Log
$LOG_PATH="C:\AWS\Logs\"
```

Provide a from address (must be verified in Amazon Simple Email Services (SES) if using it) & an admin address that will receive emails. Optionally add a prefix to your subject for better sorting/routing of email:

```PowerShell
#Email
$FROM_ADDRESS =     "nnn@nnn.com"
$ADMIN_ADDRESSES =  "nnn@nnn.com" #Add multiple addresses as such: "user1@nnn.com", "user2@nnn.com"
$SUBJECT_PREFIX = "" #Leave blank if you do not want any prefix
```

If using a custom email server set the following variables. The password is stored in an ecrypted form (see [here](http://social.technet.microsoft.com/wiki/contents/articles/4546.working-with-passwords-secure-strings-and-credentials-in-windows-powershell.aspx)):

```PowerShell
$CUSTOM_EMAIL = $true # Set to $true to enable custom email


#Custom Email Properties
$CUSTOM_EMAIL_USERNAME = "xxxxxx" #Can be "domain\username" or "user@domain.com". This will depend of your email system.
$CUSTOM_EMAIL_SECURE_PASSWORD = "*************" #Run "read-host -AsSecureString | ConvertFrom-SecureString" and paste the output above within quotes and no line breaks
$CUSTOM_EMAIL_SERVER = "mail.nnn.com"
$CUSTOM_EMAIL_PORT  = 25
$CUSTOM_EMAIL_SSL = $true
```

Edit the max number of days to keep old snapshots and the max allowable runtime of the script:

```PowerShell
# Expiration
$EXPIRATION_DAYS = 7
$EXPIRATION_WEEKS = 4
$MAX_FUNCTION_RUNTIME = 60 # minutes
```

### Create an Event Log

Execute the following line in PowerShell to allow the scripts to add entries into the event log:

```PowerShell
New-EventLog -Source "AWS PowerShell Utilities" -LogName "Application"
```

### Configure DailySnapshots.ps1

Verify the paths to AWSConfig.ps1 and AWSUtilities.ps1 :

```PowerShell
############## C O N F I G ##############
."C:\AWS\AWSConfig.ps1"

############## F U N C T I O N S ##############
."C:\AWS\AWSUtilities.ps1"
```

Edit the environment variables to define the Name (i.e. "Our Cloud Servers"), Type (i.e. "Staging", "Production", etc.), the Backup Type (i.e. "Daily") and, most importantly, the Tag to look for to identify instances to backup:

```PowerShell
# Environment
$ENVIRONMENT_NAME = "Our Cloud Servers"
$ENVIRONMENT_TYPE = "Production"
$BACKUP_TYPE = "Daily"
$backupTag = "xxxxxxxx" #Make sure the value of this tag is 'Yes', without the quotes, on the instances you want backed up
```
## Usage

Running the script DailySnapshot.ps1 will create a snapshot of each volume for each instance (without shutting them down).  Once it's complete, you'll receive an email via Amazon SES with the status of the backup and details of the process.

To automate the process, you can setup a recurring task in Task Scheduler.  When doing so, make sure you execute the "powershell" command and not just the script:

![task scheduler screenshow](http://i.imgur.com/07ozK3e.png)

## Troubleshooting

So far a majority of the issues encountered (going purely by the small number of Github issues I've received here) have to do with IAM permissions for the user / API key executing the scripts.  Do make sure your IAM user has permissions for at least the following actions:

EC2:

  * CreateTags
  * DescribeInstances
  * StartInstances
  * StopInstances
  * DescribeSnapshots
  * DeleteSnapshot
  * CreateSnapshot
  * DescribeVolumes

SES:

  * SendEmail 
  * SendRawEmail

## Contribute

I did this mostly to learn, so please excuse any bugs / awful code.  And more imporantly, please help improve these scripts!  Open an issue, fork, submit a pull request, etc.  You know the drill.  I'm game. 

## License

Copyright (C) 2015 - 2016 Noah Lehmann-Haupt.  Contributions by Ryan Bowman.  Released under the MIT License. See the bundled LICENSE file for details.
