#!/usr/bin/env python
'''Send notification to a HipChat room via API version 2 and MS Teams

example: 
For HipChat:
python -c "from hipchat_notify import *; hipchat_notify('From py blah blah blah','Automation','red')"

For MS Teams:
python -c "from hipchat_notify import *; msteams_notify('From py blah blah blah','Automation','Error')"
'''

from __future__ import print_function
import requests
import sys
import json
import datetime
import os
import csv

def hipchat_notify(message, owner, file, color='purple', notify=False,
                   format='text', host='api.hipchat.com'):

    owners = ['Automation', 'Database', 'Platform', 'Custom', 'GCT', 'EPTP']
    if owner not in owners:        
        error = ValueError("Invalid Owner. Expected one of: {0}".format(owners))
        print(error)
        return log_file(error, owner, file, 'true',)
    if owner == 'Automation':
        token = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
        room = 'LoggingTest'
    if owner == 'Database':
        token = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
        room = 'Database - Logging Test'
    if owner == 'Platform':
        token = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
        room = 'Database - Logging Test'
    if owner == 'Custom': 
        token = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
        room = 'Database - Logging Test'
    if owner == 'GCT':
        token = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
        room = 'Database - Logging Test'
    if owner == 'EPTP':
        token = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
        room = 'Database - Logging Test'        
    if len(message) > 1000:
        error = ValueError('Message too long')
        print(error)
        return log_file(error, owner, file, 'true',)
    if format not in ['text', 'html']:
        error = ValueError("Invalid message format '{0}'".format(format))
        print(error)
        return log_file(error, owner, file, 'true',)
    if color not in ['yellow', 'green', 'red', 'purple', 'gray', 'random']:
        error = ValueError("Invalid color {0}".format(color))
        print(error)
        return log_file(error, owner, file, 'true',)
    if not isinstance(notify, bool):
        error = TypeError("Notify must be boolean")
        print(error)
        return log_file(error, owner, file, 'true',)
    else:
        script = script_name(owner, file)
        print (message + ' ' + script)
        output = ( 'Message: ' + message + ' From: ' + script)
        url = "https://{0}/v2/room/{1}/notification".format(host, room)
        headers = {'Content-type': 'application/json'}
        headers['Authorization'] = "Bearer " + token
        payload = {
            'message': output,
            'notify': notify,
            'message_format': format,
            'color': color
        }
        r = requests.post(url, data=json.dumps(payload), headers=headers)
        r.raise_for_status()
        return log_file(message, owner, file, 'true',)

def msteams_notify(message, owner, file, color='Information', notify=False, format='text',
                   host='outlook.office.com'):
    owners = ['Automation', 'Database', 'Platform', 'Custom', 'GCT', 'EPTP']
    if owner not in owners:        
        error = ValueError("Invalid Owner. Expected one of: {0}".format(owners))
        print(error)
        return log_file(error, owner, file, 'true',)
    if owner == 'Automation':
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if owner == 'Database':
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if owner == 'Platform':
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if owner == 'Custom': 
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if owner == 'GCT':
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if owner == 'EPTP':
        webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
        incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
    if len(message) > 1000:
        error = ValueError('Message too long')
        print(error)
        return log_file(error, owner, file, 'true',)
    if format not in ['text', 'html']:
        error = ValueError("Invalid message format '{0}'".format(format))
        print(error)
        return log_file(error, owner, file, 'true',)
    if color not in ['Information', 'Error', 'Warning']:
        error = ValueError("Invalid color {0}".format(color))
        print(error)
        return log_file(error, owner, file, 'true',)
    if color == 'Error':
        color = '#A00000'
        title = 'Error'
    if color == 'Warning':
        color = '#A0A000'
        title = 'Warning'
    if color == 'Information':
        color = '#00A000'
        title = 'Information'
    if not isinstance(notify, bool):
        error = TypeError("Notify must be boolean")
        print(error)
        return log_file(error, owner, file, 'true',)
    else:
        script = script_name(owner, file)
        output = ( 'Message: ' + message + '\n' + 'From: ' + script)
        url = "https://{0}/webhook/{1}/IncomingWebhook/{2}".format(host, webhook, incomingwebhook)
        headers = {'Content-type': 'application/json'}
        payload = {
            "@type": "MessageCard",
            "@context": "http://schema.org/extensions",
            "themeColor": color,
            "title": title,
            "text": output
        }
        r = requests.post(url, data=json.dumps(payload), headers=headers)
        r.raise_for_status()
        return log_file(message, owner, file, 'true',)

def log_file(message, owner, file, *log, path='c:/errorlogging/'):
    if not log:
        print(message)
    else:
        now = datetime.datetime.now()
        createtime = now.strftime("%Y-%m-%d")
        filetxt = path + "errorlog-%s.txt" %createtime
        print(filetxt)
        f = open(filetxt, 'a+')
        out = '%s \n' %message
        f.write(out)
        f.close
        script = script_name(owner,file)
        filecsv = path + "errorlog-%s.csv" %createtime
        time = now.strftime("%Y%m%d-%X")
        print(time)
        print(filecsv)
        with open(filecsv, 'a+', newline='') as csvfile:
            filewriter = csv.writer(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
            #filewriter.writerow(['Time','Message','Script'])
            filewriter.writerow([time,message,script])

def script_name(owner, file):
    #script = os.path.realpath(os.path.dirname(sys.argv[0])) #Shows just path to directory of script
    script = "%s"%file
    environ = os.environ['COMPUTERNAME']
    return script + ' On Machine: ' + environ + ' Owned By: ' + owner


'''
try:
    hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', 'From Python')
except Exception as e:
        msg = "[ERROR] HipChat notify failed: '{0}'".format(e)
        print(msg, file=sys.stderr)
        sys.exit(1)
'''