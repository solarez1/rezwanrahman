#
# Cookbook Name:: sdl-zabbix
# Recipe:: default
#
# Copyright 2017, SDL International Plc
# Author: Rezwan Rahman
#
# All rights reserved - Do Not Redistribute
#
#
# Declare Node Defaults

# The Frequency At Which The Chef Client Should Run (Minutes)
node.default['chef']['interval'] = 5

# The Frequency At Which Logs & Metrics Are Uploaded To CloudWatch (Minutes)
node.default['cloudwatch']['interval'] = 5

# The Threshold At Which CloudWatch Will Alarm On The Size Of The Mail Queue
# (If the queue is larger than this on any Node, CW will alert the SNS Topic)
node.default['cloudwatch']['alarm'] = 1000

#File Check Sum
node.default['zabbix']['server']['checksum'] = 'deb5912d60cb167b968a5147a85a6331b17ee6d903d6cfcb72b18ddc51ef7b1a'
node.default['zabbix']['agent']['checksum'] = 'b44cc9957d74d628e01a49bd18bd28ff778c42445f9f58038838de66a88b300e'
node.default['zabbix']['php']['checksum'] = '5cc69c427dac3a6ba0700af4a0ba6d7c7a65bf337a1439d1c1293d9165bc6000'

# Invoke Recipes
include_recipe 'sdl-zabbix::configure_zabbix'
include_recipe 'sdl-zabbix::configure_chef'
include_recipe 'sdl-zabbix::monitoring'
#RHEL does not support yum package for this. Need to follow this http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html 
#if we want to enable it for RHEL
#include_recipe 'sdl-zabbix::configure_aws_logs'