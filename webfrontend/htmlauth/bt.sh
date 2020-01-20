#!/bin/bash
. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"

echo $home
LOXIP=$( grep 'LOXIP=' $home/MS.conf |/bin/sed 's/LOXIP=//g'  )
UDPPORT=$( grep 'UDPPORT=' $home/MS.conf |/bin/sed 's/UDPPORT=//g'  )


befehl=$1
mac=$2

echo $mac
echo $befehl

if [ $befehl == "connect" ];then
echo -e "$befehl $mac" | bluetoothctl
echo -n Alexa BT $befehl $mac TTS Start 1 > /dev/udp/$LOXIP/$UDPPORT
fi


if [ $befehl == "disconnect" ];then
echo -e "$befehl $mac" | bluetoothctl
echo -n Alexa BT $befehl $mac TTS Ende 0 > /dev/udp/$LOXIP/$UDPPORT
fi