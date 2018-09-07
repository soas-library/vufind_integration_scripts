#!/bin/bash -v
# @name: vufind_subversion_backup.sh
# @version: 1.0
# @creation_date: 2018-09-07
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This script backs up VuFind integration scripts and source code to Subversion

DATE=$(date +'%Y%m%d')

cd /home/vufind/svn

cp -ra /home/vufind/bin/* bin/
cp -ra /home/vufind/scripts/* scripts/
cp -ra /home/vufind/backup/vufind.$DATE/source_code/* source_code

svn add --force .

svn commit -m "Updating Subversion copy of VuFind integration scripts and source code"
