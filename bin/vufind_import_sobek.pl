#!/usr/bin/perl -w
# @name: vufind_import_sobek.pl
# @version: 1.0
# @creation_date: 2016-07-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Scanbit <info.sca.ils@gmail.com>
#
# @purpose:
# This program will load the bib data exported from SobekCM into VuFind.
 
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
my $ole_timestamp = strftime("%Y-%m-%d", localtime);
my $yesterday_timestamp = strftime("%Y-%m-%d", localtime);
 
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

my $collection = "SOAS Digital Library";
my $server = "vfprod01.lis.soas.ac.uk";

 
##############################################################################################################
sub log_message
# Writes messages to the log file
#
	{
		$timestamp= strftime("%Y%m%d%H%M%S", localtime);
		print program_log ("$timestamp - $program_id : $message \n") or die "Cannot print $program_id log file: $!";
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
sub index_sobek
# Import sobek records
#
	{
		$message = "Importing sobek records";
		chdir  $VUFIND_DIR or die "can't chdir to /usr/local/vufind: $!";
		$CMD = "\.\/import-marc_sobek.sh \/usr\/local\/vufind\/local\/harvest\/Sobek\/sobek.mrc";
		system($CMD);
		$message = "Sobek records have been imported.";
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
 
if ($ils_code_action eq "sobeknightly")
{
	drop_collection_index;
	index_sobek;
	optimize_vufind_index;
	create_alphabetic_index;
}                              
elsif ($ils_code_action eq "sobekmonthly")
{
	index_sobek;
	optimize_vufind_index;
	create_alphabetic_index;
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