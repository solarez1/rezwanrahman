# CW monitoring of Zabbix-Server

# Add CRON Job To Run Every 5 Minutes To Monitor Zabbix Server Service
region = (node['ec2']['placement_availability_zone']).sub(/(.$)/,'')
cron 'zabbixserver_monitor' do
  minute "*/#{node['cloudwatch']['interval']}"
  command 'aws cloudwatch put-metric-data --namespace \'ZabbixServerService\' --metric-name "ZabbixServerService" --value $(UP=$(pgrep zabbix_server | wc -l); if [ $UP -ne 0 ]; then echo 0; else echo 1; fi) --region eu-west-1'
end

# Add CRON Job To Run Every 5 Minutes To Maintain The CloudWatch Alarms
cron 'zabbixserver_monitor_alarm' do
  minute "*/#{node['cloudwatch']['interval']}"
  command 'aws cloudwatch put-metric-alarm --alarm-name "ZabbixServerService" --alarm-description "Alarm when Zabbix Server Service Stops" ' \
          + '--metric-name "ZabbixServerService" --namespace "ZabbixServerService" --statistic Maximum --period 300 --threshold 0 ' \
          + '--comparison-operator GreaterThanThreshold --evaluation-periods 1 --unit None --region eu-west-1'
end