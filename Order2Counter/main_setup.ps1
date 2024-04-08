#!/usr/bin/env pwsh
# Order2Desk stack

$StackName = "orderToCounter"
$MainStack = "orderToCounter"
$DeployStack = "${StackName}deploy"

## Get name of deployment bucket

$DeployBucketName=((aws cloudformation describe-stacks --stack $DeployStack | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq DeployBucketName)[0].OutputValue


## CREATING THE MAIN STACK

Write-Host 'creating main stack... ' -NoNewLine
aws cloudformation create-stack --stack-name $MainStack --template-body file://main_template.yml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=DeployBucketName,ParameterValue=$DeployBucketName
Write-Host 'ok' -ForegroundColor Green

Write-Host 'Waiting for main stack to create... ' -NoNewLine
aws cloudformation wait stack-create-complete --stack-name $MainStack
Write-Host 'ok' -ForegroundColor Green


## UPLOAD THE MENU FILE

Write-Host 'Uploading initial menu...' -NoNewLine
$BucketName=((aws cloudformation describe-stacks --stack order2desk | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq menubucketname)[0].OutputValue
aws s3 cp menu.json s3://$BucketName/menu.json
Write-Host 'done' -ForegroundColor Green

Write-Host 'main stack is ready' -ForegroundColor Green
