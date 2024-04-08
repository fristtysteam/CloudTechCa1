#!/usr/bin/env pwsh
# Order2Desk stack

$Stack = "orderToCounter"
$MainStack = "${StackName}_main"
$DeployStack = "${StackName}_deploy"

Write-Host 'creating code zip file... ' -NoNewLine
if ( $IsMacOs ) {
    # deal with permission bits set on Mac 
    # execute bit needs to be set (prior experience)
    chmod +x router.py common.py
    # need to use native ZIP command to respect permissions
    zip code.zip router.py common.py
}
else {
    # way to do this in PowerShell
    Compress-Archive -Force -DestinationPath code.zip -Path router.py,common.py
}
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'creating deploy stack' -NoNewLine
aws cloudformation create-stack --stack-name $DeployStack --template-body file://deploy_template.yml
Write-Host 'done' -ForegroundColor Blue

Write-Host 'waiting for deploy stack to create...' -NoNewLine
aws cloudformation wait stack-create-complete --stack-name $DeployStack
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'copying to deploy bucket...' -NoNewLine
$DeployBucketName=((aws cloudformation describe-stacks --stack $DeployStack | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq DeployBucketName)[0].OutputValue
aws s3 cp code.zip s3://$DeployBucketName/code.zip
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'creating main stack... ' -NoNewLine
aws cloudformation create-stack --stack-name $MainStack --template-body file://order2desk_template.yml --capabilities CAPABILITY_NAMED_IAM
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'Waiting for main stack to create... ' -NoNewLine
aws cloudformation wait stack-create-complete --stack-name $StackName
Write-Host 'ok' -ForegroundColor Blue

Write-Host 'Uploading initial menu...' -NoNewLine
$BucketName=((aws cloudformation describe-stacks --stack order2desk | ConvertFrom-Json).Stacks[0].Outputs | Where-Object OutputKey -eq menubucketname)[0].OutputValue
aws s3 cp menu.json s3://$BucketName/menu.json
Write-Host 'done' -ForegroundColor Blue

Write-Host 'stacks are ready' -ForegroundColor Blue
