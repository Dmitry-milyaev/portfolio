pg_type="$2"
version="$1"
pgdata_check="$(ssh pg2 ls /pgdata)"
if [[ -n "$pgdata_check" ]];
then(
echo "Succes: directory /pgdata exists"
data_directory="$(ssh pg2 ls /pgdata/data)"
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
    ssh pg2 yum -y install postgrespro-ent-$version.x86_64 postgrespro-ent-$version-contrib postgrespro-ent-$version-libs postgrespro-ent-$version-server
    ssh pg2 systemctl stop postgrespro-ent-$version
    ssh pg2 chown postgres:postgres /var/log/pg_log
    ssh pg2 echo "PGDATA=/pgdata/data" > /var/lib/pgsql/.bash_profile
    ssh pg2 echo "PGDATA=/pgdata/data" > /etc/default/postgrespro-ent-$version
    ssh pg2 'su - postgres -c "PGPASSWORD=replica pg_basebackup -h pg1 -U replica -D /pgdata/data -X s -P"'
    ssh pg2 'systemctl daemon-reload'
    systemctl stop postgrespro-ent-$version
)
else
    (
    ssh pg2 yum -y install postgresql$version postgresql$version-server postgresql$version-contrib postgresql$version-libs
    ssh pg2 chown postgres:postgres /var/log/pg_log
    ssh pg2 sed -i "s?PGDATA=/var/lib/pgsql/$version/data?PGDATA=/pgdata/data?" /var/lib/pgsql/.bash_profile
    ssh pg2 sed -i "s?PGDATA=/var/lib/pgsql/$version/data/?PGDATA=/pgdata/data?" /usr/lib/systemd/system/postgresql-$version.service
    ssh pg2 'su - postgres -c "PGPASSWORD=replica pg_basebackup -h pg1 -U replica -D /pgdata/data -X s -P"'
    ssh pg2 'systemctl daemon-reload'
    systemctl stop postgresql-$version
    )
fi
)
fi
)
else(
echo "error: directory /pgdata not exists"
exit)
fi
