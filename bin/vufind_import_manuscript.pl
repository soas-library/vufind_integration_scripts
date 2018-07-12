#!/usr/bin/perl -w
# @name: vufind_import_manuscript.pl
# @version: 1.0
# @creation_date: 2018-07-02
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This program will load SOAS Manuscript data exported from GitHub into VuFind.
 
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
 
my $import_log_file = "xxx";
my $import_log = "xxx";
my $vufind_log_prefix = "vufind_full_index_log_";
my $vufind_dly_log_prefix = "vufind_dly_update_log_";
my $vufind_auth_log_prefix = "vufind_auth_update_log_";
my $program_log = "vufind_import_manuscript.log";
my $timestamp= strftime("%Y%m%d%H%M%S", localtime);
my $date= strftime("%d.%m.%y", localtime);
my $file_date = strftime("%d.%m.%y", localtime);
my $program_id = "vufind_100_ole_index";
my $yesterday_timestamp = strftime("%Y-%m-%d", localtime);
 
my $oai_source = "manuscript";
my $oai_properties = "manuscript.properties";
 
my $file_count = 0;
my $daily_file_name;
my $CMD;
my $message;
my $ils_code = "xxx";
my $ils_action = "xxx";
my $ils_code_action = "xxx";
my $config = Config::Tiny->new();
my $index_files_expected = 8;

my $collection = "SOAS Manuscripts";
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
sub create_hierarchy_trees
# CreateHierarchyTrees
#
	{
		$message = "Create hierarchy tree has started";
		log_message;
		chdir  $VUFIND_UTIL_DIR or die "can't chdir to $VUFIND_UTIL_DIR: $!";
		$CMD = "php createHierarchyTrees.php";
		system($CMD);
		$message = "Create hierarchy trees has ended.";
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
sub import_sources
# Runs the process to import specifified OAI-PMH sources into VuFind's index.
#
	{
		$message = "Importing of $oai_source has started";
		log_message;
		$import_log_file = "$vufind_log_prefix$date";
		$import_log = "$LOG_DIR$import_log_file";
		chdir $VUFIND_HARVEST_DIR or die "can't chdir to $VUFIND_HARVEST_DIR: $!";
		$CMD = "\.\/batch-import-xsl.sh $oai_source $oai_properties";
		system($CMD);
		$message = "Importing of $oai_source has ended. See log $import_log for details.";
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
 
if ($ils_code_action eq "manuscriptdaily")
{
	#drop_collection_index;
	import_sources;
	optimize_vufind_index;
	create_alphabetic_index;
	create_hierarchy_trees;
}                              
elsif ($ils_code_action eq "manuscriptweekly")
{
	drop_collection_index;
	import_sources;
	optimize_vufind_index;
	create_alphabetic_index;
	create_hierarchy_trees;
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
