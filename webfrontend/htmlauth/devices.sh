#!/bin/bash
#

. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"

jq -r '.devices[].accountName' /$TMP/.alexa.devicelist.json >  /$home/devices.conf

echo devices.conf geschrieben