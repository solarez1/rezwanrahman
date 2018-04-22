#
# Cookbook Name:: sdl-zabbix
# Recipe:: configure-aws-logs
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
#
# All rights reserved - Do Not Redistribute
#
# Configure AWS CLI Tools to upload PostFix Logs to CloudWatch


# Ensure Latest Version AWSLogs Is Installed
yum_package ['awslogs']  do
  action :upgrade
end

# Ensure That AWS Logs Is Enabled & Running
service 'awslogs' do
  action [:enable, :start]
end

# Configure AWS Logs
template '/etc/awslogs/awscli.conf' do
	source 'awscli.conf.erb'
	action :create
	variables(lazy do{
		region: (node['ec2']['placement_availability_zone']).sub(/(.$)/,'')
		}
	end)
	notifies :restart, 'service[awslogs]', :immediately
end

template '/etc/awslogs/awslogs.conf' do
	source 'awslogs.conf.erb'
	action :create
	variables(lazy do{
		region: (node['ec2']['placement_availability_zone']).sub(/(.$)/,''),
		interval: (node['cloudwatch']['interval'] * 1000)
		}
	end)
	notifies :restart, 'service[awslogs]', :immediately
end
