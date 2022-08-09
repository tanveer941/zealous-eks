import boto3
from botocore.exceptions import ClientError
import os

def configure_aws_credentials():
    # Check for other means of providing credentials before using profile
    if 'AWS_ACCESS_KEY_ID' not in os.environ:
        os.environ['AWS_PROFILE'] = 'default'

def check_dynamodb_exists():
    # Configure AWS credentials from profile
    configure_aws_credentials()
    dynamodb_client = boto3.client('dynamodb', region_name="us-east-1")
    table_name = 'zealous'
    try:
        dynamodb_client.describe_table(
            TableName=table_name
        )
        print('DynamoDB table: ' + table_name + ' exists')
    except ClientError as err:
        if err.response['Error']['Code'] != 'ResourceNotFoundException':
            raise
        print('Creating DynamoDB table: ' + table_name + '...')
        dynamodb_client.create_table(
            TableName=table_name,
            KeySchema=[
                {
                    'AttributeName': 'LockID',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'LockID',
                    'AttributeType': 'S'
                }
            ],
            BillingMode='PAY_PER_REQUEST',
            SSESpecification={
                'Enabled': True
            },
            Tags=[
                {
                    'Key': 'adsk:moniker',
                    'Value': 'ICMPE-C-UE1'
                },
                {
                    'Key': 'owner_name',
                    'Value': 'icm_pe'
                },
                {
                    'Key': 'group_name',
                    'Value': 'icm'
                }
            ]

        )
        waiter = dynamodb_client.get_waiter('table_exists')
        waiter.wait(
            TableName=table_name,
            WaiterConfig={
                'Delay': 5,
                'MaxAttempts': 10
            }
        )

if __name__ == "__main__":
    check_dynamodb_exists()