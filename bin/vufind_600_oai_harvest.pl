#!/usr/bin/perl -w
# @name: vufind_600_oai_harvest.pl
# @version: 1.0
# @creation_date: 2014-10-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Barron <sb174@soas.ac.uk>
#
# @purpose:
# This program will run the OAI-PMH harvest for VuFind.
# As of writing, SOAS Library harvests from SOAS Research Online, an eprints repository for SOAS research.
#
# The progran is called with 1 parameter - an action code specifying daily or weekly changes.
#    wkly for the full refresh
#    dly for the daily changes
#
# Change Log:
# Version - 1.0 
# Comment: Original version created
#
#
require 5.10.1;

use strict;


use POSIX qw(strftime);

use Config::Tiny;

my $BIN_DIR="/home/vufind/bin/";
my $OUTDIR="/home/vufind/output/";
my $INDIR="/home/vufind/input/";
my $WEEKDIR="/home/vufind/input/weekly/";
my $DAYDIR="/home/vufind/input/daily/";
my $SCRIPT_DIR = "/home/vufind/scripts/";
my $LOG_DIR="/home/vufind/logs/";
my $VUFIND_DIR="/usr/local/vufind/";
my $VUFIND_UTIL_DIR="/usr/local/vufind/util/";
my $VUFIND_HARVEST_DIR="/usr/local/vufind/harvest/";
my $harvest_log_file = "xxx";
my $harvest_log = "xxx";
my $vufind_log_prefix = "vufind_full_oai_harvest_log_";
my $vufind_dly_log_prefix = "vufind_dly_oai_harvest_log_";
my $program_log = "vufind_600_oai_harvest.log";
my $timestamp= strftime("%Y%m%d%H%M%S", localtime);
my $date= strftime("%d.%m.%y", localtime);
my $file_date = strftime("%d.%m.%y", localtime);
my $program_id = "vufind_600_oai_harvest";
my $oai_source = "SOAS_Research_Online";
my $oai_properties = "eprints.properties";

my $ils_code = "xxx";
my $file_prefix_wkly = "vufind_update_weekly-";
my $file_prefix_dly = "vufind_update_daily-";
my $file_prefix_auth = "vufind_update_auth-";
my $file_suffix_auth = "_yaz.mrc";
my $user_found = "N";
my $param_list = " ";
my $file_count = 0;
my $file_name;
my $daily_file_name;
my $auth_file_name;
my $marc_file_name;
my $file_suffix = "\.mrc";
my $CMD;
my $from = "xxx";
my $to = "xxx";
my $message;
my $action = "xxx";
my $config = Config::Tiny->new();
my $index_files_expected = 8;

my $collection = "SOAS Research Online";
my $server = "vfdev01.lis.soas.ac.uk";


##############################################################################################################
sub log_message
# Writes messages to the log file
#
  {
  	$timestamp= strftime("%Y%m%d%H%M%S", localtime);
  	print program_log ("$timestamp - $program_id : $message \n") or die "Cannot print $program_id log file: $!";
  	
  }
#################################################################################################################
sub drop_oai_index
# Stops/Starts Vufind and drops the existing index. The sleep commands are in place to allow
# the background processing to complete before the next step.
#
    {
        chdir  $VUFIND_DIR or die "can't chdir to $VUFIND_DIR: $!";

		$CMD = "\.\/vufind.sh stop";
		system($CMD);
		sleep(25);
		$CMD = "rm -rf local/harvest/$oai_source";
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
		$CMD = "rm -Rf update?stream.body*";
		system($CMD);
	}

################################################################################################################ 
sub harvest_sources
# Runs the process to harvest all OAI-PMH sources specified in VuFind's harvest configuration files.
#
	{
		$message = "Harvesting of OAI-PMH sources has started";
		log_message;
		$harvest_log_file = "$vufind_log_prefix$date";
		$harvest_log = "$LOG_DIR$harvest_log_file";
		chdir $VUFIND_HARVEST_DIR or die "can't chdir to $VUFIND_HARVEST_DIR: $!";
		$CMD = "php -f harvest_oai.php";
		system($CMD);
		$message = "Harvesting of OAI-PMH sources has ended. See log $harvest_log for details.";
		log_message;
	}
#################################################################################################################
sub import_sources
# Runs the process to import specifified OAI-PMH sources into VuFind's index.
#
	{
		$message = "Importing of $oai_source has started";
		log_message;
		$harvest_log_file = "$vufind_log_prefix$date";
		$harvest_log = "$LOG_DIR$harvest_log_file";
		chdir $VUFIND_HARVEST_DIR or die "can't chdir to $VUFIND_HARVEST_DIR: $!";
		$CMD = "\.\/batch-import-xsl.sh $oai_source $oai_properties";
		system($CMD);
		$message = "Importing of $oai_source has ended. See log $harvest_log for details.";
		log_message;
	}
#################################################################################################################
sub delete_sources
# Runs the process to delete records for specified OAI_PMH sources.
#
	{
		$message = "Deleting of $oai_source records has started";
		log_message;
		$harvest_log_file = "$vufind_log_prefix$date";
		$harvest_log = "$LOG_DIR$harvest_log_file";
		chdir $VUFIND_HARVEST_DIR or die "can't chdir to $VUFIND_HARVEST_DIR: $!";
		$CMD = "\.\/batch-delete.sh $oai_source";
		system($CMD);
		$message = "Deleting of $oai_source records has ended. See log $harvest_log for details.";
		log_message;
    }
#################################################################################################################
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
##################################################################################################################
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
#####################################################################################################################
##############################################################################################################
#                      The main program flow follows
#
##############################################################################################################
open program_log, ">>$LOG_DIR$program_log" or die "Cannot open $program_id log: $!";
$message = " ** Has Started Processing";
log_message;
if (!$ARGV[0])
{
    
    $message = "No target action passed to program";
    log_message;
    $message = " ** Program Failed to complete ** ";
    close program_log or die "Cannot close  $program_id log: $!";
    exit;
}

$action=$ARGV[0];
$message = "The import action is $action";
log_message;

if ($action eq "weekly")
  		{
			drop_collection_index;
			drop_oai_index;
			harvest_sources;
			import_sources;
			optimize_vufind_index;
			create_alphabetic_index;
			#build_sitemap;
  		}
elsif ($action eq "monthly")
        {
            drop_oai_index;
            harvest_sources;
            import_sources;
            optimize_vufind_index;
            create_alphabetic_index;
            #build_sitemap;
        }
elsif ($action eq "daily")
	{
		harvest_sources;
		import_sources;
		delete_sources;
		optimize_vufind_index;
		create_alphabetic_index;
		#build_sitemap;
	}
else
        {
       	  $message = "Invalid action passed to program = $action";
       	  log_message;
       	  close program_log or die "Cannot close  $program_id log: $!";
       	  exit;
        } 		 


$timestamp= strftime("%Y%m%d%H%M%S", localtime);
$message = " ** Has Finished";
log_message;
close program_log or die "Cannot close program log: $!";
