#get all templates for all hosts by search term
import sys
sys.path.insert(0, "C:\\Users\\rrahman\\Documents\\myPythonProjects\\Zabbix")
from zabbix_api_methods import *
from pprint import pprint

searchterm = 'COS'
allhosts = (zabbix_search_allhostid(searchterm=searchterm,
                         username='user1', password='password'))
lst = []
for hosts in allhosts['result']:
	lst.append(hosts['name'])
	
for host in lst:
	zabbix_get_template(zabbix_server='https://zabbixurl', 
		username='user1', password='password', hostname=host)
