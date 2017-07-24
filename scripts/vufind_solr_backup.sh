#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local

cd $VUFIND_HOME;
./solr.sh stop;
sleep 25;
rm -f /home/vufind/backup/solr_backup/solr.tar.gz;
tar -zcvf /home/vufind/backup/solr_backup/solr.tar.gz /usr/local/vufind/solr/;
./solr.sh start;
sleep 120;

