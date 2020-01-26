#!/bin/bash

# Load alle the functions from functons.sh

. ./functions.sh

###############################################################################
######################## HIER STARTET DAS SCRIPT ##############################
###############################################################################

. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"
DEVLIST=/$TMP/.alexa.devicelist.json
NAMEDLISTFILE=/$TMP/.alexa.namedlists.json
COOKIE="/$TMP/.alexa.cookie"

FULLCOMMAND=$@

# Commandline parsing Start

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
--original | --o)
	shift # past argument
    ORIGINALSCRIPTPARAMS=$@
    ;;
    # -z|--all)
    # ACTION="all"
	# DEVICE="$2"
    # shift # past argument
    # shift # past value
    # ;;
--notifications | --nl)
    PARAM_NOTIFICATIONS=true
    shift # past argument
    # shift # past value
    ;;
--shoppinglist | --sl)
    PARAM_SHOPPINGLIST=true
    shift # past argument
    # shift # past value
    ;;
--todolist | --tl)
    PARAM_TODOLIST=true
    shift # past argument
    # shift # past value
    ;;
--calendar | --cl)
    PARAM_CALENDAR=true
    shift # past argument
    # shift # past value
    ;;
--print)
    PARAM_PRINT=true
    shift # past argument
    # shift # past value
    ;;
--playerstate | --ps)
    PARAM_PLAYERSTATE=true
    shift # past argument
    # shift # past value
    ;;
--device | --d)
    DEVICE="$2"
    shift # past argument
    shift # past value
    ;;
--execute | --e)
    PARAM_EXECUTE="$2"
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
	listDelimiter=$( grep 'listDelimiter=' $LBPHTMLAUTHDIR/amazon.txt |/bin/sed 's/listDelimiter=//g'  )
	
	export EMAIL=$EMAIL
	export PASSWORD=$PASSWORD
	export MFA_SECRET="$MFA_SECRET"
	export LANGUAGE=de,en-US;q=0.7,en;q=0.3
else
	echo Von PHP aufgerufen - Umgebungsvariablen sollten gesetzt sein
	listDelimiter=${ALEXA2LOX_listDelimiter}
fi  

echo EMAIL: ${EMAIL}
echo MFA_SECRET:  ${MFA_SECRET}
echo

# Programmverzweigung

if [ ! -z "$ORIGINALSCRIPTPARAMS" ]; then

	echo "Lötzimmer Original-Script verwenden..."
	echo "Aufrufparameter: $ORIGINALSCRIPTPARAMS"
	sh ./alexa_remote_control.sh $ORIGINALSCRIPTPARAMS
	exit 0

fi

echo "Alexa2Lox Routinen werden verwendet..."

if [ -n "$PARAM_EXECUTE" ] ; then
	
	PARAM_SET=true
	echo Execute
	query_device
	alexa_execute
	
fi

if [ "$PARAM_PLAYERSTATE" = true ] ; then
	
	PARAM_SET=true
	echo Playerstatus
	query_device
	query_playerstate
	
fi

if [ "$PARAM_SHOPPINGLIST" = true ] ; then
	
	PARAM_SET=true
	echo Einkaufsliste
	query_namedLists
	query_shoppinglist

fi

if [ "$PARAM_TODOLIST" = true ] ; then

	PARAM_SET=true
	echo To-Do Liste
	query_namedLists
	query_todolist
	
fi

if [ "$PARAM_PRINT" = true ] ; then

	PARAM_SET=true
	echo Drucken
	lp /$Ram/EkListe
	exit

fi

if [ "$PARAM_NOTIFICATIONS" = true ] ; then

	PARAM_SET=true
	echo Benachrichtigungen
	query_notifications
	
fi

if [ "$PARAM_BLUETOOTH" = true ]; then

	PARAM_SET=true
	echo Bluetooth
	query_bluetooth
	
fi
	
if [ "$PARAM_CALENDAR" = true ]; then

	PARAM_SET=true
	echo Kalender
	query_calendar

fi

if [ -z "$PARAM_SET" ] ; then
	# Keiner der oben bekannten Funktionen wurde aufgerufen
	echo "Kein bekannter Befehl ausgeführt"
	exit

fi
