#!/bin/sh
#


home="/opt/loxberry/webfrontend/cgi/plugins/alex2lox"
TMP="/tmp"

jq -r '.devices[].accountName' /$TMP/.alexa.devicelist.json >  /$home/devices.conf

echo devices.conf geschrieben