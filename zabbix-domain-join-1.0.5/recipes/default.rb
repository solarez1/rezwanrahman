#
# Cookbook Name:: poc_domain_join
# Recipe:: active_directory
#
# Copyright 2018, SDL Plc
#
# All rights reserved - Do Not Redistribute
#
# Rezwan Rahman: January 2018
#
# Performs Base Configuration For All SDL AWS-Based Infrastructure

#Ensure that the data bag encryption key is loaded and secure before domain join is run.
template "/etc/chef/encrypted_data_bag_secret" do
    source "encrypted_data_bag_secret.erb"
    action :create
    owner 'root'
    group 'root'
    mode  '0600'
  end

# Invoke Recipes
include_recipe 'zabbix-domain-join::active_directory'
