#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local
find  /usr/local/vufind/local/harvest/Archive/ -name '*.xml' -exec rm {} \;
find  /usr/local/vufind/local/harvest/Archive/processed/ -name '*.xml' -exec rm {} \;
> /usr/local/vufind/local/harvest/Archive/info.txt
rm /usr/local/vufind/local/harvest/Archive/last_harvest.txt
rm /usr/local/vufind/local/harvest/Archive/last_state.txt
cd /usr/local/vufind/harvest
/usr/bin/php harvest_oai.php Archive

#Adjust xml files after harvesting
cd /home/vufind/scripts
./vufind_transform_archive_xml.sh
