#!/usr/bin/perl -w
# @name: vufind_100_ole_index.pl
# @version: 1.1
# @creation_date: 2014-11-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Barron <sb174@soas.ac.uk>
#
# @purpose:
# This program will load the bib data exported from OLE into VuFind.
# It will process either the file of daily changes or the weekly full index rebuild
# or the refresh of the Authority index. Once the index is built it will optimize it.
# Following the bib index load/optimize the alphabetic index is created.
# The opimizing of the bib and auth indices can be requested seperately as can the creation
# of the alphabetic index
#
# The program is called with 2 parameters - ILS source - currently only OLE and an action code as follows -
#    wkly for the full bib refresh
#    dly for the daily bib changes
#    auth for the authority index refresh
#    wklyo for the optimizing of the bib index
#    wklya for the creation of the alphabetic index
#    autho for the optimizing of the authority index
#
# @edited_date: 2017-08-15 Switched to new filenames for new OLE batch exports
#
require 5.10.1;

use strict;

use POSIX qw(strftime);

use Config::Tiny;

my $BIN_DIR="/home/vufind/bin/";
my $OUTDIR="/home/vufind/output/";
my $INPUTDIR="/home/vufind/input/";
my $WEEKDIR="/home/vufind/input/weekly/";
my $DAILYDIR="/home/vufind/input/daily/";
my $SCRIPT_DIR = "/home/vufind/scripts/";
my $LOG_DIR="/home/vufind/logs/";
my $VUFIND_DIR="/usr/local/vufind/";
my $VUFIND_UTIL_DIR="/usr/local/vufind/util/";
my $VUFIND_HARVEST_DIR="/usr/local/vufind/harvest/";

my $index_log_file = "xxx";
my $index_log = "xxx";
my $harvest_log_file = "xxx";
my $harvest_log = "xxx";
my $vufind_log_prefix = "vufind_full_index_log_";
my $vufind_dly_log_prefix = "vufind_dly_update_log_";
my $vufind_auth_log_prefix = "vufind_auth_update_log_";
my $program_log = "vufind_100_ole_index.log";
my $timestamp= strftime("%Y%m%d%H%M%S", localtime);
my $date= strftime("%d.%m.%y", localtime);
my $file_date = strftime("%d.%m.%y", localtime);
my $program_id = "vufind_100_ole_index";
my $ole_timestamp = strftime("%Y-%b-%d", localtime);
my $yesterday_timestamp = strftime("%Y-%b-%d", localtime);

my $oai_source = "SOAS_Research_Online";
my $oai_properties = "eprints.properties";
my $ils_code = "xxx";
my $file_prefix_nightly = "vufind_update_nightly-";
my $file_prefix_daily = "vufind_update_daily-";
my $file_prefix_auth = "vufind_update_auth-";
my $file_suffix_auth = "_yaz.mrc";

my $user_found = "N";
my $param_list = " ";
my $user_name = "xxx";
my $logon_id;
my $logon_pwd;

my $file_count = 0;
my $file_name_daily = "vufind_daily-$ole_timestamp";
my $file_name_nightly = "vufind_nightly-$ole_timestamp";
my $file_name = "vufind_full_export*$ole_timestamp";
my $daily_file_name;
my $auth_file_name;
my $marc_file_name;
my $file_suffix = "\.mrc";
my $CMD;
my $from = "xxx";
my $to = "xxx";
my $message;
my $ils_action = "xxx";
my $ils_code_action = "xxx";
my $config = Config::Tiny->new();
my $index_files_expected = 8;

my $collection  = "SOAS Library";
my $server = "vfdev01.lis.soas.ac.uk";

##############################################################################################################
sub log_message
# Writes messages to the log file
#
  	{
  		$timestamp= strftime("%Y%m%d%H%M%S", localtime);
	  	print program_log ("$timestamp - $program_id : $message \n") or die "Cannot print $program_id log file: $!";
  	}
