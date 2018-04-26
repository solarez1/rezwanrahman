#
# Cookbook Name:: zabbix-agent-install
# Recipe:: default

#zabbix agent install
#
# All rights reserved - Do Not Redistribute
#
#
aws_region = node.default['aws']['region']
#
#
#
#
if node['platform'] == 'windows'
	require 'win32/service'
	service 'zabbix agent' do
		action :nothing
	end
# This command must be run after install rather than just starting process
	execute 'zabbix agent' do
		cwd	"c:/program files/zabbix/bin/win64"
		command 'zabbix_agentd.exe --start'
		action :nothing
	end
	cookbook_file 'C:/chef/zabbix.zip' do
		source "zabbix.zip"
		action :create
		not_if {::File.exists?("C:/chef/zabbix_agent-3-4-win.zip")}
	end
	windows_zipfile 'zabbix.zip' do
  		source 'c:/chef/zabbix.zip'
  		action :unzip
  		path 'C:/program files/'
  		overwrite true
  		not_if { ::Win32::Service.exists?("zabbix agent") }
  	end
# Configure Zabbix Agent zabbix_agent.conf File (pre-install)
	template 'c:/program files/zabbix/zabbix_agentd.conf' do
  		source 'zabbix_agentd.win.conf.erb'
  		variables hostmetadata: node['zabbix']['hostmetadata'],zabbixserver: node['aws']['zabbixproxymap'][aws_region][:zabbix_proxy]
  		action :create
  		not_if { ::Win32::Service.exists?("zabbix agent") }
	end
	windows_package 'zabbix-agent' do
		installer_type :custom
		options '--config "c:/program files/zabbix/zabbix_agentd.conf" --install'
		source "c:/program files/zabbix/bin/win64/zabbix_agentd.exe"
		action :install
		notifies :run, 'execute[zabbix agent]', :immediately
		not_if { ::Win32::Service.exists?("zabbix agent") }
	end
#
#
# This maintains desired state of Zabbix Agent zabbix_agent.conf File
	template 'c:/program files/zabbix/zabbix_agentd.conf' do
  		source 'zabbix_agentd.win.conf.erb'
  		variables hostmetadata: node['zabbix']['hostmetadata'],zabbixserver: node['aws']['zabbixproxymap'][aws_region][:zabbix_proxy]
  		action :create
		notifies :restart, 'service[zabbix agent]', :delayed
	end
# Make sure the Zabbix Agent service is enabled and started
	service 'zabbix agent' do
		action [:enable, :start]
	end
end
#
#
#
#
case node['platform'] 
when 'redhat', 'centos', 'amazon'
	service 'zabbix-agent' do
  		action :nothing
  	end
	execute 'install zabbix pre-req' do
		command "rpm -Uvh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm"
		not_if 'rpm -qa | grep zabbix-release-3.4-2.el7.noarch'
	end
	yum_package 'zabbix-agent' do
		action :install
		not_if 'rpm -qa | grep zabbix-agent'
	end
# Configure Zabbix Agent zabbix_agent.conf File
	template '/etc/zabbix/zabbix_agentd.conf' do
  		source 'zabbix_agentd.conf.erb'
  		action :create
  		mode '0644'
		variables hostmetadata: node['zabbix']['hostmetadata'],zabbixserver: node['aws']['zabbixproxymap'][aws_region][:zabbix_proxy]
		notifies :restart, 'service[zabbix-agent]', :immediately
	end
	# Ensure zabbix Agent service Is Enabled & Started
	service 'zabbix-agent' do
  		action [:enable, :start]
	end
end
