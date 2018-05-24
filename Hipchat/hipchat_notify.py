#!/usr/bin/env python
"""Send notification to a HipChat room via API version 2

Parameters
----------
token : str
    HipChat API version 2 compatible token (room or user token)
room: str
    Name or API ID of the room to notify
message: str
    Message to send to room
color: str, optional
    Background color for message, defaults to yellow
    Valid values: yellow, green, red, purple, gray, random
notify: bool, optional
    Whether message should trigger a user notification, defaults to False
format: str, optional
    Format of message, defaults to text
    Valid values: text, html
host: str, optional
    Host to connect to, defaults to api.hipchat.com

example: 
python -c "from hipchat_notify import hipchat_notify; hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', 'From py blah blah blah','Automation','red')"
"""

from __future__ import print_function
import requests
import sys
import json
import datetime
import os
import csv

def hipchat_notify(token, room, message, owner, file, color='purple', notify=False,
                   format='text', host='api.hipchat.com'):

    owners = ['Automation', 'Database', 'Platform', 'Custom']
    if owner not in owners:        
        error = ValueError("Invalid Owner. Expected one of: {0}".format(owners))
        print(error)
        return log_file(error, owner, file, 'true',)
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
        output = ( 'Error: ' + message + ' From: ' + script)
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
