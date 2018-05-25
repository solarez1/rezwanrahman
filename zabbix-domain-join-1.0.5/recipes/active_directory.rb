#
# Cookbook Name:: poc_domain_join
# Recipe:: active_directory
#
# Copyright 2018, SDL Plc
#
# All rights reserved - Do Not Redistribute
#
# Rezwan Rahman : October 2016
#
# Joins AWS-based Instances to SDLPRODUCTS Active Directory, and places the Instance into the correct Regional OU

# Leverage ad-join Cookbook (https://supermarket.chef.io/cookbooks/ad-join) To Join Windows Nodes To AD
aws_region = node['aws']['region']

# For Linux, Use SDL Cookbook
if node['platform'] == 'redhat'
  domain_join_zabbix node['aws']['ad_domain'] do
    domain         	node['aws']['ad_domain']
    domain_user    	node['aws']['ad_join_user']
    server	node['aws']['ad_servers_map'][aws_region][:primary_dc_name] + '.' + node['aws']['ad_domain']
    ou node['aws']['ad_servers_map'][aws_region][:linux_ou]
  end
end
