#!/usr/bin/env pwsh
# Order2Desk stack
# Peadar Grant

$StackName = "order2Counter"

Write-Host 'creating stack... ' -NoNewLine
aws cloudformation create-stack --stack-name $StackName --template-body file://order2desk_template.yml --capabilities CAPABILITY_NAMED_IAM
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'Waiting for stack to create... ' -NoNewLine
aws cloudformation wait stack-create-complete --stack-name $StackName
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'Uploading initial menu...' -NoNewLine
$BucketName=((aws cloudformation describe-stacks --stack order2desk | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq menubucketname)[0].OutputValue
aws s3 cp menu.json s3://$BucketName/menu.json
Write-Host 'done' -ForegroundColor Blue

Write-Host 'lab is ready' -ForegroundColor Blue
