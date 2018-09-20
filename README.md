# vufind_integration_scripts

Scripts on VuFind servers are run from /home/vufind/bin for Perl scripts and /home/vufind/scripts for shell scripts. Logs are kept in /home/vufind/logs. All scripts are run either directly from the root crontab or via the vufind_control_script from the root crontab. Run `crontab -e` as root to check all scripts running in Cron on the server.

## Shell scripts

Shell scripts are run from /home/vufind/scripts and either run tasks directly on the server via the command line or start the VuFind control script with different parameters to run different Perl scripts. 

## Perl scripts

Perl scripts are run from /home/vufind/bin and run tasks related to getting data from OLE and building the index for VuFind. 

## OLE transfer of Marc files

These scripts ensure that Marc files are transferred from the OLE server to the VuFind server regularly. The process works as follows:

1. vufind_control_script.sh 
   * The script is run with parameters specifying which program is to be run and with which attributes.
   * vufind_control_script.sh runs vufind_100_ole_index.pl.
2. vufind_100_ole_index.pl
   * get_logon_details retrieves required logon details for servers
   * ole_transfer assembles logon details and runs ole_export_transfer_file.sh with a long list of parameters
3. ole_export_transfer_file.sh
   * SSHs into the OLE server
   * Changes directory to the batch export file directory (on production, this is /usr/local/ole15/kuali/main/prd/olefs-webapp/work/staging/export/vufind_full_export/)
   * SFTPs into the VuFind server
   * Puts files from OLE server to VuFind server (on the VuFind server, Marc files are sent to /home/vufind/input/)
   * Exits
4. vufind_100_ole_index.pl
   * concatenate_files concatenates the .mrc files in /home/vufind/input into one big .mrc file in /home/vufind/input/daily
   * load_vufind_refresh indexes the file in /home/vufind/input/daily using import-marc.sh
   * optimize_vufind_index optimizes the index with optimize.php
   * create_alphabetic_index creates alphabrowse index with index-alphabetic-browse.sh
   * build_sitemap builds sitemap with sitemap.php

## Log files

Log files for the various VuFind scripts are kept in /home/vufind/logs/. Use tail to view the latest log updates.

vufind_100_ole_index.log and vufind_600_oai_harvest.log are simple logs of when vufind_100_ole_index.pl and vufind_600_oai_harvest.pl start and end.

vufind_main_run.log logs every command run by the vufind_control_script.sh. It's a verbose and thorough log of everything that happens during the scripts.

vufind_full_index_log_{$DATE} is a log of the bib indexing process. The log is generated when import-marc.sh runs. It should highlight any issues that occur during the indexing process: problems with the Solr config, problems with the Marc file, etc.

./housekeeping/housekeeping.log is a log of vufind_housekeeping.sh. It tells you exactly which files have been deleted during the housekeeping process and why.
