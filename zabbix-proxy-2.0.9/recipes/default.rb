#
# Cookbook Name:: zabbix-proxy
# Recipe:: default
#
# Copyright 2017, SDL International Plc
# Author: Stuart Caine
#
# All rights reserved - Do Not Redistribute
#
# 

# The Frequency At Which The Chef Client Should Run (Minutes)
node.default['chef']['interval'] = 30

#Checksum values for template parameters

node.default['zabbix']['proxypsk']['checksum'] = 'ed94694dc4485a677953e72db5fa205801774d4a29d7d6b74f75df0598a23d32'

node.default['zabbix']['agent']['checksum'] = '19324e039a5538cec770053111727a25d503b213ee89b0ceb34d6b29a8f763c4'

# Invoke Recipes
include_recipe 'zabbix-proxy::install_zabbix-proxy'
include_recipe 'zabbix-proxy::configure_chef'