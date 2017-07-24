#!/bin/csh
# @name: vufind_control_script.sh
# @version: 1.0
# @creation_date: 2014-08-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: David Bartlett
#
# @purpose:
# This script controls the running of the Vufind housekeeping process which will delete old files from
# the /home/vufind/input, home/vufind/input/weekly and home/vufind/logs directories.
#
# The program run is  - vufind_housekeeping.pl which is called with 2 parameters 
# The first parameter is the number of days in the past from which all files are deleted and the 2nd parameter is the full path name to the directory from which the files are to be deleted.                                                                                   #
# Example:
# ./vufind_housekeeping.pl  4 /home/vufind/logs
# This will delete all files in the logs directory over 3 days old.

set RUN_DATE=`date +"%Y%m%d%H%M"`
set VUFIND_LOG_DIR="/home/vufind/logs/"
set VUFIND_INPUT_DIR="/home/vufind/input/"
set VUFIND_DAILY_DIR="/home/vufind/input/daily"
set VUFIND_WEEKLY_DIR="/home/vufind/input/weekly/"
set VUFIND_OUTPUT_DIR="/home/vufind/output/"
set AGED_DAYS="3"
set VUFIND_BIN_DIR="/home/vufind/bin"
set VUFIND_MAIN_LOG="/home/vufind/logs/vufind_main_run.log"
set VUFIND_LOCAL_DIR="/usr/local/vufind/local/"

set PROCESS_TO_RUN="vufind_housekeeping" 
echo "$RUN_DATE - vufind housekeeping started - " >> ${VUFIND_MAIN_LOG}


cd ${VUFIND_BIN_DIR}
./vufind_housekeeping.pl $AGED_DAYS $VUFIND_LOG_DIR >> ${VUFIND_MAIN_LOG} 
#./vufind_housekeeping.pl $AGED_DAYS $VUFIND_INPUT_DIR >> ${VUFIND_MAIN_LOG}
#./vufind_housekeeping.pl $AGED_DAYS $VUFIND_DAILY_DIR >> ${VUFIND_MAIN_LOG}
#./vufind_housekeeping.pl $AGED_DAYS $VUFIND_WEEKLY_DIR >> ${VUFIND_MAIN_LOG}
./vufind_housekeeping.pl $AGED_DAYS $VUFIND_OUTPUT_DIR >> ${VUFIND_MAIN_LOG}

#remove all .mrc files from /home/vufind/input as these are concatonated into a single file in the daily dir
echo Removing all .mrc files in /home/vufind/input >> ${VUFIND_MAIN_LOG}
rm -f ${VUFIND_INPUT_DIR}/*.mrc >> ${VUFIND_MAIN_LOG}
#remove all .mrc files older than 3 day in /home/vufind/input/daily
echo Removing all .mrc files older than 3 day in /home/vufind/input/daily >> ${VUFIND_MAIN_LOG}
find $VUFIND_DAILY_DIR -type f -mtime +2 -name '*.mrc' -exec rm -f {} \; >> ${VUFIND_MAIN_LOG}
#remove all searches from vufind.search table older than 7 days
php /usr/local/vufind/util/expire_searches.php 7 >> ${VUFIND_MAIN_LOG}
set RUN_DATE_END=`date +"%Y%m%d%H%M"`
echo "$RUN_DATE_END - vufind housekeeping ended - " >> ${VUFIND_MAIN_LOG}
#  exit the program
exit 0