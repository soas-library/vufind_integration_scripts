#!/usr/bin/perl -w
# @name: vufind_import_doab.pl
# @version: 1.0
# @creation_date: 2018-08-24
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This program will load the data exported from Directory of Open Access Books into VuFind.
 
require 5.10.1;
 
use strict;
 
use POSIX qw(strftime);
 
use Config::Tiny;
 
my $BIN_DIR="/home/vufind/bin/";
my $SCRIPT_DIR = "/home/vufind/scripts/";
my $LOG_DIR="/home/vufind/logs/";
my $VUFIND_DIR="/usr/local/vufind/";
my $VUFIND_UTIL_DIR="/usr/local/vufind/util/";
my $VUFIND_HARVEST_DIR="/usr/local/vufind/harvest/";

my $harvest_log_file = "xxx";
my $harvest_log = "xxx";
my $vufind_log_prefix = "vufind_harvest_doab_log_";
my $program_log = "vufind_import_doab.log";
my $timestamp= strftime("%Y%m%d%H%M%S", localtime);
my $date= strftime("%d.%m.%y", localtime);
my $file_date = strftime("%d.%m.%y", localtime);
my $program_id = "vufind_import_doab";
my $yesterday_timestamp = strftime("%Y-%m-%d", localtime);
 
my $oai_source = "DOAB";
my $oai_properties = "doab.properties";
my $collection = "Directory of Open Access Books";
my $recordtype = "doab";
my $server = "vfdev01.lis.soas.ac.uk";

my $source = "xxx";
my $frequency = "xxx";
my $source_frequency = "xxx";
my $file_count = 0;

my $CMD;
my $message;
my $config = Config::Tiny->new();
 
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
		$CMD =   "wget 'http://$server:8080/solr/biblio/update?stream.body=<delete><query>recordtype:\"$recordtype\"</query></delete>&commit=true'";
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
sub create_alphabrowse_index
# Create the alphabrowse index
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
# Runs the process to import specified OAI-PMH sources into VuFind's index.
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

##############################################################################################################
#                      The main program flow follows
#
##############################################################################################################
open program_log, ">>$LOG_DIR$program_log" or die "Cannot open $program_id log: $!";
$message = " ** Has Started Processing";
log_message;
if (!$ARGV[0])
{
   
    $message = "No target source or frequency passed to program";
    log_message;
    $message = " ** Program Failed to complete ** ";
    close program_log or die "Cannot close  $program_id log: $!";
    exit;
}
 
$source=$ARGV[0];
$message = "The import source is $source";
log_message;
$frequency=$ARGV[1];
$message = "The import frequency is $frequency";
log_message;
$source_frequency = "$source$frequency";
 
if ($source_frequency eq "doabnightly")
{
	import_sources;
	optimize_vufind_index;
	create_alphabrowse_index;
}                              
elsif ($source_frequency eq "doabweekly")
{
	drop_collection_index;
	import_sources;
	optimize_vufind_index;
	create_alphabrowse_index;
}
else
{
	$message = "Invalid source or frequency passed to program = $source_frequency";
	log_message;
	close program_log or die "Cannot close  $program_id log: $!";
	exit;
}                        
 
$timestamp= strftime("%Y%m%d%H%M%S", localtime);
$message = " ** Has Finished";
log_message;
close program_log or die "Cannot close program log: $!";
