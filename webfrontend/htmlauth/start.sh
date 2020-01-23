#!/bin/bash


##
## Funktions-Definitionen
##

# Devicetyp und Seriennummer aus Gerätename auslesen
function query_device {

	DEVICES=$(jq -r '.devices[].accountName' /$TMP/.alexa.devicelist.json)
	
	DEVICE=$(echo ${DEVICE,,} | sed -r 's/%20/ /g')

	if [ -z "${DEVICE}" ] ; then
		# if no device was supplied, use the first Echo(dot) in device list
		echo "setting default device to:"
		DEVICE=$(jq -r '[ .devices[] | select(.deviceFamily == "ECHO" or .deviceFamily == "KNIGHT" ) | .accountName] | .[0]' ${DEVLIST})
		echo $DEVICE
		DEVICE=${DEVICE,,}
	fi
	
	# Case-insensitive Suche nach Device machen, und den echten Devicenamen abfragen
	DEVICE=$(jq --arg device "$DEVICE" -r '.devices[] | select( .accountName|ascii_downcase == $device) | .accountName' ${DEVLIST})
	
	DEVICETYPE=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .deviceType' ${DEVLIST})
	DEVICESERIALNUMBER=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .serialNumber' ${DEVLIST})
	MEDIAOWNERCUSTOMERID=$(jq --arg device "${DEVICE}" -r '.devices[] | select(.accountName == $device) | .deviceOwnerCustomerId' ${DEVLIST})

	if [ -z "${DEVICESERIALNUMBER}" ] ; then
		echo "ERROR: unkown device dev:${DEVICE}"
		exit 1
	fi

}

## Status eines Players abfragen
function query_playerstate {

	# Playerstatus abfragen
	# Response-JSON in Variable PLAYER speichern

	echo Player abfragen...

	PLAYER=$(curl \
	-s \
	 -b  ${COOKIE} \
	 -A "Mozilla/5.0" \
	 --compressed \
	 -H "DNT: 1" \
	 -H "Connection: keep-alive" \
	 -L \
	 -H "Content-Type: application/json; charset=UTF-8" \
	 -H "Referer: https://alexa.amazon.de/spa/index.html" \
	 -H "Origin: https://alexa.amazon.de" \
	 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})" \
	 "https://alexa.amazon.de/api/np/player?deviceSerialNumber=$DEVICESERIALNUMBER&deviceType=$DEVICETYPE")

	# jq alternative operator:
	#	// empty ändert den String "null" in eine leere Ausgabe

	Title=$(echo $PLAYER | jq -M -r '.playerInfo.infoText.title  // empty')
	Album=$(echo $PLAYER | jq -e -M -r '.playerInfo.infoText.subText1 // empty')
	Interpret=$(echo $PLAYER | jq -M -r '.playerInfo.infoText.subText2  // empty')
	Volume=$(echo $PLAYER | jq -M -r '.playerInfo.volume.volume  // empty')
	Muted=$(echo $PLAYER | jq -M -r '.playerInfo.volume.muted')
	Repeat=$(echo $PLAYER | jq -M -r '.playerInfo.transport.repeat // empty')
	Shuffle=$(echo $PLAYER | jq -M -r '.playerInfo.transport.shuffle // empty')
	Bild=$(echo $PLAYER | jq -M -r '.playerInfo.mainArt.url // empty')
	Status=$(echo $PLAYER | jq -M -r '.playerInfo.state // empty')
	Mediaid=$(echo $PLAYER | jq -M -r '.playerInfo.mediaId // empty')
	Queueid=$(echo $PLAYER | jq -M -r '.playerInfo.queueId // empty')
	Provider=$(echo $PLAYER | jq -M -r '.playerInfo.provider.providerName // empty')

	echo Title:     $Title
	echo Album:     $Album
	echo Interpret: $Interpret
	echo Volume:    $Volume
	echo Muted:     $Muted
	echo Repeat:    $Repeat
	echo Shuffle:   $Shuffle
	echo Bild:      $Bild
	echo Status:    $Status
	echo Mediaid:   $Mediaid
	echo Queueid:   $Queueid
	echo Provider:  $Provider

	JSON_FORMAT='{ "topic":"%s", "value":"%s", "retain":"%s" }'
	echo Sende an MQTT Gateway...
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/title" "$Title" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/album" "$Album" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/artist" "$Interpret" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/volume" "$Volume" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/muted" "$Muted" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/repeat" "$Repeat" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/shuffle" "$huffle" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/arturl" "$Bild" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/state" "$Status" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/mediaId" "$Mediaid" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/queueId" "$Queueid" "0" > /dev/udp/127.0.0.1/$MQTTUDP
	printf "$JSON_FORMAT" "$TOPIC/$DEVICE/providerName" "$Provider" "0" > /dev/udp/127.0.0.1/$MQTTUDP

