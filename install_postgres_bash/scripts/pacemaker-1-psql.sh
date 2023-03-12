version="$1"
ip_virt="$2"
cluster_interface="$3"
mask="$4"
pcs cluster auth pg1 pg2 
pcs cluster setup --start --name cluster_name pg1 pg2
pcs property set no-quorum-policy="ignore" 
pcs property set stonith-enabled="false"
pcs resource defaults resource-stickiness="1000"
pcs resource defaults migration-threshold="3"
echo -n 'pcs resource create vip-master IPaddr2 ip="' > temp.sh
echo -n "$ip_virt" >> temp.sh
echo -n '" nic="' >> temp.sh
echo -n "$cluster_interface" >> temp.sh
echo -n '" cidr_netmask="' >> temp.sh
echo -n "$mask" >> temp.sh
echo -n '" op start timeout="180s" interval="0s" on-fail="restart" op monitor timeout="180s" interval="10s" on-fail="restart" op stop timeout="180s" interval="0s" on-fail="block"' >> temp.sh
chmod +x temp.sh
./temp.sh

echo -n 'pcs resource create pgsql pgsql pgctl="/usr/pgsql-' > temp.sh
echo -n "$version" >> temp.sh
echo -n '/bin/pg_ctl" psql="/usr/pgsql-' >> temp.sh
echo -n "$version" >> temp.sh
echo -n '/bin/psql" pgdata="/pgdata/data/" rep_mode="sync" node_list="pg1 pg2" primary_conninfo_opt="keepalives_idle=60 keepalives_interval=5 keepalives_count=5 password=replica" repuser=replica replication_slot_name=standby_slot2 master_ip="' >> temp.sh
echo -n "$ip_virt" >> temp.sh
echo -n '" op start timeout="180s" interval="0s" on-fail="restart" op monitor timeout="180s" interval="4s" on-fail="restart" op monitor timeout="180s" interval="3s" on-fail="restart" role="Master" op promote timeout="180s" interval="0s" on-fail="restart" op demote timeout="180s" interval="0s" on-fail="stop" op stop timeout="180s" interval="0s" on-fail="block" op notify timeout="180s" interval="0s"' >> temp.sh
./temp.sh

pcs resource master msPostgresql pgsql master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true

pcs resource group add master-group vip-master
pcs constraint colocation add master-group with Master msPostgresql INFINITY 
pcs constraint order promote msPostgresql then start master-group symmetrical=false score=INFINITY
pcs constraint order demote msPostgresql then stop master-group symmetrical=false score=0

