import sys
sys.path.insert(0, "C:\\Users\\rrahman\\Documents\\myPythonProjects\\Zabbix")
from zabbix_api_methods import *
from pprint import pprint


#Associate items with multiple instances

hosts = ['SNJTESTVM01', 'SNJCPTTEST001']
for host in hosts:
	pprint(zabbix_add_item(hostname=host, username='rrahman', password='R32wan1234',
	                    itemname='blahdeblah', key='net.if.list', ptype='0', vtype='0'))