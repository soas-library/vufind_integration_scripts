#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local
find  /usr/local/vufind/local/harvest/Archive/ -name '*.xml' -exec rm {} \;
find  /usr/local/vufind/local/harvest/Archive/processed/ -name '*.xml' -exec rm {} \;
cd /usr/local/vufind/harvest
/usr/bin/php harvest_oai.php Archive

cd /home/vufind/scripts
./vufind_transform_archive_xml.sh
