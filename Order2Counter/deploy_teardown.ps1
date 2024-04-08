#!/usr/bin/env pwsh

$StackName = "orderToCounter"
$MainStack = "orderToCounter"
$DeployStack = "${StackName}deploy"

Write-Host 'emptying deployment bucket... ' -NoNewLine
$BucketName=((aws cloudformation describe-stacks --stack $DeployStack | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq deploybucketname)[0].OutputValue
aws s3 rm s3://$BucketName/code.zip
Write-Host 'ok' -ForegroundColor Green

Write-Host 'delete stack... ' -NoNewLine
aws cloudformation delete-stack --stack-name $DeployStack
Write-Host 'ok' -ForegroundColor Green

Write-Host 'Waiting for stack to delete... ' -NoNewLine
aws cloudformation wait stack-delete-complete --stack-name $DeployStack
Write-Host 'ok' -ForegroundColor Green


Write-Host 'delete done' -ForegroundColor Green
