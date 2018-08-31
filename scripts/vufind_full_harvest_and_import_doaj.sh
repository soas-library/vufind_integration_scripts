#!/bin/bash -v
# @name: vufind_full_harvest_and_import_doaj.sh
# @version: 1.0
# @creation_date: 2018-08-22
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This script harvests and then imports records from DOAJ into VuFind

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
RUN_DATE=`date +"%Y%m%d%H%M"`
VUFIND_LOG_DIR="/home/vufind/logs/"
VUFIND_BIN_DIR="/home/vufind/bin"
VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"
VUFIND_BIN_HIERARCHY="/usr/local/vufind/util"

export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local
find  /usr/local/vufind/local/harvest/DOAJ/ -name '*.xml' -exec rm {} \;
find  /usr/local/vufind/local/harvest/DOAJ/processed/ -name '*.xml' -exec rm {} \;
> /usr/local/vufind/local/harvest/DOAJ/info.txt
rm /usr/local/vufind/local/harvest/DOAJ/last_harvest.txt
rm /usr/local/vufind/local/harvest/DOAJ/last_state.txt
cd /usr/local/vufind/harvest
/usr/bin/php harvest_oai.php DOAJ
sed -i "s/xmlns:dc/ xmlns:dc/" /usr/local/vufind/local/harvest/DOAJ/*.xml
 
echo "Log in ${VUFIND_MAIN_LOG}" 
PROCESS_TO_RUN="vufind_full_harvest_and_import_doaj"
echo "$RUN_DATE - VuFind importing DOAJ records - " >> "${VUFIND_MAIN_LOG}"
  
cd ${VUFIND_BIN_DIR}
pwd
./vufind_import_doaj.pl doaj weekly >> "${VUFIND_MAIN_LOG}"
 
RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - VuFind importing DOAJ records ended - " >> "${VUFIND_MAIN_LOG}"

#  exit the program
exit 0

