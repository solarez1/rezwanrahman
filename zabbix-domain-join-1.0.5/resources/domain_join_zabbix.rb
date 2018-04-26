#
# Cookbook Name:: zabbix-domain-join
# Recipe:: ad_join_zabbix
#
# Copyright 2018, SDL Plc
#
# All rights reserved - Do Not Redistribute
#
# Stuart Caine : January 2018
#
# Joins Linux Node To Active Directory

resource_name :domain_join_zabbix
property :domain, String, required: true
property :domain_user, String, required: true
property :server, [String, NilClass], required: true, default: nil
property :ou, [String, NilClass], required: false, default: nil


default_action :join

action :join do
  # Create Resources To Restart ntpd & network Daemons
  service 'ntpd' do
    action :nothing
  end

  service 'network' do
    action :nothing
  end

  service 'sssd' do
    action :nothing
  end

  service 'sshd' do
    action :nothing
  end

  # Install samba, oddjob and kerberos tools
  yum_package ['samba', 'samba-client', 'samba-common', 'ntp', 'sssd', 'oddjob', 'oddjob-mkhomedir', 'adcli', 'realmd', 'krb5-workstation.x86_64', 'pam_krb5.x86_64'] do
    action :install
  end

  net_config_files = ['hosts', # Configure the hosts file and make sure FQDN is bound to own IP
                  'krb5.conf', # Configure Kerberos
                  'sysconfig/network', # Configure the Hostname
                  'sysconfig/network-scripts/ifcfg-eth0'] # Disable DHCP - Set AD DC's As DNS Servers & AD Domain As Primary Search Domain

  ad_config_files = ['nsswitch.conf', # Permit lookup of AD passwords via sssd
                  'samba/smb.conf', # Configure Samba
                  'ssh/sshd_config', # Allows SSH authentication via kerberos and allows ssh group
                  'pam.d/sshd'] # Configure PAM to allow sssd lookups

# Iterate Through Templates & Apply
  ad_config_files.each do |file|
    template "/etc/#{file}" do
      source file + '.erb'
      action :create
      variables(lazy do
        {
          aws: node['aws']
        }
      end)
    end
  end

  # Iterate Through Templates & Apply
  net_config_files.each do |file|
    template "/etc/#{file}" do
      source file + '.erb'
      action :create
      variables(lazy do
        {
          aws: node['aws']
        }
      end)
      notifies :restart, 'service[network]', :immediately
    end
  end

#can only be started liited times before fails so configuring seperately
 template "/etc/ntp.conf" do
    source "ntp.conf.erb"
    action :create
    variables(lazy do
        {
          aws: node['aws']
        }
      end)
      notifies :restart, 'service[ntpd]', :immediately
    end

#wont start until domain joined
  template "/etc/sssd/sssd.conf" do
    source "sssd.conf.erb"
    action :create
    variables(lazy do
        {
          aws: node['aws']
        }
      end)
    owner 'root'
    group 'root'
    mode '0600'
  end

  # Configure Required Daemons To Start On Boot & Start
  service 'oddjobd'  do
    action %i[enable start]
  end

  service 'ntpd' do
    action %i[enable start]
  end

  service 'smb'  do
    action %i[enable start]
  end

  service 'realmd' do
  	action %i[enable start]
  end

  # Create Local SSH Users Group & Add Local Users To It
  group 'sshusers' do
    action :create
    members ['ec2-user']
    append false
  end

  domain_password = data_bag_item('zabbix-data','servicezabbixjoin')['password']

  # Execute Net Join If Required
  execute 'realm join' do
    command "realm join #{domain} -U #{domain_user}%#{domain_password} --computer-ou='#{ou}'"
     guard_block = <<-BASH
        realm list -n | grep -c 'sdlproducts.com'
     BASH
     not_if guard_block
    notifies :restart, 'service[sssd]', :immediately
    notifies :restart, 'service[sshd]', :immediately
  end

  #This service will only start/enable when domain joined
    service 'sssd' do
    action %i[enable start]
  end

end
