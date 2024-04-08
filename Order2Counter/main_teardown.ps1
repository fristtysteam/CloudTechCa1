#!/usr/bin/env pwsh

$StackName = "order2Counter"
$MainStack = "order2Counter"
$DeployStack = "${StackName}deploy"

Write-Host 'emptying bucket... ' -NoNewLine
$BucketName=((aws cloudformation describe-stacks --stack $MainStack | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq menubucketname)[0].OutputValue
aws s3 rm s3://$BucketName/menu.json
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'delete stack... ' -NoNewLine
aws cloudformation delete-stack --stack-name $StackName 
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'Waiting for stack to delete... ' -NoNewLine
aws cloudformation wait stack-delete-complete --stack-name $StackName
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'delete done' -ForegroundColor Blue
