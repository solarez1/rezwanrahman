#!/usr/bin/env python

from __future__ import print_function
import requests
import sys
import json
import datetime

def hipchat_notify(token, room, message, color='yellow', notify=False,
                   format='text', host='api.hipchat.com'):
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

    example: python -c "from hipchat_notify import hipchat_notify; hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', 'From py blah blah blah', 'red')"
    """

    if len(message) > 1000:
        error = ValueError('Message too long')
        print(error)
        return log_file(error, 'true')
    if format not in ['text', 'html']:
        error = ValueError("Invalid message format '{0}'".format(format))
        print(error)
        return log_file(error, 'true')
    if color not in ['yellow', 'green', 'red', 'purple', 'gray', 'random']:
        error = ValueError("Invalid color {0}".format(color))
        print(error)
        return log_file(error, 'true')
    if not isinstance(notify, bool):
        error = TypeError("Notify must be boolean")
        print(error)
        return log_file(error, 'true')
    if message == Exception:
        print(message)
        return log_file(message, 'true')
   
    url = "https://{0}/v2/room/{1}/notification".format(host, room)
    headers = {'Content-type': 'application/json'}
    headers['Authorization'] = "Bearer " + token
    payload = {
        'message': message,
        'notify': notify,
        'message_format': format,
        'color': color
    }
    r = requests.post(url, data=json.dumps(payload), headers=headers)
    r.raise_for_status()

def log_file(message, *log):
    if not log:
        print(message)
    else:
        now = datetime.datetime.now()
        createtime = now.strftime("%Y-%m-%d")
        file = "c:/pyerror/errorlog-%s.txt" %createtime
        f = open(file, "a+")
        out = '%s \n' %message
        f.write(out)
        f.close

'''
try:
    hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', 'From Python')
except Exception as e:
        msg = "[ERROR] HipChat notify failed: '{0}'".format(e)
        print(msg, file=sys.stderr)
        sys.exit(1)
'''