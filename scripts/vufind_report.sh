#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local

#df -k | mailx -s "Report size" againzarain@scanbit.net itsupport@scanbit.net ft9@soas.ac.uk bj1@soas.ac.uk
tail -100 /home/vufind/logs/vufind_main_run.log | mailx -s "Report log $(hostname)" sb174@soas.ac.uk ap87@soas.ac.uk 
##tail -100 /home/vufind/logs/vufind_main_run.log | mailx -s "Report log $(hostname)" againzarain@scanbit.net itsupport@scanbit.net ft9@soas.ac.uk bj1@soas.ac.uk
#w  | mailx -s "CPU log" againzarain@scanbit.net  itsupport@scanbit.net ft9@soas.ac.uk bj1@soas.ac.uk

echo -e "\nSYSTEM STATE $date" > /tmp/report.txt
echo -e "\nDisk Usage \n" >> /tmp/report.txt
df -h  >> /tmp/report.txt
echo -e "\nMemory Usage\n" >> /tmp/report.txt
free -m  >> /tmp/report.txt
echo -e "\nProcess Running\n" >> /tmp/report.txt
top -b -n 1 >> /tmp/report.txt

mailx -s "System State $(hostname)"  sb174@soas.ac.uk ap87@soas.ac.uk ft9@soas.ac.uk bj1@soas.ac.uk csbs@soas.ac.uk < /tmp/report.txt
