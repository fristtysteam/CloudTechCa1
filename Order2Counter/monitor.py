#!/usr/bin/env python3
# order2desk monitor
# Peadar Grant

import sys
import boto3
import json
from argparse import ArgumentParser

from common import *

parser = ArgumentParser(description='order monitor for gym example')
parser.add_argument('--stack', help='stack name', default='order2Counter')
parser.add_argument('--wait', help='wait for booking day', action='store_true', default=False)
parser.add_argument('--debug', help='debug', action='store_true', default=False)
args = parser.parse_args()
stack_name=args.stack

queue_url = None
cf_client = boto3.client('cloudformation')
response = cf_client.describe_stacks(StackName=stack_name)
outputs = response["Stacks"][0]["Outputs"]
queue_url = cf_output(outputs, "dumbellqurl")

if queue_url is None:
    print("no queue URL found")
    exit

# client object for SQS
sqs = boto3.client('sqs')
wait_time_seconds = 1

while True:
    # receive
    response = sqs.receive_message(QueueUrl=queue_url, WaitTimeSeconds=wait_time_seconds, MaxNumberOfMessages=1)
    wait_time_seconds = 20

    if 'Messages' not in response:
        continue

    # loop over all messages
    for message in response['Messages']:

        if args.debug:
            print(message)
        
        # do processing work here (example just prints)
        print("order received: ")
        order = json.loads(message['Body'])
    
        customer = order['username']
        print("\tfor: %s" % customer )

        item = order['item']
        print("\t\t%s" % item )

        made = False
        while ( True == args.wait ):
            print(' ')
            if 'y' == input('order done [y/n]...'):
                break

        print("\tdeliver to: %s" % order['hostname'])
            
        # delete once processed
        sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=message['ReceiptHandle'])
        
        print("---\n\n")
