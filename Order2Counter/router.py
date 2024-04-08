import boto3
import json

from common import * 

stack_name = 'order2Counter'
cf_client = boto3.client('cloudformation')
response = cf_client.describe_stacks(StackName=stack_name)
outputs = response["Stacks"][0]["Outputs"]

# Queue setup
queue_url = cf_output(outputs, "dumbellqurl")
sqs = boto3.client("sqs")

# audit table setup
audit_table_name = cf_output(outputs, 'audittablename')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(audit_table_name)

def handle_order(event, context):

    # info from event
    username = event['username']
    hostname = event['hostname']
    item = event['item']

    # queue the order for dispatch
    sqs.send_message(QueueUrl=queue_url, MessageBody=json.dumps(event))

    # save to the audit table
    table.put_item( Item=event )
    
    # reponse
    response = {
        "status": "accepted"
        }

    return response
