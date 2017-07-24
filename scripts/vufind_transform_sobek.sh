#!/bin/sh
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export VUFIND_HOME=/usr/local/vufind/
export VUFIND_LOCAL_DIR=/usr/local/vufind/local
find  /usr/local/vufind/local/harvest/Sobek/ -name '*.xml' -exec rm {} \;
#find  /usr/local/vufind/local/harvest/Sobek/ -name '*.mrc' -exec rm {} \;
rm /usr/local/vufind/local/harvest/Sobek/last_harvest.txt
rm /usr/local/vufind/local/harvest/Sobek/last_state.txt
cd /usr/local/vufind/harvest
/usr/bin/php harvest_oai.php Sobek

#Convert XML into MARC
rm -Rf /usr/local/vufind/local/harvest/Sobek/sobek.mrc
cd /usr/local/vufind/local/harvest/Sobek/
#Delete wrong files

for file in /usr/local/vufind/local/harvest/Sobek/*.xml
do
  yaz-marcdump -i marcxml -o marc "$file" -v > "${file/.xml/.mrc}"
done
#Changing wrong files
rm /usr/local/vufind/local/harvest/Sobek/*AA00000082_00001*.mrc
rm /usr/local/vufind/local/harvest/Sobek/*AA00000083_00001*.mrc
cp /usr/local/vufind/local/harvest/Sobek/changed/*.mrc /usr/local/vufind/local/harvest/Sobek/
#End Changing wrong files
cat /usr/local/vufind/local/harvest/Sobek/*.mrc > /usr/local/vufind/local/harvest/Sobek/sobek.txt
rm -Rf /usr/local/vufind/local/harvest/Sobek/*.mrc
mv /usr/local/vufind/local/harvest/Sobek/sobek.txt /usr/local/vufind/local/harvest/Sobek/sobek.mrc


