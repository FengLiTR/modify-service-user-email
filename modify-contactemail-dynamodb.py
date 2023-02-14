#!/usr/bin/env python3

import boto3
import csv

def modify_email(sf_account: str, email: str, new_contact_email: str) -> bool:
    try:
        response = table.update_item(
            Key={
                'account': sf_account,
                'email': email 
            },
            UpdateExpression="set contactEmail = :val",
            ExpressionAttributeValues={':val': str(new_contact_email)}
        )
    except Exception as exp:
        print(f'Update contact email exception.')
        raise exp
    else:
        return True


if __name__ == '__main__':
    session = boto3.Session(profile_name='default')
    dynamoDB = boto3.resource('dynamodb')

    table = dynamoDB.Table('a207838-sss-user-lookup-dev')
    sf_account = 'tradmin.us-east-1'

    with open('edw-preprod-user-new-email.csv', newline='') as csvfile:
        email_reader = csv.reader(csvfile)
        for row in email_reader:
            print(row[0])
            modify_email(sf_account, row[0], row[1])
