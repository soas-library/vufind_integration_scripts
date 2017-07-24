#!/bin/bash
RUN_DATE=`date +"%Y%m%d%H%M"`
VUFIND_LOG_DIR="/home/vufind/logs/"
VUFIND_BIN_DIR="/home/vufind/bin"
VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"
 
echo "Log in ${VUFIND_MAIN_LOG}" 
PROCESS_TO_RUN="vufind_import_sobek"
echo "$RUN_DATE - vufind importing sobek records - " >> "${VUFIND_MAIN_LOG}"
 
 
 
cd ${VUFIND_BIN_DIR}
pwd
./vufind_import_sobek.pl sobek nightly >> "${VUFIND_MAIN_LOG}"
 
RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - vufind importing sobek records - " >> "${VUFIND_MAIN_LOG}"
#  exit the program
exit 0
