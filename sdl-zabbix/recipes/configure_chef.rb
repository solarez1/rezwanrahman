#
# Cookbook Name:: sdl-zabbix
# Recipe:: configure-chef
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
#
# All rights reserved - Do Not Redistribute
#
# Configure CRON job to run Chef Client on a schedule
# Maintain a CRON Job To Run Chef Periodically
# Specify environment variables
my_env_vars = {"PATH" => "/usr/bin:/usr/local/bin"}  

cron 'chef_client' do
  environment my_env_vars
  minute "*/#{node['chef']['interval']}"
  command "bash /etc/chef/run-chef-client.sh"
end