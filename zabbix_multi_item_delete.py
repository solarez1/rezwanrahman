import sys
sys.path.insert(0, "C:\\Users\\rrahman\\Documents\\myPythonProjects\\Zabbix")
from zabbix_api_methods import *
from pprint import pprint

#Delete multiple items using dictonary

items = {}
searchterm = 'blahdeblah'
for host in hosts:	
	items[host] = (zabbix_get_item(hostname=host, username='rrahman', password='R32wan1234', searchterm=searchterm))
	del_item = (items[host][searchterm])
	pprint(zabbix_delete_item(username='rrahman', password='R32wan1234', item=del_item))
