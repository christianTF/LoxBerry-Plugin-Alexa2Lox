#!/bin/sh
#
home="/opt/loxberry/webfrontend/cgi/plugins/alex2lox"
TMP="/tmp"
DEVLIST=/$TMP/.alexa.devicelist.json
COOKIE="/$TMP/.alexa.cookie"

echo $home
if [ -d /run/shm/alex2lox/ ] ; then 
Ram=/run/shm/alex2lox
echo "Verwende Ram Disk......"
else
Ram=/opt/loxberry/webfrontend/cgi/plugins/alex2lox
echo "Verwende Plugin Verzeichniss"
fi

Data1=$1
Data2=$2
Data3=$3
Data4=$4
Data5=$5

EMAIL=$( grep 'EMAIL=' /opt/loxberry/webfrontend/cgi/plugins/alex2lox/amazon.txt |/bin/sed 's/EMAIL=//g'  )
PASSWORD=$( grep 'Passwort=' /opt/loxberry/webfrontend/cgi/plugins/alex2lox/amazon.txt |/bin/sed 's/Passwort=//g'  )



echo $Data1 $Data2 $Data3 $Data4 $Data5


if [ "$1" != "-z" ] ; then

###############################################
#Original Script ausführen
###############################################

echo "Ab zu Remote Script"
export EMAIL=$EMAIL
export PASSWORD=$PASSWORD
sh ./alexa_remote_control.sh $Data1 $Data2 $Data3 $Data4$Data5
exit 1
   fi
###############################################
#Zusatz Script ausführen
###############################################
echo "Ab zum B&B Script"




if [ "$2" = "Einkaufsliste" ] ; then

echo EK Liste abfragen


curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/namedLists/" > $Ram/listid.txt
jq '.[]' /$Ram/listid.txt >  /$Ram/listid.json
cat /run/shm/alex2lox/listid.json | jq '.[].itemId' | /bin/sed 's/"//g'>/$Ram/ListIds.txt
read ShoppingListId  < /run/shm/alex2lox/ListIds.txt
echo ShoppingListId  $ShoppingListId 


curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/namedLists/$ShoppingListId/items?startTime=&endTime=&completed=&listIds=$ShoppingListId" > /$Ram/ekliste.conf

jq '.[]' /$Ram/ekliste.conf >  /$Ram/ekliste.json

echo EINKAUFS-LISTE  >/$Ram/EkListe
echo --------------  >>/$Ram/EkListe
echo   >>/$Ram/EkListe

cat /run/shm/alex2lox/ekliste.json | jq '.[].value'| /bin/sed 's/"//g'  >>/$Ram/EkListe


if [ "$3" = "Drucken" ] ; then

lp /$Ram/EkListe

fi


else



jq -r '.devices[].accountName' /$TMP/.alexa.devicelist.json >  /$home/devices.conf

#zusätzlich eingefügt


Curl=$2
DEVICE=$2
echo $Curl



LOXIP=$( grep 'LOXIP=' $home/$Curl.conf |/bin/sed 's/LOXIP=//g'  )
LOXPASS=$( grep 'LOXPASS=' $home/$Curl.conf |/bin/sed 's/LOXPASS=//g'  )
LOXUSER=$( grep 'LOXUSER=' $home/$Curl.conf |/bin/sed 's/LOXUSER=//g'  )
LoxTitel=$( grep 'LoxTitel=' $home/$Curl.conf |/bin/sed 's/LoxTitel=//g'  )
LoxInterpret=$( grep 'LoxInterpret=' $home/$Curl.conf |/bin/sed 's/LoxInterpret=//g'  )
LoxAlbum=$( grep 'LoxAlbum=' $home/$Curl.conf |/bin/sed 's/LoxAlbum=//g'  )
UDPPORT=$( grep 'UDPPORT=' $home/$Curl.conf |/bin/sed 's/UDPPORT=//g'  )
HTTPPORT=$( grep 'HTTPPORT=' $home/$Curl.conf |/bin/sed 's/HTTPPORT=//g'  )


if [ -z "$HTTPPORT" ] ; then
HTTPPORT=80
fi

if [ $HTTPPORT -eq 80 ] ; then
HTTPPORT=80
fi


	DEVICE=$(echo ${DEVICE} | sed -r 's/%20/ /g')
	
	if [ -z "${DEVICE}" ] ; then
		# if no device was supplied, use the first Echo(dot) in device list
		echo "setting default device to:"
		DEVICE=$(jq -r '[ .devices[] | select(.deviceFamily == "ECHO" or .deviceFamily == "KNIGHT" ) | .accountName] | .[0]' ${DEVLIST})
		echo ${DEVICE}
	fi

	DEVICETYPE=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .deviceType' ${DEVLIST})
	DEVICESERIALNUMBER=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .serialNumber' ${DEVLIST})
	MEDIAOWNERCUSTOMERID=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .deviceOwnerCustomerId' ${DEVLIST})

	if [ -z "${DEVICESERIALNUMBER}" ] ; then
		echo "ERROR: unkown device dev:${DEVICE}"
		exit 1
	fi






