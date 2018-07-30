#!/bin/bash
DB_HOST=`cat /etc/hive/conf/hive-site.xml  | grep jdbc: | awk -F ":|/" '{print $5}'`
DB_PORT=`cat /etc/hive/conf/hive-site.xml  | grep jdbc: | awk -F ":|/" '{print $6}'`
DB_USER=`cat /etc/hive/conf/hive-site.xml  | grep -A 1 ConnectionUserName | grep value | awk -F">|<" '{print $3}'`
DB_PASSWORD=`cat /etc/hive/conf/hive-site.xml  | grep -A 1 ConnectionPassword | grep value | awk -F">|<" '{print $3}'`

echo "db config: ${DB_TYPE} => ${DB_USER}@${DB_HOST}:${DB_PORT}"

rm /opt/hive/logs/*.pid 2> /dev/null

/wait-for-it.sh zookeeper:2181 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n--------------------------------------------"
    echo -e "      Zookeeper not ready! Exiting..."
    echo -e "--------------------------------------------"
    exit $rc
fi

/wait-for-it.sh hadoop:8020 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n--------------------------------------------"
    echo -e "      HDFS not ready! Exiting..."
    echo -e "--------------------------------------------"
    exit $rc
fi

/wait-for-it.sh $DB_HOST:$DB_PORT -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n--------------------------------------------"
    echo -e "    DB:$DB_TYPE not ready! Exiting..."
    echo -e "--------------------------------------------"
    exit $rc
fi
#/wait-for-it.sh postgres:5432 -t 120
#rc=$?
#if [ $rc -ne 0 ]; then
#    echo -e "\n--------------------------------------------"
#    echo -e "    PostgreSql not ready! Exiting..."
#    echo -e "--------------------------------------------"
#    exit $rc
#fi

#sudo -u hdfs hdfs dfs -mkdir -p /tmp
#sudo -u hdfs hdfs dfs -mkdir -p /user/
#sudo -u hdfs hdfs dfs -mkdir -p /user/hive
#sudo -u hdfs hdfs dfs -mkdir -p /user/hive/warehouse
#sudo -u hdfs hdfs dfs -chmod g+w /tmp
#sudo -u hdfs hdfs dfs -chmod g+w /user/hive/warehouse
#sudo -u hdfs hdfs dfs -chown -R hdfs:supergroup /tmp
#sudo -u hdfs hdfs dfs -chown -R hdfs:supergroup /user

# need create metastore manually
#psql -h postgres -U postgres -c "CREATE DATABASE metastore;" 2>/dev/null

#/usr/lib/hive/bin/schematool -dbType postgres -initSchema
/usr/lib/hive/bin/schematool -dbType $DB_TYPE -initSchema

supervisorctl start hive-metastore

/wait-for-it.sh localhost:9083 -t 240
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "  Hive Metastore not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

#supervisorctl start hive-server2
#/wait-for-it.sh localhost:10002 -t 240
#rc=$?
#if [ $rc -ne 0 ]; then
#    echo -e "\n---------------------------------------"
#    echo -e "   HiveServer2 not ready! Exiting..."
#    echo -e "---------------------------------------"
#    exit $rc
#fi
#
#echo -e "\n\n--------------------------------------------------------------------------------"
#echo -e "You can now access to the following Hive Web UIs:"
#echo -e ""
#echo -e "HiveServer2 Web Interface:		http://localhost:10002"
#echo -e "\nMantainer:   Matteo Capitanio <matteo.capitanio@gmail.com>"
#echo -e "--------------------------------------------------------------------------------\n\n"
