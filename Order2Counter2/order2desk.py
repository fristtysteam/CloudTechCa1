#!/usr/bin/env python3
import os
import platform
import boto3
import uuid
import json
from argparse import ArgumentParser

from common import *

# arguments
parser = ArgumentParser(description='order monitor for Gym example')
parser.add_argument('--stack', help='stack name', default='order2desk')
args = parser.parse_args()
stack_name=args.stack

# bucket name
cf_client = boto3.client('cloudformation')
response = cf_client.describe_stacks(StackName=stack_name)
outputs = response["Stacks"][0]["Outputs"]
menu_bucket_name = cf_output(outputs, "menubucketname")

# banner
print("Welcome to the Gym Desk system")
print('Loading menu from %s...' % menu_bucket_name)

# load menu from S3
s3_client = boto3.client("s3")
menu_json = s3_client.get_object(Bucket=menu_bucket_name, Key='menu.json').get('Body').read().decode()
menu = json.loads(menu_json)

print("... menu loaded!\n")

# auto-detect username
username = os.getlogin()
print("Member name: %s" % username)

# auto-detect host name
hostname = platform.node()
print("Hostname: %s\n" % hostname)

# menu print
print("Menu:")
index = 0
choices = []
for category in menu['categories']:
    print(category['name'])
    for item in category['items']:
        print("  %2d : %s" % ( index, item))
        choices.append(item)
        index = index + 1 
print(" ")
        
# make your choice
choice = int(input("Enter number from 0-%s: " % str(index-1)))

chosen_item = choices[choice]

print("sending order...")

payload = {
    "order_id": str(uuid.uuid4()),
    "hostname": hostname,
    "username": username,
    "item": chosen_item
    }

lambda_client = boto3.client('lambda')
lambda_client.invoke(FunctionName='order2desk_handler',Payload=json.dumps(payload))

print("Your %s is on its way!" % chosen_item)
