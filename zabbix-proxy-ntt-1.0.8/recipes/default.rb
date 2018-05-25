#
# Cookbook Name:: zabbix-proxy-ntt
# Recipe:: default
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
#
# All rights reserved - Do Not Redistribute
#
# 

# The Frequency At Which The Chef Client Should Run (Minutes)
node.default['chef']['interval'] = 30

#Checksum values for template parameters

node.default['zabbix']['proxypsk']['checksum'] = 'ed94694dc4485a677953e72db5fa205801774d4a29d7d6b74f75df0598a23d32'

# Invoke Recipes
include_recipe 'zabbix-proxy-ntt::install_zabbix-proxy'
include_recipe 'zabbix-proxy-ntt::configure_chef'
