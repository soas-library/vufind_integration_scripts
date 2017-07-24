#!/usr/bin/perl -w
# Program Name: vufind_700_fix_auth_file
# Author: Dave Bartlett
# Created: April 2014
#
# Description:
# 	This program will take the Authority file output from the ILS and apply several changes to create a new file.
#   The changes are 
#                   1) Create a tag 001 for each Marc record. Where a tag already exists then replace it with the new value.
#                      The Tag 001 values are generated with the format vufnnnnnnn where nnnnnnn is a generated sequence
#                      number starting from 0000001.
#                   2) Remove any control characters in the file (^C etc).
#  In order to carry out the processing the file is passed through Yaz for conversion to and from raw Marc format and text.
#  The resulting edited file is in raw Marc format and is used by vufind_500_update_index to create the new Authority index.
# Change Log:
# Version - 1.0 - April 2014
# Comment: Original version created
#
#
#
require 5.006;

use strict;

use POSIX qw(strftime);
use Encode;
use Config::Tiny;



my $LOG_DIR="/home/vufind/logs/";

my $FILE_DIR_IN="/home/vufind/input/";
my $FILE_DIR_OUT="/home/vufind/output/";
my $datestamp  = strftime("%d.%m.%y", localtime);
my $timestamp= strftime("%Y%m%d%H%M%S", localtime);
my $program_id = "vufind_700_fix_auth_file";
my $program_log = "vufind_700_log";
my $date  = strftime("%a - %d\/%m\/%Y", localtime);
my $rec_length;
my $tag_id;
my $bib_code;
my $file_name_in = "xxxx";
my $file_name_out = "xxxx";
my $tmp_file = "vufind_700_tmp";
my $suffix = "_yaz";
my $prefix = "vufind_update_auth-";
my $leader_field = "xxxx";
my $leader_record_found = "N";
my $seq_number = "000000000";
my $bib_yaz_fixed = "auth_yaz_fixed";
my $bib_yaz_errors = "auth_yaz_errors";
my $bib_yaz_tmp = "auth_yaz_tmp";

my $in_record;

my $message = "xxx";

my $missing_001_count = 0;


my $CMD;
my $new_bib_ct = 0000000;
my $new_bib_id = "xxx";
my $bib_id_lit = "vuf";
my $new_tab_001 = "xxxx";
my $lead_zeroes;
my $bib_yaz_marc_suffix = "_yaz.mrc";
my $bib_yaz_marc_file;
##############################################################################################################
sub log_message
# Writes messages to the log file
#
  {
  	$timestamp= strftime("%Y%m%d%H%M%S", localtime);
  	print program_log ("$timestamp - $program_id : $message \n") or die "Cannot print $program_id log file: $!";
  	
  }
  
######################################################################################################################################
sub convert_marc_to_line
# 
# 
{
	$CMD = "yaz-marcdump $file_name_in > $file_name_out";				
	
	system($CMD);
	
}
######################################################################################################################################
sub convert_line_to_marc
# 
# 
{
	
	$bib_yaz_marc_file = "$prefix$datestamp$bib_yaz_marc_suffix";
	$CMD = "yaz-marcdump -i line -o marc $FILE_DIR_OUT$tmp_file > $FILE_DIR_OUT$bib_yaz_marc_file";				
	
	system($CMD);
	
}
######################################################################################################################################
sub parse_yaz_file
# 
# 
{
  open (tmp_file, ">:encoding(utf8)","$FILE_DIR_OUT$tmp_file") or die "Cannot open $tmp_file : $!";
  #binmode tmp_file, ':encoding(UTF-8)';
  open (main_file, "<:encoding(utf8)","$FILE_DIR_IN$file_name_out") or die "Cannot open $file_name_out: $!";
 
  while (defined($in_record = <main_file>) )
     {
       chomp $in_record;
       $in_record =~ tr/\015//d;;
       #$in_record =~ s/[^ -~]//g;
       $rec_length = length($in_record);
       
       $tag_id = substr ($in_record,0,4);
       if ($rec_length > 22)
          {
             $leader_field = substr ($in_record,19,5);
             #print "ldr = $leader_field\n";
             if ($leader_field eq " 4500")
               {
               	  
               	  print tmp_file ("$in_record\n") or die "Cannot print $tmp_file : $!";
               	  $new_bib_ct++;
               	  $lead_zeroes = sprintf("%08d", $new_bib_ct);
      						$new_bib_id = "$bib_id_lit$lead_zeroes";
       		 				$new_tab_001 = "001 $new_bib_id";
           				
           				$in_record = $new_tab_001;
           				print tmp_file ("$in_record\n") or die "Cannot print $tmp_file : $!";
           				next;
               }
          }
       if ($tag_id eq "001 " || $rec_length == 0)
          {
          	next;
          }
       print tmp_file ("$in_record\n") or die "Cannot print $tmp_file : $!";
     }
}

################################################################################################################

################################################################################################################
sub process_yaz_file
#  Process a single yaz file
#
{
     convert_marc_to_line;
     parse_yaz_file;
     convert_line_to_marc;
}


###################################################################################################################################
#
#                                       The main program flow follows
#
####################################################################################################################################
open program_log, ">>$LOG_DIR$program_log" or die "Cannot open $program_id log: $!";
$message = "** Has Started Processing";
log_message;
if (!$ARGV[0])
          {die "You must supply a file name to the program\n";}
$file_name_in = "$ARGV[0]";
$file_name_out = "$file_name_in$suffix";
chdir  $FILE_DIR_IN or die "can't chdir to $FILE_DIR_IN : $!";
if (-e "$FILE_DIR_IN$file_name_in" && -s "$FILE_DIR_IN$file_name_in" > 0)
 			  {
					  
						
						process_yaz_file;	
				}
else
  		  {
      		 
	    		 $message = "The input file $file_name_in does not exist or is empty";
	    		 log_message;
    		}					
						
$message = "** Has Finished **  ";
log_message;

close program_log or die "Cannot close program log: $!";


		
  





