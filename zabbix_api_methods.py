'''

Python Module to carry out methods on the Zabbix Server

.EXAMPLES

 python -c "from zabbix_api_methods import *; zabbix_get_allhostid(username='', password='')"
 python -c "from zabbix_api_methods import *; zabbix_get_hostid(hostname='plop', username='', password='')"
 python -c "from zabbix_api_methods import *; zabbix_get_item(username='', password='',searchterm='blah')"
 python -c "from zabbix_api_methods import *; zabbix_update_item(username='', password='', item='199987', status='0')"
 python -c "from zabbix_api_methods import *; zabbix_add_item(username='', password='', itemname='blahdeblah',key='net.if.list')"
 python -c "from zabbix_api_methods import *; zabbix_get_template(hostname='Aspera-Server1',username='', password='')"
 python -c "from zabbix_api_methods import *; zabbix_search_allhostid(searchterm='',username='', password='')"
 python -c "from zabbix_api_methods import *; zabbix_search_template(hostname='COSP-QUAY-CA-ip-10-72-95-194',username='', password='', searchterm='Windows')"
 python -c "from zabbix_api_methods import *; zabbix_add_user(zabbix_server=zabbix_endpoint,userPerms='ReadOnly',userId='2_dchapelle',name='Foo',Surname='bar'))

.AUTHOR 

Rezwan Rahman


'''
import requests
from pprint import pprint
import json
from zabbix.api import *
import sys

def zabbix_login(zabbix_server, username='', password=''):

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
  print('Logged in to: {}'.format(zabbix_server))
  return (res['result'])

def zabbix_get_hostid(zabbix_server, hostname='NP-STH-01-GS-157', username='', password=''):

  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
  host_name = hostname
  url = zabbix_server + 'api_jsonrpc.php'

  headers = {
      'content-type': 'application/json',
  }

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")

  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))
  else:
    message = ("No hosts found {0}".format(host_name))
    print(message)
    #return log_file(message, 'Automation', __file__, 'true',)
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
  # pprint(res2)
  pprint("Host Id: " + res2['result'][0]['hostid'])
  pprint("hostname: " + res2['result'][0]['name'])
  return (res2['result'][0]['hostid'])


def zabbix_get_allhostid(zabbix_server, username='', password=''):

  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
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
  return(res2)

def zabbix_search_allhostid(zabbix_server, username='', password='', searchterm=''):

  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
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
          'search': {
              'name': searchterm
          },
      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()

  print('host.get response')
  pprint(res2)
  return(res2)

def zabbix_add_item(zabbix_server, hostname='NP-STH-01-GS-157', username='', password='',
                    itemname='blahdeblah', key='net.if.list', ptype='0', vtype='0'):

  #ZABBIX_SERVER = zabbix_server
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)

  host_name = hostname

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")

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
      return log_file(message, 'Automation', __file__, 'true',)
      sys.exit()
    print("Added item {0} with itemid {1} to host: {2}".format(itemname,
                                                               item["itemids"][0], host_name))
  else:
    message = ("No hosts found {0}".format(host_name))
    print(message)
    #return hipchat_notify(message, 'Automation', __file__, 'yellow')
    return log_file(message, 'Automation', __file__, 'true',)

def zabbix_get_item(zabbix_server, hostname='NP-STH-01-GS-157', username='', password='', searchterm='system'):

  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  host_name = hostname

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")

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


def zabbix_update_item(zabbix_server, username='', password='', item='12345', status='0'):
  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
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


def zabbix_delete_item(zabbix_server, username='', password='', item='12345'):
  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
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


def zabbix_get_template(zabbix_server,  username='', password='', hostname='hk'):
  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  host_name = hostname

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")
  
  if not hosts:
    print(host_name + ' does not work, please check if hostname exists and is correct')
    return

  host_id = hosts[0]["hostid"]
  print("Found host id {0} of {1}".format(host_id, host_name))

  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "template.get",
      "params": {
          "hostids":host_id,
          'output': [
              'name'],
      },
      "auth": res,
      "id": 2,
  
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()
  items = {}
  for item in res2['result']:
    items[(item['templateid'])] = (item['name'])
  pprint(items)
  return(items)

def zabbix_search_template(zabbix_server, hostname='NP-STH-01-GS-157', username='', password='', searchterm=''):
  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  host_name = hostname

  #hosts = zapi.host.get(filter={"host": host_name},
  #                      selectInterfaces=["interfaceid"])

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")
  
  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))

  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "template.get",
      "params": {
          "hostids":host_id,
          "search": {
          "name": searchterm
          },
          'output': [
              'name'],
      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()
  items = {}
  for item in res2['result']:
    items[(item['templateid'])] = (item['name'])
  pprint(items)
  pprint(hostname)
  return(items)

def zabbix_get_hostgroup(zabbix_server, hostname='NP-STH-01-GS-157', username='', password=''):
  res = zabbix_login(zabbix_server)
  zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
  #zapi.login(username, password)
  url = zabbix_server + 'api_jsonrpc.php'

  host_name = hostname

  hosts = zapi.host.get(output="extend", selectGroups="extend", selectParentTemplates="extend",search={"name": host_name}, searchWildcardsEnabled="1")

  if hosts:
    host_id = hosts[0]["hostid"]
    print("Found host id {0}".format(host_id))

  headers = {
      'content-type': 'application/json',
  }
  payload = {
      "jsonrpc": "2.0",
      "method": "hostgroup.get",
      "params": {
          "hostids":host_id,
          'output': 'extend',
      },
      "auth": res,
      "id": 2,
  }
  res2 = requests.post(url, data=json.dumps(payload), headers=headers)
  res2 = res2.json()
  return(res2)

def zabbix_add_user(zabbix_server,userPerms,userId,name,surname,username='',password=''):
  try:
    res = zabbix_login(zabbix_server)
    zapi = ZabbixAPI(url=zabbix_server,user=username,password=password)
    #zapi.login(username, password)
    url = zabbix_server + 'api_jsonrpc.php'
    
    # Administrator
    if userPerms == 'Administrator':
      if zabbix_server == 'X':
        userPerms = '7'
        usertype = '2'
      if zabbix_server == 'X':
        userPerms = '7'
        usertype = '2'
      if zabbix_server == 'X':
        userPerms = '7'
        usertype = '2'

    # Read Only
    if userPerms == 'ReadOnly':
      if zabbix_server == 'X':
        userPerms = '16'
        usertype = '1'
      if zabbix_server == 'X':
        userPerms = '17'
        usertype = '1'
      if zabbix_server == 'X':
        userPerms = '13'
        usertype = '1'

    headers = {
      'content-type': 'application/json',
    }
    payload = {
        "jsonrpc": "2.0",
        "method": "user.create",
        "params": {
        "alias": userId,
        "name": name,
        "surname": surname,
        "type": usertype,
        "passwd": password,
                "usrgrps": [
              {
                  "usrgrpid": userPerms
              }
          ],
                "user_medias": [
            {
                "mediatypeid": "1",
                "sendto": "{}@nvidia.com".format(userId),
                "active": 0,
                "severity": 63,
                "period": "1-7,00:00-24:00"
            }
        ]

        },
        "auth": res,
        "id": 2,
    }

    res2 = requests.post(url, data=json.dumps(payload), headers=headers)
    res2 = res2.json()
    print("User:{} added with UID:{} in {}".format(userId,res2['result']['userids'][0],zabbix_server))
  except: 
    print("Please check if user: {} already exists in {}.".format(userId,zabbix_server))
