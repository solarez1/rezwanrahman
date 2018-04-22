sdl-zabbix Cookbook
=================
This Cookbook configures a Private Amazon Linux AMI to act as a Monitoring Server for SDL Hosted Infrastructure.

Requirements
------------
This Cookbook has been developed against x64 Amazon Private AMI based on RHEL 7.4; all required packages are retrieved by Chef

Attributes
----------

sdl-zabbix::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['sdl-zabbix']['chef']['interval']</tt></td>
    <td>Integer</td>
    <td>The frequency (Minutes) at which CRON should execute the Chef Client</td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
    <td><tt>['sdl-zabbix']['cloudwatch']['interval']</tt></td>
    <td>Integer</td>
    <td>The frequency (Minutes) at which Logs & Metrics Are Uploaded To CloudWatch</td>
    <td><tt>5</tt></td>
  </tr>
</table>

Usage
-----
Just include `sdl-zabbix` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[sdl-zabbix]"
  ]
}
```

License and Authors
-------------------
Authors:

Rezwan Rahman: November 2017

All rights reserved SDL International Plc 2017
