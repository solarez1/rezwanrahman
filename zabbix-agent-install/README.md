# zabbix-agent-deploy Cookbook

Performs installation of the zabbix agent in the sdlproducts.com domain. 



### Platforms

Linux RedHat, Windows

### Chef

- Chef 12.0 or later

### Cookbooks

- `windows_package` - zabbix-agent-deploy needs windows_package to install and unzip zabbix.zip.

## Attributes

TODO: List your cookbook attributes here.

e.g.
### zabbix-agent-install::default

## Usage
include zabbix-agent-deploy in the runlist
  "run_list": [
    "recipe[zabbix-agent-install]"
  ]

 Also if you are required to add create a value for Hostmetadata in your Chef role

 	"default_attributes": {
		"zabbix": {
		"hostmetadata" : {
			"<enter value here>"
		}
	}
},


## License and Authors

v1.0.0 - Stuart Caine - February 2018