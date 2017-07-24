#!/usr/bin/perl -w
# @name: vufind_housekeeping.pl
# @version: 1.0
# @creation_date: 2014-08-05
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author: Dave Bartlett
#
# @purpose:
# Call the program with number of days and a directory name
# The program will remove any files in the target that have not been modified in less than the number of days. e.g. a value of 3 will delete any files not modified in the last 3 days.
# The number of days value must be > 2.
#
use warnings;
use strict;
use POSIX qw(strftime);
my $program_id = "vufind_housekeeping";
my $filecount = 0;
my $TODAY = time;
my $TARGET_DIR = "xxxx";
my $days;
my $filename;
my $LOGFILE = "/home/vufind/logs/housekeeping/housekeeping.log";
my $wktime = 604800; 
#(ie 86400*7)

my $datestamp  = strftime("%Y%m%d%H%M", localtime);

#############################################################################
sub remove_old_files
{
    opendir DIR, "$TARGET_DIR" or die "Could not open directory $TARGET_DIR: $!";
    while ($filename = readdir DIR)
    {
		next if -d "$TARGET_DIR/$filename";
		my $mtime = (stat "$TARGET_DIR/$filename")[9];
        if ($TODAY - $wktime > $mtime)
			{
			$filecount++;
			print LOGFILE "$datestamp - Removing $TARGET_DIR/$filename as older than $days days\n";
			unlink "$TARGET_DIR/$filename";
			}
	}
    close DIR;
}
##################################################################################
# Main processing Start

if (!$ARGV[0])
          {die "You must supply number of days to the program\n";}
if (!$ARGV[1])
          {die "You must supply a directory path to the program\n";}        
$TARGET_DIR = "$ARGV[1]";
$days = "$ARGV[0]";

$wktime = ($days*86400);
open LOGFILE, ">>$LOGFILE" or die "Cannot open $program_id log: $!";
print LOGFILE "$datestamp - $program_id Housekeeping started for $TARGET_DIR\n";
if ($days < 3)
  {
    print LOGFILE "$datestamp - $program_id  Housekeeping canceled for $TARGET_DIR. Number of days must be > 2. Days input = $days\n";
    close LOGFILE;
    exit;
  }
remove_old_files;
print LOGFILE "$datestamp - Housekeeping ended for $TARGET_DIR with $filecount files removed\n";
close LOGFILE;