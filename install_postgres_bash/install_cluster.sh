#!/bin/bash
pg_type="$2"
version="$1"
ip_slave="$3"
ip_virt="$4"
cluster_interface="$5"
mask="$6"
/opt/install_postgres/scripts/install_postgres_master.sh $version $pg_type $ip_slave $ip_virt
/opt/install_postgres/scripts/install_postgres_slave.sh $version $pg_type
yum -y install pcs corosync pacemaker resource-agents
ssh pg2 yum -y install pcs corosync pacemaker resource-agents
echo -e "hacluster\nhacluster\n" | passwd hacluster
ssh pg2 'echo -e "hacluster\nhacluster\n" | passwd hacluster'
os_release="$(cat /etc/*release* | grep 'CentOS')"
if [[ -n "$os_release" ]];
then (
echo "CentOS"
cp /opt/install_postgres/pgsql/pgsql$version /usr/lib/ocf/resource.d/heartbeat/pgsql
chmod +x /usr/lib/ocf/resource.d/heartbeat/pgsql
scp /opt/install_postgres/pgsql/pgsql$version root@$ip_slave:/usr/lib/ocf/resource.d/heartbeat/pgsql
ssh pg2 'chmod +x /usr/lib/ocf/resource.d/heartbeat/pgsql'
)
fi
os_release="$(cat /etc/*release* | grep 'RED OS')"
if [[ -n "$os_release" ]];
then (
echo "RED OS"
cp /opt/install_postgres/pgsql/pgsql_redos /usr/lib/ocf/resource.d/heartbeat/pgsql
chmod +x /usr/lib/ocf/resource.d/heartbeat/pgsql
scp /opt/install_postgres/pgsql/pgsql_redos root@$ip_slave:/usr/lib/ocf/resource.d/heartbeat/pgsql
ssh pg2 'chmod +x /usr/lib/ocf/resource.d/heartbeat/pgsql'
)
fi
systemctl start pcsd.service
systemctl is-active pcsd.service
systemctl enable pcsd.service
systemctl is-enabled pcsd.service
ssh pg2 'systemctl start pcsd.service'
ssh pg2 'systemctl is-active pcsd.service'
ssh pg2 'systemctl enable pcsd.service'
ssh pg2 'systemctl is-enabled pcsd.service'

pacemaker_version="$(rpm -qa | grep pacemaker-1)"
if [[ -n "$pacemaker_version" ]];
then
(echo "pacemaker-1"
/opt/install_postgres/scripts/pacemaker-1-$pg_type.sh $version $ip_virt $cluster_interface $mask
)
else
(echo "pacemaker-2"
/opt/install_postgres/scripts/pacemaker-2-$pg_type.sh $version $ip_virt $cluster_interface $mask)
fi

ssh pg2 'pcs cluster stop'
pcs cluster stop --force
rm -rf /pgdata/tmp/PGSQL.lock
ssh pg2 'rm -rf /pgdata/tmp/PGSQL.lock'
pcs cluster start
sleep 60
ssh pg2 'rm -rf /pgdata/data'
ssh pg2 'su - postgres -c "PGPASSWORD=replica pg_basebackup -h pg1 -U replica -D /pgdata/data -X s -P"'
ssh pg2 'pcs cluster start'

sleep 40
crm_mon -Art
