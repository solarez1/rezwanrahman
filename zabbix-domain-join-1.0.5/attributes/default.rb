# Add Node Defaults For AWS
node.default['aws']['region'] = (node['ec2']['placement_availability_zone']).sub(/(.$)/, '')
node.default['aws']['hostname'] = node['hostname']
node.default['aws']['fqdn'] = node['fqdn']
node.default['aws']['ipaddress'] = node['ipaddress']
node.default['aws']['ad_domain'] = 'sdlproducts.com'
node.default['aws']['ad_join_user'] = 'servicezabbixjoin'

# Declare Per-Region Defaults For Domain Controllers, OU Placement Etc.
node.default['aws']['ad_servers_map'] = {
  'us-east-1' => {
    primary_dc_name: 'NVADC01',
    secondary_dc_name: 'NVADC02',
    primary_dc_ip: '172.21.75.38',
    secondary_dc_ip: '172.21.75.79',
    linux_ou: 'OU=High Production Servers,OU=Timezone - No Updates,OU=NVirginia,OU=Domain Servers,DC=sdlproducts,DC=com'
  },  
  'us-west-2' => {
    primary_dc_name: 'BDADC01',
    secondary_dc_name: 'BDADC02',
    primary_dc_ip: '172.21.1.125',
    secondary_dc_ip: '172.21.1.45',
    linux_ou: 'OU=High Production Servers,OU=Timezone - No Updates,OU=Boardman,OU=Domain Servers,DC=sdlproducts,DC=com'
  },
  'eu-central-1' => {
    primary_dc_name: 'FRADC01',
    secondary_dc_name: 'FRADC02',
    primary_dc_ip: '172.21.73.60',
    secondary_dc_ip: '172.21.73.90',
    linux_ou: 'OU=High Production Servers,OU=Timezone - No Updates,OU=Frankfurt,OU=Domain Servers,DC=sdlproducts,DC=com'
  },  
  'eu-west-1' => {
    primary_dc_name: 'DUBDC02',
    secondary_dc_name: 'DUBDC03',
    primary_dc_ip: '172.21.0.5',
    secondary_dc_ip: '172.21.0.83',
    linux_ou: 'OU=High Production Servers,OU=Timezone - EMEA,OU=Dublin,OU=Domain Servers,DC=sdlproducts,DC=com'
  },
  'ap-northeast-1' => {
    primary_dc_name: 'TKYDC01',
    secondary_dc_name: 'TKYDC01',
    primary_dc_ip: '172.21.2.81',
    secondary_dc_ip: '172.21.2.81',
    linux_ou: 'OU=High Production,OU=No Updates,OU=Tokyo,OU=Domain Servers,DC=sdlproducts,DC=com'
  }
}