## Alte Konvertierungen der Stati

# if [ "$Repeat" = "ENABLED" ]
# then
# Repeat1=0

# fi
# if [ "$Repeat" = "SELECTED" ]
# then
# Repeat1=1

# fi

# if [ "$Shuffle" = "ENABLED" ]
# then
  # Shuffle1=0

# fi
# if [ "$Shuffle" = "SELECTED" ]
# then
  # Shuffle1=1

# fi
# if [ "$Status" = "PLAYING" ]
# then
  # Status1=1

# fi
# if [ "$Status" = "PAUSED" ]
# then
  # Status1=2

# fi
# if [ "$Status" = "IDLE" ]
# then
  # Status1=0

# fi
# if [ "$Titel" = "null" ]
# then
  # Titel=keine Daten

# fi

# if [ "$Interpret1" = "null" ]
# then
  # Interpret1=-
# fi
# if [ "$Album1" = "null" ]
# then
  # Album1=-
# fi

# if [ "$Titel11" = "null" ]
# then
  # Titel1=-
# fi



}

function query_notifications {
	echo Notifications abfragen...

	NOTIFICATIONS=$(curl \
	 -s \
	 -b  ${COOKIE} \
	 -A "Mozilla/5.0" --compressed \
	 -H "DNT: 1" \
	 -H "Connection: keep-alive" \
	 -L \
	 -H "Content-Type: application/json; charset=UTF-8" \
	 -H "Referer: https://alexa.amazon.de/spa/index.html" \
	 -H "Origin: https://alexa.amazon.de" \
	 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})" \
	 "https://alexa.amazon.de/api/notifications?cached=true")
	 

	# echo $NOTIFICATIONS | jq  '.[]' /$Ram/Notifications.txt >  /$Ram/Notifications.conf

		
	 # menge=$( tr -s " " "\n" < /$Ram/Notifications.conf | grep -c alarmTime )
	# echo "es sind $menge Timmereintraege vorhanden"




	# if [ "$menge" -ge 1 ]
		# then
	# jq -r '.[0] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 2 ]
	# then
	# jq -r '.[1] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 3 ]
	# then
	# jq -r '.[2] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 4 ]
	# then
	# jq -r '.[3] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 5 ]
	# then
	# jq -r '.[4] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi  
	# if [ "$menge" -ge 6 ]
	# then
	# jq -r '.[5] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 7 ]
	# then
	# jq -r '.[6] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 8 ]
	# then
	# jq -r '.[7] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi
	# if [ "$menge" -ge 9 ]
	# then
	# jq -r '.[8] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi		
	# if [ "$menge" -ge 10 ]
	# then
	# jq -r '.[9] | {timerLabel,reminderLabel,deviceSerialNumber,notificationIndex,status,recurringPattern,type,originalTime,remainingTime}' $Ram/Notifications.conf > /dev/udp/$LOXIP/$UDPPORT
	# fi


}

function query_bluetooth {

	echo Bluetooth-Status abfragen

	BLUETOOTH=$(curl \
	 -s \
	 -b ${COOKIE} \
	 -A "Mozilla/5.0" \
	 --compressed \
	 -H "DNT: 1" \
	 -H "Connection: keep-alive" \
	 -L \
	 -H "Content-Type: application/json; charset=UTF-8" \
	 -H "Referer: https://alexa.amazon.de/spa/index.html" \
	 -H "Origin: https://alexa.amazon.de" \
	 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})" \
	 "https://alexa.amazon.de/api/bluetooth?cached=true")

	# jq  '.[]?' /$Ram/bt.txt >  /$Ram/bt.conf


	# cat /$Ram/bt.txt > /dev/udp/$LOXIP/$UDPPORT	
		

	# VAR="$(cat /$Ram/bt.txt)"
	# echo  $VAR | tr "," "\n" |/bin/sed 's/"//g'|/bin/sed 's/{//g' |/bin/sed 's/}//g' |/bin/sed 's/`//g' |/bin/sed -e's/volume:muted/ /g' |/bin/sed 18,23D > /$Ram/bt.txt
	# echo $DEVICE1

}

