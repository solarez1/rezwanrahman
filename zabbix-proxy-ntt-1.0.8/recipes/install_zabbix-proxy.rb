#
# Cookbook Name:: zabbix-proxy-ntt
# Recipe:: install_zabbix-proxy.rb
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman

# All rights reserved - Do Not Redistribute
#
# Configures Zabbix Proxy per SDL requirements

service 'zabbix-agent' do
  action :nothing
end

service 'corosync' do
  action :nothing
end


# Configure Zabbix Proxy zabbix_proxy.conf File
template '/etc/zabbix/zabbix_proxy.conf' do
	source node['zabbix']['proxy']['conf']
	action :create
  	mode '0644'
    checksum node['zabbix']['proxy']['checksum']
  notifies :restart, 'service[corosync]', :immediately
end

# Configure Zabbix Agent zabbix_agent.conf File
template '/etc/zabbix/zabbix_agentd.conf' do
  source node['zabbix']['agent']['conf']
  action :create
  mode '0644'
  checksum node['zabbix']['agent']['checksum']
  notifies :restart, 'service[zabbix-agent]', :immediately
end

# Configure Zabbix Proxy zabbix_proxy.psk File
template '/etc/zabbix/zabbix_proxy.psk' do
  source 'zabbix_proxy.psk.erb'
  action :create
  owner 'zabbix'
  group 'zabbix'
  mode '0770'
  checksum node['zabbix']['proxypsk']['checksum']
end

# Ensure zabbix Agent service Is Enabled & Started
service 'zabbix-agent' do
  action [:enable, :start]
end


