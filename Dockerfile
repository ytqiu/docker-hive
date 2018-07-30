FROM parrotstream/centos-openjdk

MAINTAINER Matteo Capitanio <matteo.capitanio@gmail.com>

USER root

ADD cloudera-cdh5.repo /etc/yum.repos.d/
RUN rpm --import https://archive.cloudera.com/cdh5/redhat/5/x86_64/cdh/RPM-GPG-KEY-cloudera
#RUN yum install -y postgresql hive hive-hbase hive-jdbc hive-metastore hive-server2
RUN yum install postgresql-jdbc hive-metastore -y
RUN yum clean all
RUN yum install mysql-connector-java -y
RUN yum install postgresql -y

RUN ln -s /usr/share/java/postgresql-jdbc.jar /usr/lib/hive/lib/postgresql-jdbc.jar
RUN ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar
#RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1209.jre7.jar -O /usr/lib/hive/lib/postgresql-9.4.1209.jre7.jar

WORKDIR /

ADD etc/default/supervisord.conf /etc/
ADD etc/default/hive/conf/*.xml /etc/hive/conf/
ADD etc/default/hadoop/conf/*.xml /etc/hadoop/conf/
ADD bin/supervisord-bootstrap.sh ./
ADD bin/wait-for-it.sh ./
RUN chmod +x ./*.sh

#EXPOSE 9083 10000 10002
EXPOSE 9083

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