################################################################################################################
sub ole_transfer
# Transfers each of the files created by OLE to the VuFind server. 
#
	{
        $CMD = "/home/vufind/scripts/ole_export_transfer_file.sh";

		chdir $SCRIPT_DIR or die "Can't chdir to $SCRIPT_DIR: $!";
		system($CMD);
	}
###############################################################################################################
sub check_ole_export {
# tg3 20150929
# Check that export exists and is sufficiently large to represent our collection
	my $export = shift;
	if ( -f $export) {
	   my $export_size = -s $export;
	   #MARC export was 952756922 bytes on 28/9/2015
	   if ($export_size >= 900000000) {
		$message = "Export from OLE: $export looks fine $export_size bytes";
		log_message;
		return 1;
	   } else {
                $message = "Export from OLE: $export is smaller than expected $export_size bytes";
                log_message;
		return 0;
	   }
	} else {
	 
          $message = "Export from OLE is missing: $export!";
          log_message;
	  return 0;
	}

}
################################################################################################################ 
sub concatenate_files_nightly
# Concatenates the extracted file into one and adds suffix .mrc. Copies the new file to the week directory.
#
 	{
  		$marc_file_name = "$file_prefix_nightly$file_date$file_suffix";
  		$CMD = "cat $INPUTDIR$file_name*.mrc > $DAILYDIR$marc_file_name";
		system($CMD);
		my $result = check_ole_export("$DAILYDIR$marc_file_name");
		return $result;
	}
#################################################################################################################
sub concatenate_files_daily
# Concatenates the extracted file into one and adds suffix .mrc. Copies the new file to the week directory.
# 
	{
		$marc_file_name = "$file_prefix_daily$file_date$file_suffix";
		$CMD = "cat $INPUTDIR$file_name_daily*.mrc > $DAILYDIR$marc_file_name";
		system($CMD);
		my $result = check_ole_export ("$DAILYDIR$marc_file_name");
		return $result;
	}
#################################################################################################################

sub drop_vufind_index
# Stops/Starts Vufind and drops the existing index and spell checking files. The sleep commands are in place to allow 
# the background processing to complete before the next step.
# Additionally a backup of last solr index is made
	{
 		chdir  $VUFIND_DIR or die "can't chdir to $VUFIND_DIR: $!";		    
		$CMD = "\.\/vufind.sh stop";	
 		system($CMD);
 		sleep(25);
		$CMD = "rm -f /home/vufind/backup/solr_backup/solr.tar.gz";
		system($CMD);
		$CMD = "tar -zcvf /home/vufind/backup/solr_backup/solr.tar.gz /usr/local/vufind/solr/";
		system($CMD);
 		$CMD = "rm -rf solr/biblio/index solr/biblio/spell* solr/biblio/tlog";
 		system($CMD);
		$CMD = "\.\/vufind.sh start";	
 		system($CMD);
 		sleep(120);
	}
################################################################################################################
sub drop_collection_index
# Stops/Starts Vufind and drops the existing index and spell checking files. The sleep commands are in place to allow
# the background processing to complete before the next step.
#
	{
		chdir  $VUFIND_DIR or die "can't chdir to $VUFIND_DIR: $!";
		$CMD =   "wget 'http://$server:8080/solr/biblio/update?stream.body=<delete><query>collection:\"$collection\"</query></delete>&commit=true'";
		system($CMD);
		$CMD =  "rm -Rf update?stream.body*";
		system($CMD);
		$message = "VuFind index dropped.";
                log_message;
	}
#################################################################################################################
sub load_vufind_refresh
# Rebuild the index using the weekly refresh data
#
	{
 		$message = "Rebuild of index has started";
		log_message;
		$index_log_file = "$vufind_log_prefix$date";
		$index_log = "$LOG_DIR$index_log_file";
		chdir  $VUFIND_DIR or die "can't chdir to $VUFIND_DIR: $!";		
		$CMD = "\.\/import-marc.sh $DAILYDIR$marc_file_name > $index_log";
		system($CMD);		
		$message = "Rebuild of index has ended. See log $index_log for details. ";
		log_message;
	}
