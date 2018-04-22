#
# Cookbook Name:: sdl-zabbix
# Recipe:: configure-zabbix
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
# All rights reserved - Do Not Redistribute
#
# Configure Zabbix per SDL requirements

# Load Node Defaults
#smtp_config = node['smtp']

# Configure Front End PHP zabbix.conf.php File
template '/etc/zabbix/web/zabbix.conf.php' do
  source 'zabbix.conf.php.erb'
  action :create
  mode '0777'
  checksum node['zabbix']['php']['checksum']
  notifies :restart, 'service[zabbix-server]', :immediately
end

# Configure Zabbix Server zabbix_server.conf File
template '/etc/zabbix/zabbix_server.conf' do
  source 'zabbix_server.conf.erb'
  action :create
  mode '0640'
  checksum node['zabbix']['server']['checksum']
  notifies :restart, 'service[zabbix-server]', :immediately
end

# Configure Zabbix Agent zabbix_agentd.conf File
template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  action :create
  mode '0644'
  checksum node['zabbix']['agent']['checksum']
  notifies :restart, 'service[zabbix-agent]', :immediately
end

# Ensure Zabbix Server and Agent Daemon Is Enabled & Started
service 'zabbix-agent' do
  action [:enable, :start]
end

service 'zabbix-server' do
  action [:enable, :start]
end

service 'zabbix-server' do
  action :nothing
end

service 'zabbix-agent' do
  action :nothing
end
