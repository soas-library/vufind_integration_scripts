#!/bin/bash
# @name: vufind_full_import_manuscript.sh
# @version: 1.0
# @creation_date: 2018-07-02
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This script imports data from SOAS Library's GitHub repository for FIHRIST records into VuFind

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
RUN_DATE=`date +"%Y%m%d%H%M"`
VUFIND_HOME_DIR="/home/vufind"
VUFIND_LOG_DIR="/home/vufind/logs/"
VUFIND_BIN_DIR="/home/vufind/bin"
VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"
VUFIND_BIN_HIERARCHY="/usr/local/vufind/util"

export PATH

echo "Log in ${VUFIND_MAIN_LOG}" 
PROCESS_TO_RUN="vufind_full_import_manuscript"
echo "$RUN_DATE - VuFind importing manuscript records - " >> "${VUFIND_MAIN_LOG}"

cd ${VUFIND_HOME_DIR}
rm -rf ./fihrist-mss
git clone https://github.com/soas-library/fihrist-mss.git
find /usr/local/vufind/local/harvest/manuscript/processed/ -name '*.xml' -exec rm {} \;

cp ${VUFIND_HOME_DIR}/fihrist-mss/collections/school\ of\ oriental\ and\ african\ studies/*.xml /usr/local/vufind/local/harvest/manuscript/

cd ${VUFIND_BIN_DIR}
pwd
./vufind_import_manuscript.pl manuscript weekly >> "${VUFIND_MAIN_LOG}"
 
RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - VuFind importing manuscript records ended - " >> "${VUFIND_MAIN_LOG}"
#  exit the program
exit 0