##################################################################################################################	
sub optimize_vufind_index
# Optimize the index 
#
	{
		$message = "Optimize index has started";
		log_message;
		chdir  $VUFIND_UTIL_DIR or die "can't chdir to $VUFIND_UTIL_DIR: $!";		
		$CMD = "php optimize.php";
		system($CMD);		
		$message = "Optimize index has ended.";
		log_message;
	}
##################################################################################################################	
sub create_alphabetic_index
# Create the  alphabetic index 
#
	{
		$message = "Alphabetic index has started";
		log_message;
		chdir  $VUFIND_DIR or die "can't chdir to $VUFIND_DIR: $!";	
		$CMD = "\.\/index-alphabetic-browse.sh";	
		system($CMD);		
		$message = "Alphabetic index has ended.";
		log_message;
	}
#################################################################################################################
sub build_sitemap
# Build the sitemap for webcrawlers
#
	{
		$message = "Sitemap build has started";
		log_message;
		chdir  $VUFIND_UTIL_DIR or die "can't chdir to $VUFIND_UTIL_DIR: $!";
		$CMD = "php sitemap.php";
		system($CMD);
		$message = "Sitemap build has ended.";
		log_message;
	}
##############################################################################################################
#                      The main program flow follows
#
##############################################################################################################
open program_log, ">>$LOG_DIR$program_log" or die "Cannot open $program_id log: $!";
$message = " ** Has Started Processing";
log_message;
if (!$ARGV[0])
{
    
    $message = "No target ILS/action passed to program";
    log_message;
    $message = " ** Program Failed to complete ** ";
    close program_log or die "Cannot close  $program_id log: $!";
    exit;
}

$ils_code=$ARGV[0];
$message = "The import ILS source is $ils_code";
log_message;
$ils_action=$ARGV[1];
$message = "The import action is $ils_action";
log_message;
$ils_code_action = "$ils_code$ils_action";

if ($ils_code_action eq "olenightly")
{
	ole_transfer;
	if (concatenate_files_nightly) {
		$message = "Loading and building indexes for OLE MARC expor - $ils_code_action\n";
		log_message;
		ole_transfer;
		concatenate_files_nightly;
		drop_collection_index;
		load_vufind_refresh;
		optimize_vufind_index;
		create_alphabetic_index;
		build_sitemap; 
	} else {
		$message = "Warning: Marc Export does not exist or is smaller than expected";
		log_message;
		#SCB Avoid mailing
		#my $cmd = q[ssh -i /home/tg3/.ssh/report_rsa report@james.lis.soas.ac.uk mailx -r tg3@soas.ac.uk -s "'VuFind OLE catalogue data report - read me now'" tg3@soas.ac.uk library.systems@soas.ac.uk itsupport@scanbit.net < /home/vufind/bin/OleCatalogeDataReport_instructions.txt];
		#print $cmd . "\n";
		#system($cmd);
	} 		 	   
}
  		 
elsif ($ils_code_action eq "oledaily")
{
	ole_transfer;
	if (concatenate_files_daily) {
		$message = "Loading and building indexes for OLE MARC expor - $ils_code_action\n";
		log_message;
		load_vufind_refresh;
		optimize_vufind_index;
		create_alphabetic_index;
		#build_sitemap;
	} else {
		$message = "Warning: Marc Export does not exist or is smaller than expected";
		log_message;
	}			
}

else
{
	$message = "Invalid ILS/action passed to program = $ils_code_action";
	log_message;
	close program_log or die "Cannot close  $program_id log: $!";
	exit;
}

$timestamp= strftime("%Y%m%d%H%M%S", localtime);
$message = " ** Has Finished";
log_message;
close program_log or die "Cannot close program log: $!";
