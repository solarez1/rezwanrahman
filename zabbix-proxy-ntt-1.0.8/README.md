zabbix-proxy Cookbook
=================
This Cookbook configures a Linux Centos 7 VM to act as a Zabbix Proxy Server for SDL Hosted Infrastructure.

Requirements
------------
This Cookbook has been developed against x64 Linux Centos 7 Private NTT VM; all required packages should already be installed in the VM

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
    <td><tt>['zabbix-proxy-ntt']['chef']['interval']</tt></td>
    <td>Integer</td>
    <td>The frequency (Minutes) at which CRON should execute the Chef Client</td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
</table>

Usage
-----
Just include `zabbix-proxy-ntt` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix-proxy-ntt]"
  ]
}
```

License and Authors
-------------------
Authors:

Stuart Caine - Senior Engineer : December 2017

All rights reserved SDL International Plc 2017
