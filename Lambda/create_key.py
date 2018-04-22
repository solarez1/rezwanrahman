from __future__ import print_function

import json
import boto3
from botocore.exceptions import ClientError

print('Loading function')

def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    token = event['query']["token"]
    #Recieve parameter from API Gateway Query String
    username = event['query']["username"]
    if username == "" or token == "":
        return ("""<br><body><h1 style="color:red;">Please make sure you do not leave username or token fields blank...</h1><br>"""
        """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
        )
    else:
        if token != "T0k3n123":
            return ("""<br><body><h1 style="color:red;">Incorrect token entered, please try again...</h1><br>"""
            """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
            )
        else:
            #Create instance of client access key
            try:
                client = boto3.client('iam')
                response = client.create_access_key(UserName=username)
                access = response['AccessKey']['AccessKeyId']
                secret =  response['AccessKey']['SecretAccessKey']

            except:
                errMessage = ("<html><head><title>Create API Key</title>"
                """<body><h1 style="color:red;">Is this a valid user "%s"? If so you cannot create your key as you already have too many keys. Use the AWS Delete API Key to delete an existing key first.</h2><br><br><br><br><br>"""
                 """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""%(username)
                )
                
                return (errMessage)
        '''###THIS CODE IS ONLY IF YOU WANT TO HOST A STATIC PAGE IN S3. THIS CAN BE USEFUL IF YOU WANT TO RESTORE A FILE FROM S3 RATHER THAN EXECUTING LAMBDA AGAIN!###
           
           #use s3 client to create file
            s3client = boto3.resource('s3')
            
            #bucket
            bucket_name = "api-key-bucket"
            
            bucket_policy = s3client.BucketPolicy(bucket_name)
            policy_payload = {
              "Version": "2012-10-17",
              "Statement": [{
                "Sid": "Allow Public Access to All Objects",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::%s/*" % (bucket_name)
              }
              ]
            }
            
            # Add the policy to the bucket
            response = bucket_policy.put(Policy=json.dumps(policy_payload))
            
            # Next we'll set a basic configuration for the static website.
            website_payload = {
                'ErrorDocument': {
                    'Key': 'error.html'
                },
                'IndexDocument': {
                    'Suffix': 'index.html'
                }
            }
            
            # Make our new S3 bucket a static website
            bucket_website = s3client.BucketWebsite(bucket_name)
            
            # And configure the static website with our desired index.html
            # and error.html configuration.
            bucket_website.put(WebsiteConfiguration=website_payload)
        
            
            s3client.Object(bucket_name, 'index.html').put(Body=message, ContentType='text/html')'''
                
        message = ("<html><head><title>API Key</title>"
               """<body><h1 style="color:blue;">Access Key:</h1>""" 
                   "<h1>%s</h1></body>"
               """<body><h1 style="color:green;">Secret Key:</h1>""" 
                   "<h1>%s</h1><br><br><br><br><br>"
                """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
               % (access, secret))
               
        return (message)
            
        '''###ONLU USE IF YOU WANT TO RETURN JSON###
        'statusCode': 200,
        'headers': { 'Content-Type': 'application/json' },
        'body': json.dumps(username)
        
        #Return Values for IAM Key, this is displayed as a list
            'Username:' : username,
            'Access Key:' : access,
            'Secret Key:' : secret'''
        
          