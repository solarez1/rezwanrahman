#
#These attributes are used to determine which zabbix proxy to use, dependant on which region the instance is in.
#This will only work for AWS instance, however it is possible to add an attribute in the role if using Chef with VM in NTT
node.default['aws']['region'] = (node['ec2']['placement_availability_zone']).sub(/(.$)/, '')
#
#
#
node.default['aws']['zabbixproxymap'] = {
  'us-west-2' => {
        zabbix_proxy: 'bdazabproxy01'
    },
  'us-east-1' => {
        zabbix_proxy: 'nvazabproxy01'
    },
   'ap-northeast-1' => {
        zabbix_proxy: 'tkozabproxy01'
   },
   'eu-central-1' => {
        zabbix_proxy: 'frazabproxy01'
   },
   'eu-west-1' => {
        zabbix_proxy: 'dubzabproxy01'
   }
}