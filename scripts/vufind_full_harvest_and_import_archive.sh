#!/bin/bash -v
# @name: vufind_full_harvest_and_import_archive.sh
# @version: 1.0
# @creation_date: 2018-09-24
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This script harvests and then imports records from SOAS Archives (Axiell Calm) VuFind

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
RUN_DATE=`date +"%Y%m%d%H%M"`
VUFIND_LOG_DIR="/home/vufind/logs/"
VUFIND_BIN_DIR="/home/vufind/bin"
VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"

export PATH
export LANG="en_GB.UTF-8"
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
cd $VUFIND_HOME/import
php save_titleid.php

cd $VUFIND_LOCAL_DIR/harvest/Archive/

sed -i 's/\Â£//g' *.xml

sed -i "s/&amp;apos;/'/g" *.xml
sed -i 's/&amp;/&/g' *.xml

sed -i 's/<\/p><p>/\n\n/g' *.xml
sed -i 's/<p>//g' *.xml
sed -i 's/<\/p>//g' *.xml

echo "Log in ${VUFIND_MAIN_LOG}" 
PROCESS_TO_RUN="vufind_full_harvest_and_import_archive"
echo "$RUN_DATE - VuFind importing archive records - " >> "${VUFIND_MAIN_LOG}"
  
cd ${VUFIND_BIN_DIR}
pwd
./vufind_import_archive.pl archive weekly >> "${VUFIND_MAIN_LOG}"
 
RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - VuFind importing archive records - " >> "${VUFIND_MAIN_LOG}"
#  exit the program
exit 0
