zabibx-domain-join Cookbook
=====================
Performs Domain Configuration For All SDL Zabbix Servers

=> Targets DNS Servers in corresponding Shared Infrastructure VPC for AWS Region
=> Joins Instances to SDLProducts Active Directory
=> Enables SSH via SDLProducts Credentials instead of private keys

Requirements
------------
### Community Cookbooks:


#### Gems


Attributes
----------

#### sdl_aws_base::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['aws']['ad_domain']</tt></td>
    <td>String</td>
    <td>Name of the Active Directory Forest to join</td>
    <td><tt>sdlproducts.com</tt></td>
  </tr>
  <tr>
    <td><tt>['aws']['ad_join_user']</tt></td>
    <td>String</td>
    <td>Name of the Active Directory account used to perform the domain join</td>
    <td><tt>ServiceZabbixJoin</tt></td>
  </tr>
  <tr>
</table>

Usage
-----
#### zabbix-domain-join::default

Just include `zabbix-domain-join` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabibxdomain-join]"
  ]
}
```


License and Authors
-------------------
Authors:

-Stuart Caine (scaine@sdl.com) - Senior Engineer
