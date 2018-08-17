"""
Looks up a host based on its name, and then adds an item to it
Usage example: python -c "from zabbix_additem import zabbix_add_item; zabbix_add_item(username='rrahman' , hostname='test')"
"""

from pyzabbix import ZabbixAPI, ZabbixAPIException
import sys 
sys.path.insert(0,"C:\\Users\\rrahman\\Documents\\myPythonProjects\\Hipchat")
from hipchat_notify import hipchat_notify

def zabbix_add_item(zabbix_server='https://zabbix-web.sdlproducts.com/zabbix/', hostname='ZABBIXTEST-FHAR', username='rrahman', password='MyPassword'):

    # The hostname at which the Zabbix web interface is available
    ZABBIX_SERVER = zabbix_server

    zapi = ZabbixAPI(ZABBIX_SERVER)

    # Login to the Zabbix API
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
                name='Used disk space on $1 in %',
                key_='vfs.fs.size[/,pused]',
                type=0,
                value_type=3,
                interfaceid=hosts[0]["interfaces"][0]["interfaceid"],
                delay=30
            )
            item2 = zapi.item.create(
                hostid=host_id,
                name='Software Architecture Information',
                key_='system.sw.arch',
                type=0,
                value_type=3,
                interfaceid=hosts[0]["interfaces"][0]["interfaceid"],
                delay=30
            )
        except ZabbixAPIException as e:
            message = str(e)
            print(message)
            return hipchat_notify(message, 'Automation', __file__, 'red')
            sys.exit()
        print("Added item with itemid {0} to host: {1}".format(
            item["itemids"][0], host_name))
        print("Added item 2 with itemid {0} to host: {1}".format(
            item2["itemids"][0], host_name))
    else:
        message = ("No hosts found {0}".format(host_name))
        print(message)
        return hipchat_notify(message, 'Automation', __file__, 'yellow')
