############## C O N F I G ##############

#AWS SDK Path 
Add-Type -Path "C:\Program Files (x86)\AWS SDK for .NET\bin\AWSSDK.dll"

#Access Keys
$accessKeyID="XXXXXXXXXXXXXXXXXXXX"
$secretAccessKey="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$accountID = "############"

#Regions
#$serviceURL="https://ec2.us-west-1.amazonaws.com"
#$serviceURL="https://ec2.us-west-2.amazonaws.com"
#$serviceURL="https://ec2.us-east-1.amazonaws.com"

#Log
$LOG_PATH="C:\AWS\Logs\"

#Email
$FROM_ADDRESS = "you@example.com"
$ADMIN_ADDRESSES = "you@example.com","you2@example.com.com"


#Expiration
$EXPIRATION_DAYS = 5
$EXPIRATION_WEEKS = 4
$MAX_FUNCTION_RUNTIME = 60 # minutes

#Test
$TEST_URL = "http://example.com"

############## A W S  C L I E N T S ##############
#Global Amazon EC2 Client
$config=New-Object Amazon.EC2.AmazonEC2Config
$config.ServiceURL = $serviceURL
$EC2_CLIENT=[Amazon.AWSClientFactory]::CreateAmazonEC2Client($accessKeyID, $secretAccessKey, $config)

#Global Amazon SES Client
$SES_CLIENT=[Amazon.AWSClientFactory]::CreateAmazonSimpleEmailServiceClient($accessKeyID, $secretAccessKey)