#echo -n $Curl Daten auslesen | nc -4u $LOXIP $UDPPORT
	



#Playerstatus abfragen

curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/np/player?deviceSerialNumber=$DEVICESERIALNUMBER&deviceType=$DEVICETYPE" > /$Ram/$Curl.txt










#cat $Ram/$Curl.txt

VAR="$(cat /$Ram/$Curl.txt)"
echo  $VAR | tr "," "\n" |/bin/sed 's/"//g'|/bin/sed 's/{//g' |/bin/sed 's/}//g' |/bin/sed 's/`//g' |/bin/sed -e's/volume:muted/ /g' |/bin/sed 18,23D > /$Ram/$Curl.txt





curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/notifications?cached=true" > /$Ram/Notifications.txt	

 jq  '.[]' /$Ram/Notifications.txt >  /$Ram/Notifications.conf







#BT status abfragen

curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/bluetooth?cached=true" > /$Ram/bt.txt


                jq  '.[]?' /$Ram/bt.txt >  /$Ram/bt.conf


cat /$Ram/bt.txt > /dev/udp/$LOXIP/$UDPPORT	
	

VAR="$(cat /$Ram/bt.txt)"
echo  $VAR | tr "," "\n" |/bin/sed 's/"//g'|/bin/sed 's/{//g' |/bin/sed 's/}//g' |/bin/sed 's/`//g' |/bin/sed -e's/volume:muted/ /g' |/bin/sed 18,23D > /$Ram/bt.txt
echo $DEVICE1


#Google Kalender abfrage

curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://${ALEXA}/api/cards/" > /$Ram/card.txt

echo -n Kalender Daten Start > /dev/udp/$LOXIP/$UDPPORT
jq '.[]' /$Ram/card.txt >  /$Ram/card.conf
jq -r '.[]? | .eonEventList, .eonLinks' /$Ram/card.conf > /$Ram/card1.conf
jq -r '.[]? | {title,startTime,endTime}' /$Ram/card1.conf > /$Ram/card2.conf
awk '{if (a[$0]==0) {a[$0]=1; print}}' /$Ram/card2.conf >/$Ram/card3.conf

split -d -l 20 /$Ram/card3.conf /$Ram/card.conf 
cat $Ram/card.conf > /dev/udp/$LOXIP/$UDPPORT

if [ -e $Ram/card.conf01 ]; then
cat $Ram/card.conf01 > /dev/udp/$LOXIP/$UDPPORT
fi

if [ -e $Ram/card.conf02 ]; then
cat $Ram/card.conf02 > /dev/udp/$LOXIP/$UDPPORT
fi

echo -n Kalender Daten Ende > /dev/udp/$LOXIP/$UDPPORT






#------------------------------------------------------------------------------------------------------------------------------


Titel=$( grep 'title:' $Ram/$Curl.txt |/bin/sed 's/title://g'  )
 Album=$( grep 'subText1:' $Ram/$Curl.txt |/bin/sed 's/subText1://g'  )
 Interpret=$( grep 'subText2:' $Ram/$Curl.txt |/bin/sed 's/subText2://g'  )
 Volume=$( grep 'volume:' $Ram/$Curl.txt |/bin/sed 's/volume://g'  )
 Bild=$( grep 'url:' $Ram/$Curl.txt |/bin/sed 's/url://g'  )
 Status=$( grep 'state:' $Ram/$Curl.txt |/bin/sed 's/state://g'  )
 Mediaid=$( grep 'mediaId:' $Ram/$Curl.txt |/bin/sed 's/mediaId://g'  )
 Queueid=$( grep 'queueId:' $Ram/$Curl.txt |/bin/sed 's/queueId://g'  )
 Provider=$( grep 'providerName:' $Ram/$Curl.txt |/bin/sed 's/providerName://g'  )
 Repeat=$( grep 'repeat:' $Ram/$Curl.txt |/bin/sed 's/repeat://g'  )
 Shuffle=$( grep 'shuffle:' $Ram/$Curl.txt |/bin/sed 's/shuffle://g'  )

#Daten für Loxone Urldecoden Leerzeichen entfernen

	Titel1=$(echo $Titel |/bin/sed -e 's/ /%20/g')
	Interpret1=$(echo $Interpret |/bin/sed -e 's/ /%20/g')
	Album1=$(echo $Album |/bin/sed -e 's/ /%20/g')
	Info1=$(echo $Info |/bin/sed -e 's/ /%20/g')


