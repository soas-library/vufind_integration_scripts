#!/bin/csh
# @name: vufind_control_script.sh
# @version: 1.0
# @creation_date: 2014-04-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: David Bartlett
#
# @purpose:
# This script controls the running of the 4 Vufind data input programs.
# The programs are - 
# vufind_100_ole_index.pl
# vufind_600_oai_harvest.pl

#setenv VUFIND_HOME=/usr/local/vufind
#setenv VUFIND_LOCAL_DIR=/usr/local/vufind/local

set RUN_DATE=`date +"%Y%m%d%H%M"`
set ILS_ACTION="None"
set ILS_NAME="None"
set VUFIND_BIN_DIR="/home/vufind/bin"
set VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"

set PARM_LIST = $argv[1]

set PROCESS_TO_RUN = `echo $PARM_LIST | cut -d , -f1`
set ILS_NAME = `echo $PARM_LIST | cut -d , -f2`
set ACTION = `echo $PARM_LIST | cut -d , -f2`
set ILS_ACTION = `echo $PARM_LIST | cut -d , -f3`
echo "$RUN_DATE - vufind main control started - running $PROCESS_TO_RUN for library $ILS_NAME with action $ILS_ACTION " >> ${VUFIND_MAIN_LOG}

# Use switch function to determine which program to use

switch($PROCESS_TO_RUN) 
   case vufind_100:
     cd ${VUFIND_BIN_DIR}
     ./vufind_100_ole_index.pl $ILS_NAME $ILS_ACTION >> ${VUFIND_MAIN_LOG}
     breaksw
   case vufind_200:	
     cd ${VUFIND_BIN_DIR}
     ./vufind_200_daily_extract.pl $ILS_NAME >> ${VUFIND_MAIN_LOG} 
     breaksw 
   case vufind_400:	
     cd ${VUFIND_BIN_DIR}
     ./vufind_400_weekly_extract.pl $ILS_NAME >> ${VUFIND_MAIN_LOG} 
     breaksw 
   case vufind_450:	
     cd ${VUFIND_BIN_DIR}
     ./vufind_450_weekly_auth_extract.pl $ILS_NAME >> ${VUFIND_MAIN_LOG} 
     breaksw 
   case vufind_500:	
     cd ${VUFIND_BIN_DIR}
     ./vufind_500_update_index.pl $ILS_NAME $ILS_ACTION >> ${VUFIND_MAIN_LOG} 
     breaksw
   case vufind_600:
     cd ${VUFIND_BIN_DIR}
     ./vufind_600_oai_harvest.pl $ACTION >> ${VUFIND_MAIN_LOG}
     breaksw 
 
endsw
set RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - vufind main control ended - running $PROCESS_TO_RUN for library $ILS_NAME with $ILS_ACTION" >> ${VUFIND_MAIN_LOG}
#  exit the program
exit 0