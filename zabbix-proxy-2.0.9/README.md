zabbix-proxy Cookbook
=================
This Cookbook configures a Linux RHEL 7 AMI to act as a Zabbix Proxy Server for SDL Hosted Infrastructure.

Requirements
------------
This Cookbook has been developed against x64 Linux RHEL 7 Private AMI; all required packages should already be installed to the AMI

Attributes
----------

zabbix-proxy::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['zabbix-proxy']['chef']['interval']</tt></td>
    <td>Integer</td>
    <td>The frequency (Minutes) at which CRON should execute the Chef Client</td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
</table>

Usage
-----
Just include `zabbix-proxy` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix-proxy]"
  ]
}
```

License and Authors
-------------------
Authors:

Stuart Caine - Senior Engineer : October 2017

All rights reserved SDL International Plc 2017
