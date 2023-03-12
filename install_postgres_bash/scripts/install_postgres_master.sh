#!/bin/bash
pg_type="$2"
version="$1"
ip_slave="$3"
ip_virt="$4"
pwd="$(pwd)"
ip_main="$(hostname -i)"
pgdata_check="$(ls /pgdata)"
if [[ -n "$pgdata_check" ]];
then(
echo "Succes: directory /pgdata exists"
data_directory="$(ls /pgdata/data)"
if [[ -n "$data_directory" ]];
then(
echo "error: directory /pgdata/data exists"
exit 
)
else(
echo "Succes: directory /pgdata/data not exists"
mkdir /var/log/pg_log
echo "$pg_type"
if [ $pg_type = "pro" ];   
then(
yum -y install postgrespro-ent-$version.x86_64 postgrespro-ent-$version-contrib postgrespro-ent-$version-libs postgrespro-ent-$version-server
systemctl stop postgrespro-ent-$version
chown postgres:postgres /var/log/pg_log
chown -R postgres:postgres /pgdata
chmod -R 700 /pgdata
echo "PGDATA=/pgdata/data" > /var/lib/pgsql/.bash_profile
echo "PGDATA=/pgdata/data" > /etc/default/postgrespro-ent-$version
path_init="/opt/pgpro/ent-$version/bin/initdb -k -D /pgdata/data"
su - postgres -c "$path_init"
sed -i "s?#listen_addresses = 'localhost'?listen_addresses = '*'?" /pgdata/data/postgresql.conf
sed -i "s?#port = 5432?port = 5432?" /pgdata/data/postgresql.conf
sed -i "s?#wal_level = replica?wal_level = hot_standby?" /pgdata/data/postgresql.conf
sed -i "s?#max_wal_senders = 10?max_wal_senders = 10?" /pgdata/data/postgresql.conf
sed -i "s?#max_replication_slots = 10?max_replication_slots = 10?" /pgdata/data/postgresql.conf
sed -i "s?#hot_standby = on?hot_standby = on?" /pgdata/data/postgresql.conf
sed -i "s?#full_page_writes = on?full_page_writes = on?" /pgdata/data/postgresql.conf
sed -i "s?#log_directory = 'log'?log_directory = '/var/log/pg_log'?" /pgdata/data/postgresql.conf
sed -i "s?#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'?log_filename = 'postgresql-%a.log'?" /pgdata/data/postgresql.conf

echo " " > /pgdata/data/pg_hba.conf
echo "host  postgres  postgres   "$ip_main"/32     trust" >> /pgdata/data/pg_hba.conf
echo "host  postgres  postgres   "$ip_slave"/32     trust" >> /pgdata/data/pg_hba.conf
echo "#host  all       all        x.x.x.x/32        md5" >> /pgdata/data/pg_hba.conf
#echo "local  tech_user tech_user                    md5" >> /pgdata/data/pg_hba.conf
echo "local  all       postgres                    peer" >> /pgdata/data/pg_hba.conf
echo "local  replication   postgres                peer" >> /pgdata/data/pg_hba.conf
echo "host  replication   replica   "$ip_main"/32     md5" >> /pgdata/data/pg_hba.conf
echo "host  replication   replica   "$ip_slave"/32     md5" >> /pgdata/data/pg_hba.conf
echo "host  replication   replica   "$ip_virt"/32     md5" >> /pgdata/data/pg_hba.conf

systemctl daemon-reload
systemctl start postgrespro-ent-$version
)
else
    (
    yum -y install postgresql$version postgresql$version-server postgresql$version-contrib postgresql$version-libs
    sed -i "s?PGDATA=/var/lib/pgsql/$version/data?PGDATA=/pgdata/data?" /var/lib/pgsql/.bash_profile
    sed -i "s?PGDATA=/var/lib/pgsql/$version/data/?PGDATA=/pgdata/data?" /usr/lib/systemd/system/postgresql-$version.service

    path_init="/usr/pgsql-$version/bin/initdb -k -D /pgdata/data"

    su - postgres -c "$path_init"
    sed -i "s?#listen_addresses = 'localhost'?listen_addresses = '*'?" /pgdata/data/postgresql.conf
    sed -i "s?#port = 5432?port = 5432?" /pgdata/data/postgresql.conf
    sed -i "s?#wal_level = replica?wal_level = hot_standby?" /pgdata/data/postgresql.conf
    sed -i "s?#max_wal_senders = 10?max_wal_senders = 10?" /pgdata/data/postgresql.conf
    sed -i "s?#max_replication_slots = 10?max_replication_slots = 10?" /pgdata/data/postgresql.conf
    sed -i "s?#hot_standby = on?hot_standby = on?" /pgdata/data/postgresql.conf
    sed -i "s?#full_page_writes = on?full_page_writes = on?" /pgdata/data/postgresql.conf
    sed -i "s?#log_directory = 'log'?log_directory = '/var/log/pg_log'?" /pgdata/data/postgresql.conf
    sed -i "s?#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'?log_filename = 'postgresql-%a.log'?" /pgdata/data/postgresql.conf

    echo " " > /pgdata/data/pg_hba.conf
    echo "host  postgres  postgres   "$ip_main"/32     trust" >> /pgdata/data/pg_hba.conf
    echo "host  postgres  postgres   "$ip_slave"/32     trust" >> /pgdata/data/pg_hba.conf
    echo "#host  all       all        x.x.x.x/32        md5" >> /pgdata/data/pg_hba.conf
    #echo "local  tech_user tech_user                    md5" >> /pgdata/data/pg_hba.conf
    echo "local  all       postgres                    peer" >> /pgdata/data/pg_hba.conf
    echo "local  replication   postgres                peer" >> /pgdata/data/pg_hba.conf
    echo "host  replication   replica   "$ip_main"/32     md5" >> /pgdata/data/pg_hba.conf
    echo "host  replication   replica   "$ip_slave"/32     md5" >> /pgdata/data/pg_hba.conf
    echo "host  replication   replica   "$ip_virt"/32     md5" >> /pgdata/data/pg_hba.conf
    
    systemctl daemon-reload
    systemctl start postgresql-$version
    )
fi

#su - postgres -c "$pwd/create_replica.sh"
su - postgres -c "/opt/install_postgres/scripts/create_replica.sh"
)
fi
)
else(
    echo "error: directory /pgdata not exists"
    exit)
fi
