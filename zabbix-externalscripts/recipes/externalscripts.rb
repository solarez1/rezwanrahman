#
# Cookbook Name:: zabbix-externalscripts
# Recipe:: externalscripts.rb
#
# Copyright 2018, SDL International Plc
# Author: Stuart Caine
#
# All rights reserved - Do Not Redistribute
#
# Configure Zabbix Proxy for external scripts per SDL requirements
# 
service 'zabbix-proxy' do
  action :nothing
end
#Create the external scripts directory
directory "/etc/zabbix/externalscripts" do
  owner 'zabbix'
  group 'zabbix'
  mode  '0770'
  action :create
  not_if {::Dir.exists?("/etc/zabbix/externalscripts")} 
end
#
#Create directory for AWS config file - this is used to add profiles (so you can add region, access keys, role arn's in your parameters)
directory "/etc/zabbix/.aws/" do
  owner 'zabbix'
  group 'zabbix'
  mode  '0770'
  action :create
  not_if {::Dir.exists?("/etc/zabbix/.aws")} 
end
#
#This will add the relevant config file to the proxy. The source will be defined in the proxies role.
template "/etc/zabbix/.aws/config" do
  source node['zabbix']['proxy']['config']
  owner 'zabbix'
  group 'zabbix'
  mode '0770'
  action :create
  notifies :restart, 'service[zabbix-proxy]', :immediately
  end
#
# This crerates a variable which wil loop through below and add them to the proxy external scripts directory
config_files = ['cwalarms.py',
                'checkcwalarm.sh',
                'checkallcwalarms.sh',
                'checkallcwalarmsprefix.sh']
#
#
config_files.each do |file|
template "/etc/zabbix/externalscripts/#{file}" do
	source "#{file}.erb"
	owner 'zabbix'
  group 'zabbix'
  mode  '0770'
	action :create
  notifies :restart, 'service[zabbix-proxy]', :immediately
  end
end