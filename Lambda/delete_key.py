import json
import boto3

def lambda_handler(event, context):
    # TODO implement
	username = event['query']["username"]
	accesskeyid = event['query']["keyid"]
	token = event['query']["token"]
	try:
		if username == "" or accesskeyid == "" or token == "":
			return ("""<br><body><h1 style="color:red;">Please make sure you do not leave username, token or key fields blank...</h1><br>"""
			"""<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
			)
	except:
		return("Something has gone terribly wrong!")
	else:
		if token != "T0k3n123":
		   return ("""<br><body><h1 style="color:red;">Incorrect token entered, please try again...</h1><br>"""
		   """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
		   )
		    
		else:
			client = boto3.client('iam')
			try:
				response = client.delete_access_key(
					AccessKeyId=accesskeyid,
					UserName=username
					)
				result = (response['ResponseMetadata']['HTTPStatusCode'])
				#key = accesskeyid
				#msg = "Deleted key {} successfully with HTTP: {}".format(key,result)
				
				message = ("<html><head><title>Delete Key</title>"
				"""<body><h1 style="color:Black;">Deleted Key:</h1><h1 style="color:red;">%s</h1><h1>successfully with HTTP: %s</h1><br><br><br><br><br>"""
				"""<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
				% (accesskeyid, result))
				
				if (result) == 200:
					return(message)
						#return{'Message' : msg}
			except:
				       
				errMessage = ("<html><head><title>Delete Key</title>"
		        """<br><br><h1 style="color:red">An error occurred, did you enter the right username "%s"? maybe the key "%s" doesn't exist anymore? Run AWS List API Keys to see if the key was deleted already!</h1><br><br><br><br><br>"""
		        """<center><button onclick="window.location.replace('https://s3-eu-west-1.amazonaws.com/api-key-bucket/APIGateway.html')">Go Back</button></center></body></html>"""
		        % (username,accesskeyid))
				return(errMessage)
				
				
			'''	return{
				'ErrMessage' : "An error occurred, maybe the key doesn't exist anymore? Run AWS List API Keys to see if the key has been deleted already!"
			}
			'''