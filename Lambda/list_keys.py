import boto3
import json

def lambda_handler(event, context):
    # TODO implement
	client = boto3.client('iam')
	paginator = client.get_paginator('list_access_keys')
	username = event['query']["username"]
	token = event['query']["token"]
	if username == "" or token	== "":
		return ("""<br><body><h1 style="color:red;">Please make sure you do not leave username or token fields blank...</h1><br>"""
		"""<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
		)
	else:
		if token != "T0k3n123":
			return ("""<br><body><h1 style="color:red;">Incorrect token entered, please try again...</h1><br>"""
			"""<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
			)
		else:
			try:
				for response in paginator.paginate(UserName=username):
					keycount = 0
					my_list = []
					count = response['AccessKeyMetadata']
					for a in count:				
						my_list.append(a['AccessKeyId'])
						my_list.append(a['Status'])
						keycount+=1
			except BaseException:
				return ("""<br><br><html><h1 style="color:red;">Oops! Are you sure the username "%s" is correct?<h1><br><br><br>"""
				"""<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
				) %(username)
			output = "There is {} Access Keys for {} user".format(keycount,username)
			
			message = ("<html><head><title>These are keys for %s</title></head>"
		           """<body><h1 style="color:blue;">Keys:</h1>""" 
		               "<h1>%s</h1></body>"
		           """<body><h1 style="color:green;">Key Count:</h1>""" 
		               "<h1>%s</h1><br><br><br><br><br>"
		               """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
		           % (username, my_list, output))
		
			''' This is for JSON output.
			return {
					    'Keys': my_list,
					    'Key Count:' : output
				   }
			'''
			return (message)