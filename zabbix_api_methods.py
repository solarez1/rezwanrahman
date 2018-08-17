'''

Python Module to carry out methods on the Zabbix Server

.EXAMPLES

 python -c "from zabbix_api_methods import *; zabbix_get_allhostid()"
 python -c "from zabbix_api_methods import *; zabbix_get_hostid(hostname='plop')"
 python -c "from zabbix_api_methods import *; zabbix_get_item(searchterm='blah')"
 python -c "from zabbix_api_methods import *; zabbix_update_item(item='199987', status='0')"
 python -c "from zabbix_api_methods import *; zabbix_add_item(itemname='blahdeblah',key='net.if.list')"

.AUTHOR 

Rezwan Rahman

'''
import requests
from pprint import pprint
import json
from pyzabbix import ZabbixAPI, ZabbixAPIException
import sys
sys.path.insert(0, "C:\\Users\\rrahman\\Documents\\myPythonProjects\\Hipchat")
from hipchat_notify import *


def zabbix_login(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', username='', password=''):

  ZABBIX_ROOT = zabbix_server
  url = ZABBIX_ROOT + 'api_jsonrpc.php'

  payload = {
      "jsonrpc": "2.0",
      "method": "user.login",
      "params": {
          'user': username,
          'password': password,
      },
      "auth": None,
      "id": 0,
  }
  headers = {
      'content-type': 'application/json',
  }
  res = requests.post(url, data=json.dumps(payload), headers=headers)
  res = res.json()
  print('user.login response')
  pprint(res)
  return (res['result'])


def zabbix_get_hostid(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', hostname='SNJCPTTEST001', username='', password=''):

  res = zabbix_login(username=username, password=password)
  zapi = ZabbixAPI(zabbix_server)
  zapi.login(username, password)
  host_name = hostname
  url = zabbix_server + 'api_jsonrpc.php'

  headers = {
      'content-type': 'application/json',
  }

  hosts = zapi.host.get(filter={"host": host_name},
                        selectInterfaces=["interfaceid"])
  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))
  else:
    message = ("No hosts found {0}".format(host_name))
    print(message)
    hip = hipchat_notify(message, 'Automation', __file__, 'red')
    ms = msteams_notify(message, "Automation", __file__, color='Error', notify=False, format='text',
                 host='outlook.office.com')
    return hip,ms
    sys.exit(message)
  payload = {
      "jsonrpc": "2.0",
      "method": "host.get",
      "params": {
          'hostids': (host_id),
          'output': [
              'hostid',
              'name'],

      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()

  print('host.get response')
  #pprint(res2)
  pprint("Host Id: " + res2['result'][0]['hostid'])
  pprint("hostname: " + res2['result'][0]['name'])
  return (res2['result'][0]['hostid'])


def zabbix_get_allhostid(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', username='', password=''):

  res = zabbix_login(username=username, password=password)
  zapi = ZabbixAPI(zabbix_server)
  zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "host.get",
      "params": {
          'output': [
              'hostid',
              'name'],

      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()

  print('host.get response')
  pprint(res2)


def zabbix_add_item(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', hostname='SNJCPTTEST001', username='', password='',
                    itemname='blahdeblah', key='net.if.list', ptype='0', vtype='0'):

  ZABBIX_SERVER = zabbix_server

  zapi = ZabbixAPI(ZABBIX_SERVER)

  zapi.login(username, password)

  host_name = hostname

  hosts = zapi.host.get(filter={"host": host_name},
                        selectInterfaces=["interfaceid"])
  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))

    try:
      item = zapi.item.create(
          hostid=host_id,
          name=itemname,
          key_=key,
          type=ptype,
          value_type=vtype,
          interfaceid=hosts[0]["interfaces"][0]["interfaceid"],
          delay=30
      )
    except ZabbixAPIException as e:
      message = str(e)
      print(message)
      hip = hipchat_notify(message, 'Automation', __file__, 'red')
      ms = msteams_notify(message, "Automation", __file__, color='Error', notify=False, format='text',
                   host='outlook.office.com')
      return hip,ms
      sys.exit()
    print("Added item {0} with itemid {1} to host: {2}".format(itemname,
                                                               item["itemids"][0], host_name))
  else:
    message = ("No hosts found {0}".format(host_name))
    print(message)
    return hipchat_notify(message, 'Automation', __file__, 'yellow')


def zabbix_get_item(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', hostname='SNJCPTTEST001', username='', password='', searchterm='system'):

  res = zabbix_login(username=username, password=password)
  zapi = ZabbixAPI(zabbix_server)
  zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  host_name = hostname

  hosts = zapi.host.get(filter={"host": host_name},
                        selectInterfaces=["interfaceid"])
  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))

  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "item.get",
      "params": {
          "output": "extend",
          "hostids": host_id,
          "search": {
              "name": searchterm
          },
          "sortfield": "name"
      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()

  items = {}
  for item in res2['result']:
    items[(item['name'])] = (item['itemid'])
  pprint(items)
  return (items)

def zabbix_update_item(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', username='', password='', item='12345', status='0'):
  res = zabbix_login(username=username, password=password)
  zapi = ZabbixAPI(zabbix_server)
  zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'
  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "item.update",
      "params": {
          "itemid": item,
          "status": status
      },
      "auth": res,
      "id": 1,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()
  pprint(res2)


def zabbix_delete_item(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', username='', password='', item='12345'):
  res = zabbix_login(username=username, password=password)
  zapi = ZabbixAPI(zabbix_server)
  zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'
  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "item.delete",
      "params": [
          item
      ],
      "auth": res,
      "id": 1,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()
  pprint(res2)
