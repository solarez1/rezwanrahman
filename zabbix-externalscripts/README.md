zabbix-externalscripts Cookbook
=================
This Cookbook configures Zabbix Proxy Server to use external scripts to monitor services in AWS such as Cloudwatch alarms

Requirements
------------
This Cookbook has been developed against x64 Linux RHEL 7 Private AMI; all required packages should already be installed to the AMI

Attributes
----------

zabbix-externalscripts::default


Usage
-----
Just include `zabbix-externalscripts` in your node's `run_list` and also create a variable for externalscripts:

```json
	"default_attributes": {
		"zabbix": {
		"proxy" : {
			"conf" : "",
			"config" : "enter config folder variable (have a look in the temaplates folder, there is one for each aws region"
		}
	}
},
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix-externalscripts]"
  ]
}
```

License and Authors
-------------------
Authors:

Rezwan Rahman - Senior Engineer : January 2018

All rights reserved SDL International Plc 2018