echo "Tite1= "$Titel 
echo "Tite1l= "$Titel1
echo "Interpret= "$Interpret1
echo "Album= "$Album1 
echo "Album= "$Album 
echo "Interpret= "$Interpret 
echo "Volume= "$Volume 
echo "Bild= "$Bild 
echo "Status= "$Status
echo "MediaID= "$Mediaid
echo "QueueID= "$Queueid
echo "Provider= "$Provider
echo "Shuffle= "$Shuffle
echo "Repeat= "$Repeat
echo "$Info1"
echo $DEVICESERIALNUMBER
echo $DEVICETYPE
echo $MEDIAOWNERCUSTOMERID






echo Lox IP $LOXIP
echo Lox Pass $LOXPASS
echo Lox User $LOXUSER
echo Lox Titel $LoxTitel
echo Lox Interpret $LoxInterpret
echo Lox Album $LoxAlbum
echo Lox UDP Port $UDPPORT
echo Lox HTTP Port $HTTPPORT

echo ende
echo $Curl

echo -n $Curl Status $Status $Shuffle $Repeat > /dev/udp/$LOXIP/$UDPPORT	

if [ "$Repeat" = "ENABLED" ]
then
Repeat1=0

fi
if [ "$Repeat" = "SELECTED" ]
then
Repeat1=1

fi

if [ "$Shuffle" = "ENABLED" ]
then
  Shuffle1=0

fi
if [ "$Shuffle" = "SELECTED" ]
then
  Shuffle1=1

fi
if [ "$Status" = "PLAYING" ]
then
  Status1=1

fi
if [ "$Status" = "PAUSED" ]
then
  Status1=2

fi
if [ "$Status" = "IDLE" ]
then
  Status1=0

fi
if [ "$Titel" = "null" ]
then
  Titel=keine Daten

fi

if [ "$Interpret1" = "null" ]
then
  Interpret1=-
fi
if [ "$Album1" = "null" ]
then
  Album1=-
fi

if [ "$Titel11" = "null" ]
then
  Titel1=-
fi

		echo -n TCP Daten Alexa Start > /dev/udp/$LOXIP/$UDPPORT
		output3=$(wget -4 -q -O - --user $LOXUSER --password $LOXPASS http://$LOXIP:$HTTPPORT/dev/sps/io/$LoxAlbum/$Album1)
	 	output4=$(wget -4 -q -O - --user $LOXUSER --password $LOXPASS http://$LOXIP:$HTTPPORT/dev/sps/io/$LoxInterpret/$Interpret1)
	 	output1=$(wget -4 -q -O - --user $LOXUSER --password $LOXPASS http://$LOXIP:$HTTPPORT/dev/sps/io/$LoxTitel/$Titel1)
	 	output9=$(wget -4 -q -O - --user $LOXUSER --password $LOXPASS http://$LOXIP:$HTTPPORT/dev/sps/io/$LoxINFO/$Info1)
		echo -n TCP Daten Alexa Ende > /dev/udp/$LOXIP/$UDPPORT
echo -n --------------------------------------------------------------------------------- > /dev/udp/$LOXIP/$UDPPORT

echo -n UDP Daten Alexa Start > /dev/udp/$LOXIP/$UDPPORT

echo -n $Curl Status: $Status1 / Repeat: $Repeat1/ Shuffle: $Shuffle1 / Volume: $Volume> /dev/udp/$LOXIP/$UDPPORT
echo -n $Curl Shuffle $Shuffle1 > /dev/udp/$LOXIP/$UDPPORT
#echo -n $Curl Volume $Volume > /dev/udp/$LOXIP/$UDPPORT
echo -n $Curl MediaID: $Mediaid / QueuID: $Queueid > /dev/udp/$LOXIP/$UDPPORT
#echo -n $Curl QueuID $Queueid: > /dev/udp/$LOXIP/$UDPPORT

 menge=$( tr -s " " "\n" < /$Ram/Notifications.conf | grep -c alarmTime )
echo "es sind $menge Timmereintraege vorhanden"




if [ "$menge" -ge 1 ]
    then
jq -r '.[0] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 2 ]
then
jq -r '.[1] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 3 ]
then
jq -r '.[2] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 4 ]
then
jq -r '.[3] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 5 ]
then
jq -r '.[4] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi  
if [ "$menge" -ge 6 ]
then
jq -r '.[5] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 7 ]
then
jq -r '.[6] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 8 ]
then
jq -r '.[7] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi
if [ "$menge" -ge 9 ]
then
jq -r '.[8] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi		
if [ "$menge" -ge 10 ]
then
jq -r '.[9] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
fi


echo Daten Gesendet.........................................................................................................................................








echo -n UDP Daten Alexa Ende > /dev/udp/$LOXIP/$UDPPORT
echo -n --------------------------------------------------------------------------------- > /dev/udp/$LOXIP/$UDPPORT

fi

