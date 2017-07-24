#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local

find $VUFIND_HOME/local/harvest/Archive/ -name '*.xml' -exec rm {} \;
find $VUFIND_HOME/local/harvest/Archive/processed/ -name '*.xml' -exec rm {} \;

cd /usr/local/vufind/import
php extract_xmls.php

cd $VUFIND_LOCAL_DIR/harvest/Archive/

find $VUFIND_LOCAL_DIR/harvest/Archive/ -type f -exec sed -i "s/&amp;apos;/'/g" {} \;
find $VUFIND_LOCAL_DIR/harvest/Archive/ -type f -exec sed -i 's/&amp;/&/g' {} \;