function query_calendar {


	#Google Kalender abfrage

	set CARDS=$(curl \
	 -s \
	 -b ${COOKIE} \
	 -A "Mozilla/5.0" \
	 --compressed \
	 -H "DNT: 1" \
	 -H "Connection: keep-alive" \
	 -L \
	 -H "Content-Type: application/json; charset=UTF-8" \
	 -H "Referer: https://alexa.amazon.de/spa/index.html" \
	 -H "Origin: https://alexa.amazon.de" \
	 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
	 "https://${ALEXA}/api/cards/")

	#echo -n Kalender Daten Start > /dev/udp/$LOXIP/$UDPPORT
	#jq '.[]' /$Ram/card.txt >  /$Ram/card.conf
	#jq -r '.[]? | .eonEventList, .eonLinks' /$Ram/card.conf > /$Ram/card1.conf
	#jq -r '.[]? | {title,startTime,endTime}' /$Ram/card1.conf > /$Ram/card2.conf
	#awk '{if (a[$0]==0) {a[$0]=1; print}}' /$Ram/card2.conf >/$Ram/card3.conf

	# split -d -l 20 /$Ram/card3.conf /$Ram/card.conf 
	# cat $Ram/card.conf > /dev/udp/$LOXIP/$UDPPORT

	# if [ -e $Ram/card.conf01 ]; then
	# cat $Ram/card.conf01 > /dev/udp/$LOXIP/$UDPPORT
	# fi

	# if [ -e $Ram/card.conf02 ]; then
	# cat $Ram/card.conf02 > /dev/udp/$LOXIP/$UDPPORT
	# fi

	# echo -n Kalender Daten Ende > /dev/udp/$LOXIP/$UDPPORT

}

function query_shoppinglist {


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

}

### HIER STARTET DAS SCRIPT ###

. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"
DEVLIST=/$TMP/.alexa.devicelist.json
COOKIE="/$TMP/.alexa.cookie"

FULLCOMMAND=$@

# Commandline parsing Start

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -z|--all)
    ACTION="all"
	DEVICE="$2"
    shift # past argument
    shift # past value
    ;;
    --action)
    ACTION="$2"
    shift # past argument
    shift # past value
    ;;
    --device)
    DEVICE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo Optionen:
echo ACTION: $ACTION
echo DEVICE: $DEVICE
echo Full command: $FULLCOMMAND

# Commandline Parsing Ende

echo $home
if [ -d /run/shm/alex2lox/ ] ; then 
Ram=/run/shm/alex2lox
echo "Verwende Ram Disk......"
else
Ram=$LBPHTMLAUTHDIR
echo "Verwende Plugin Verzeichnis"
fi

echo "Prüfe auf Environment Variablen"
if [ "${ALEXA2LOXENV}" != "php" ]; then
	echo Lese Umgebungsvariablen vom Configfile
	EMAIL=$( grep 'EMAIL=' $LBPHTMLAUTHDIR/amazon.txt |/bin/sed 's/EMAIL=//g'  )
	PASSWORD=$( grep 'Passwort=' $LBPHTMLAUTHDIR/amazon.txt |/bin/sed 's/Passwort=//g'  )
	USE_OATH=$( grep 'use_oath=' $LBPHTMLAUTHDIR/amazon.txt |/bin/sed 's/use_oath=//g'  )
	if [ "$USE_OATH" = "true" ]; then
		MFA_SECRET=$( grep 'TOKEN=' $LBPHTMLAUTHDIR/amazon.txt |/bin/sed 's/TOKEN=//g'  )
		echo MFA_SECRET $MFA_SECRET
	fi
	export EMAIL=$EMAIL
	export PASSWORD=$PASSWORD
	export MFA_SECRET="$MFA_SECRET"
	export LANGUAGE=de,en-US;q=0.7,en;q=0.3
else
	echo Von PHP aufgerufen - Umgebungsvariablen sollten gesetzt sein
fi  

echo EMAIL: ${EMAIL}
echo MFA_SECRET:  ${MFA_SECRET}
echo

# Programmverzweigung

if [ -z "$ACTION" ]; then

	echo "Lötzimmer Original-Script verwenden..."
	sh ./alexa_remote_control.sh $FULLCOMMAND
	exit 1

elif [ "${ACTION,,}" == "playerstatus" ] || [ "${ACTION,,}" = "playerstate" ]; then

	echo Playerstatus
	query_device
	query_playerstate
	exit

elif [ "${ACTION,,}" == "einkaufsliste" ] || [ "${ACTION,,}" = "shoppinglist" ]; then

	echo Einkaufsliste
	query_shoppinglist
	exit

elif [ "${ACTION,,}" = "drucken" ] || [ "${ACTION,,}" = "print" ]; then

	echo Drucken
	lp /$Ram/EkListe
	exit

elif [ "${ACTION,,}" = "benachrichtigungen" ] || [ "${ACTION,,}" = "notifications" ]; then

	echo Benachrichtigungen
	query_notifications
	exit

elif [ "${ACTION,,}" = "bluetooth" ]; then

	echo Bluetooth
	query_bluetooth
	exit

elif [ "${ACTION,,}" = "kalender" ] || [ "${ACTION,,}" = "calendar" ]; then

	echo Kalender
	query_calendar
	exit
	
elif [ "${ACTION,,}" = "all" ]; then
	
	echo Alle Abfragen
	# Curl=$2
	
	query_device
	query_playerstate
	query_notifications
	query_bluetooth
	query_calendar
	exit

else

	# Funktionsaufruf query_device
	echo "Kein bekannter Befehl ausgeführt"
	exit

fi




