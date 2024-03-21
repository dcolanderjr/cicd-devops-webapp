import json
import csv
import os
import boto3

def lambda_handler(event, context):
    # Extract relevant information from the EventBridge event
    event_detail = event['detail']
    event_name = event_detail['eventName']
    event_time = event_detail['eventTime']
    instance_id = event_detail.get('instanceId', 'N/A')
    elastic_ip = event_detail.get('elasticIp', 'N/A')

    # Define CSV file path
    csv_file_path = '/tmp/ec2_state_changes.csv'

    # Write event information to CSV file
    with open(csv_file_path, mode='a', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        # Write header if file is empty
        if os.path.getsize(csv_file_path) == 0:
            csv_writer.writerow(['Event Name', 'Event Time', 'Instance ID', 'Elastic IP'])
        # Write event information
        csv_writer.writerow([event_name, event_time, instance_id, elastic_ip])

    # Publish CSV file to SNS topic
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    sns_client = boto3.client('sns')
    with open(csv_file_path, 'rb') as file_data:
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=file_data.read(),
            Subject='EC2 State Change Notification - CSV Report'
        )

    return {
        'statusCode': 200,
        'body': json.dumps('CSV report generated and sent to SNS topic')
    }
