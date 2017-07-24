#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export LANG="en_GB.UTF-8"
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local

cd $VUFIND_HOME/import
php save_titleid.php

cd $VUFIND_LOCAL_DIR/harvest/Archive/

sed -i 's/\Â£//g' *.xml

sed -i "s/&amp;apos;/'/g" *.xml
sed -i 's/&amp;/&/g' *.xml

sed -i 's/<\/p><p>/\n\n/g' *.xml
sed -i 's/<p>//g' *.xml
sed -i 's/<\/p>//g' *.xml


