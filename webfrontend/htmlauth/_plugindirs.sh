#!/usr/bin/bash

# This script sets variables for the plugin directories and should be sourced by all other scripts
# Variables are equivalent to PHP's constants (

LBHOMEDIR=/opt/loxberry
LBPPLUGINDIR=alexa2lox
LBPHTMLAUTHDIR=/opt/loxberry/webfrontend/htmlauth/plugins/alexa2lox
LBPHTMLDIR=/opt/loxberry/webfrontend/html/plugins/alexa2lox
LBPTEMPLATEDIR=/opt/loxberry/templates/plugins/alexa2lox
LBPDATADIR=/opt/loxberry/data/plugins/alexa2lox
LBPLOGDIR=/opt/loxberry/log/plugins/alexa2lox
LBPCONFIGDIR=/opt/loxberry/config/plugins/alexa2lox
LBPBINDIR=/opt/loxberry/bin/plugins/alexa2lox

GENERALCFG=$LBHOMEDIR/config/system/general.cfg

# Set TMP for femp directory
TMP="/tmp"


# Read MQTT Gateway UDP port
MQTTUDP=$(jq -r '.Main.udpinport' $LBHOMEDIR/config/plugins/mqttgateway/mqtt.json)
echo Used UDP port from MQTT Gateway: $MQTTUDP

# Set MQTT base topic
TOPIC=alexa2lox
