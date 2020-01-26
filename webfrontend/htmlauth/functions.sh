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
		return 1
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
	 
	echo $NOTIFICATIONS

	echo $NOTIFICATIONS | jq  '.[]'

		
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

	echo $BLUETOOTH

	# jq  '.[]?' /$Ram/bt.txt >  /$Ram/bt.conf


	# cat /$Ram/bt.txt > /dev/udp/$LOXIP/$UDPPORT	
		

	# VAR="$(cat /$Ram/bt.txt)"
	# echo  $VAR | tr "," "\n" |/bin/sed 's/"//g'|/bin/sed 's/{//g' |/bin/sed 's/}//g' |/bin/sed 's/`//g' |/bin/sed -e's/volume:muted/ /g' |/bin/sed 18,23D > /$Ram/bt.txt
	# echo $DEVICE1

}

function query_calendar {


	echo Kalender abfragen

	CARDS=$(curl \
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
	 "https://alexa.amazon.de/api/Calendar/"\
	 )
	 
	 
	 
	 
	 
	 
	 #"https://alexa.amazon.de/api/cards/")



	echo "$CARDS" | jq .


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

# Listen abfragen
function query_namedLists {

	LISTAGE=604800
	if [ -f "$NAMEDLISTFILE" ]; then
		LISTAGE=$(($(date +%s) - $(date +%s -r "$NAMEDLISTFILE")))
	fi
	
	echo Alter des Caches der verfügbaren Listen: $LISTAGE Sekunden
	
	if [ "$LISTAGE" -gt "86400" ]; then
		# Cached list is too old or does not exist - request 
		echo Rufe verfügbare Listen von Amazon ab
		NAMEDLISTS=$(curl \
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
		 "https://alexa.amazon.de/api/namedLists/")
		
		echo "$NAMEDLISTS" > "$NAMEDLISTFILE"
	else
		echo Lese verfügbare Listen aus dem lokalen Cache
		NAMEDLISTS=$(<$NAMEDLISTFILE)
	fi
	 
	# echo $NAMEDLISTS

}

function query_shoppinglist
{

	if [ -z "$NAMEDLISTS" ]; then
		echo Variable für verfügbare Listen ist leer! Abbruch.
		return 1
	fi
	
	echo "Suche Einkaufsliste"
	
	local ListId=$(echo $NAMEDLISTS | jq -r '.lists[] | select(.type =="SHOPPING_LIST" and .defaultList==true) | .itemId')

	echo Frage Liste ab - ShoppingListId $ListId
	
	local List=$(curl \
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
	"https://alexa.amazon.de/api/namedLists/$ListId/items?startTime=&endTime=&completed=false&listIds=$ListId")

	#echo "$List" | jq .

	echo "Einkaufsliste (Listentrennzeichen $listDelimiter)"
	readarray -t Elements < <( echo "$List" | jq -r '.list[].value' )
	local JoinedElements=$(implode " $listDelimiter " "${Elements[@]}")
	echo "$JoinedElements"
	
	JSON_FORMAT='{ "topic":"%s", "value":"%s", "retain":"%s" }'
	echo Sende an MQTT Gateway...
	printf "$JSON_FORMAT" "$TOPIC/list/shopping" "$JoinedElements" "0" > /dev/udp/127.0.0.1/$MQTTUDP

}


function query_todolist
{

	if [ -z "$NAMEDLISTS" ]; then
		echo Variable für verfügbare Listen ist leer! Abbruch.
		return 1
	fi
	
	echo "Suche To-Do Liste"
	
	local ListId=$(echo $NAMEDLISTS | jq -r '.lists[] | select(.type =="TO_DO" and .defaultList==true) | .itemId')

	echo Frage Liste ab - ListId $ListId
	
	local List=$(curl \
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
	"https://alexa.amazon.de/api/namedLists/$ListId/items?startTime=&endTime=&completed=false&listIds=$ListId")

	#echo "$List" | jq .

	echo "To-Do Liste (Listentrennzeichen $listDelimiter)"
	readarray -t Elements < <( echo "$List" | jq -r '.list[].value' )
	local JoinedElements=$(implode " $listDelimiter " "${Elements[@]}")
	echo "$JoinedElements"
	
	local sendTopic="$TOPIC/list/todo"
	JSON_FORMAT='{ "topic":"%s", "value":"%s", "retain":"%s" }'
	echo Sende an MQTT Gateway...
	# printf "$JSON_FORMAT" "$TOPIC/list/todo" "$JoinedElements" "0" 
	# printf "$JSON_FORMAT" "$TOPIC/list/todo" "$JoinedElements" "0" > /dev/udp/127.0.0.1/$MQTTUDP

	jq -r -n --arg topic "$sendTopic" --arg value "$JoinedElements" '{ topic:($topic), value:($value)}' > /dev/udp/127.0.0.1/$MQTTUDP


}


# Fügt ein Bash array zusammen mit dem übergebenen Trennzeichen (1. Param)
# So wie in PHP implode, bzw. in Perl join
function implode {
	local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}";
}



