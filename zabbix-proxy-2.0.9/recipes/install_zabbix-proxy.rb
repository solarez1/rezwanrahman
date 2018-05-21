#
# Cookbook Name:: zabbix-proxy
# Recipe:: install_zabbix-proxy.rb
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
#
# All rights reserved - Do Not Redistribute
#
# Install & configure Zabbix Proxy per SDL requirements

# Configure Zabbix Proxy zabbix_proxy.conf File
template '/etc/zabbix/zabbix_proxy.conf' do
	source node['zabbix']['proxy']['conf']
	action :create
  mode '0644'
  notifies :restart, 'service[zabbix-proxy]', :immediately
  checksum node['zabbix']['proxy']['checksum']
end

# Configure Zabbix Agent zabbix_agent.conf File
template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  action :create
  mode '0644'
  notifies :restart, 'service[zabbix-agent]', :immediately
  checksum node['zabbix']['agent']['checksum']
end

# Configure Zabbix Proxy zabbix_proxy.psk File
template '/etc/zabbix/zabbix_proxy.psk' do
  source 'zabbix_proxy.psk.erb'
  action :create
  owner 'zabbix'
  group 'zabbix'
  mode '0770'
  notifies :restart, 'service[zabbix-proxy]', :immediately
  checksum node['zabbix']['proxypsk']['checksum']
end

# Ensure zabbix Proxy service Is Enabled & Started
service 'zabbix-proxy' do
  action [:enable, :start]
end

service 'zabbix-proxy' do
  action :nothing
end

# Ensure zabbix Agent service Is Enabled & Started
service 'zabbix-agent' do
  action [:enable, :start]
end

service 'zabbix-agent' do
  action :nothing
end
