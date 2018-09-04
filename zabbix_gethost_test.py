import sys
sys.path.insert(0, "C:\\Users\\rrahman\\Documents\\myPythonProjects\\Zabbix")
from zabbix_api_methods import *
from pprint import pprint

pprint(zabbix_get_hostid(hostname='DUBFTP01',
                         username='rrahman', password='R32wan1234'))

#pprint(zabbix_get_allhostid(username='rrahman', password='R32wan1234'))
#pprint(zabbix_get_item(username='rrahman', password='R32wan1234', searchterm='system'))
