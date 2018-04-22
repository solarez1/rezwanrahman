#
# Cookbook Name:: sdl_aws_base
# Recipe:: active_directory
#
# Copyright 2016, SDL Plc
#
# All rights reserved - Do Not Redistribute
#
# Dave Osment (dosment@sdl.com) : October 2016
#
# Performs Base Configuration For All SDL AWS-Based Infrastructure

# Ensure All Gems Required For This Cookbook Are Present

# Add Node Defaults For AWS
node.default['aws']['region'] = (node['ec2']['placement_availability_zone']).sub(/(.$)/,'')
node.default['aws']['hostname'] = node['hostname']
node.default['aws']['fqdn'] = node['fqdn']
node.default['aws']['ipaddress'] = node['ipaddress']
node.default['aws']['ad_domain'] = 'sdlproducts.com'
node.default['aws']['ad_join_user'] = 'ServiceWSCFNScript'
node.default['aws']['ad_join_cipertext'] = 'AQECAHg+/9bZkcmKdxLPL+k+d/hKWfMATt2xwUqa2P3W+7RKKQAAAGowaAYJKoZIhvcNAQcGoFswWQIBADBUBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDATyNryswaWuppI7rwIBEIAn4IyYpfC7e2GeAzhybhIHHtQ8+F+c2t1y2yeAFSe7yTMQ89Vbfq3A'										  
node.default['aws']['sep']['url']['amazon'] = 'https://s3-us-west-2.amazonaws.com/com-sdlproducts-worldserver-resources/sep/sep-managed-client-linux.zip'
node.default['aws']['sep']['url']['windows'] = 'https://s3-us-west-2.amazonaws.com/com-sdlproducts-worldserver-resources/sep-client.zip'
node.default['chef']['interval'] = 5
node.default['aws']['ad_servers_map'] = { 'eu-west-1' => {	:primary_dc_name => 'DUBDC02', 
															:secondary_dc_name => 'DUBDC03', 
															:primary_dc_ip => '172.21.1.125', 
															:secondary_dc_ip => '172.21.1.45', 
															:linux_ou => 'SDLProducts Servers/Boardman/Timezone - USA/High Production',
															:windows_ou => 'OU=High Production,OU=Timezone - USA,OU=Boardman,OU=SDLProducts Servers,DC=sdlproducts,DC=com'} }

#node.default['aws']['dns_servers_map'] = { 'us-west-2' => ['172.21.1.125', '172.21.1.45'], 
#										  'eu-west-1' =>  ['172.21.1.125', '172.21.1.45'] }
#node.default['aws']['ad_join_ou_map'] = { 'us-west-2' => 'OU=High Production,OU=Timezone - USA,OU=Boardman,OU=SDLProducts Servers,DC=sdlproducts,DC=com', 
#										  'eu-west-1' =>  'OU=High Production,OU=Timezone - USA,OU=Dublin,OU=SDLProducts Servers,DC=sdlproducts,DC=com' }
