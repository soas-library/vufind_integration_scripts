#!/bin/bash -v
# @name: vufind_backup_script.sh
# @version: 1.0
# @creation_date: Unknown
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author Simon Barron <sb174@soas.ac.uk>
#
# @purpose:
# This script runs a backup of all files on this server's VuFind instance that are likely to have been edited.
# Backups are retained for three days in /home/vufind/backup

THREEDAYS=$(date --date=-3days +'%y%m%d')
DATE=$(date +'%y%m%d')

mkdir /home/vufind/backup/vufind.$DATE
mkdir /home/vufind/backup/vufind.$DATE/bin
mkdir /home/vufind/backup/vufind.$DATE/scripts
mkdir /home/vufind/backup/vufind.$DATE/cron_jobs
mkdir /home/vufind/backup/vufind.$DATE/program_source_code
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk/local
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk/themes
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk/solr
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk/solr/biblio
mkdir /home/vufind/backup/vufind.$DATE/program_source_code/trunk/solr/authority
cp -vu /usr/local/vufind/solr.sh /home/vufind/backup/vufind.$DATE/program_source_code/trunk
cp -vu /usr/local/vufind/index-alphabetic-browse.sh /home/vufind/backup/vufind.$DATE/program_source_code/trunk
cp -rvu /usr/local/vufind/local/config /home/vufind/backup/vufind.$DATE/program_source_code/trunk/local
cp /usr/local/vufind/local/httpd-vufind.conf /home/vufind/backup/vufind.$DATE/program_source_code/trunk/local
cp -rvu /usr/local/vufind/themes/soas /home/vufind/backup/vufind.$DATE/program_source_code/trunk/themes
cp -rvu /usr/local/vufind/themes/scb-soas /home/vufind/backup/vufind.$DATE/program_source_code/trunk/themes
cp -rvu /usr/local/vufind/import /home/vufind/backup/vufind.$DATE/program_source_code/trunk/
cp -rvu /usr/local/vufind/local/import /home/vufind/backup/vufind.$DATE/program_source_code/trunk/
cp -rvu /usr/local/vufind/module /home/vufind/backup/vufind.$DATE/program_source_code/trunk
cp -rvu /usr/local/vufind/solr/biblio/conf /home/vufind/backup/vufind.$DATE/program_source_code/trunk/solr/biblio/conf
cp -rvu /usr/local/vufind/solr/authority/conf /home/vufind/backup/vufind.$DATE/program_source_code/trunk/solr/authority/conf
cp -rvu /usr/local/vufind/harvest /home/vufind/backup/vufind.$DATE/program_source_code/trunk
cp -rvu /home/vufind/bin /home/vufind/backup/vufind.$DATE
cp -rvu /home/vufind/scripts /home/vufind/backup/vufind.$DATE
crontab -l > /home/vufind/backup/vufind.$DATE/cron_jobs/crontab.txt
rm -rf /home/vufind/backup/vufind.$THREEDAYS

exit 0
