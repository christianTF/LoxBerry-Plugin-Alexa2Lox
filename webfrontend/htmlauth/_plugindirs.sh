#!/usr/bin/bash

# This script sets variables for the plugin directories and should be sourced by all other scripts
# Variables are equivalent to PHP's constants

LBHOMEDIR=REPLACELBHOMEDIR
LBPPLUGINDIR=REPLACELBPPLUGINDIR
LBPHTMLAUTHDIR=REPLACELBPHTMLAUTHDIR
LBPHTMLDIR=REPLACELBPHTMLDIR
LBPTEMPLATEDIR=REPLACELBPTEMPLATEDIR
LBPDATADIR=REPLACELBPDATADIR
LBPLOGDIR=REPLACELBPLOGDIR
LBPCONFIGDIR=REPLACELBPCONFIGDIR
LBPBINDIR=REPLACELBPBINDIR

GENERALCFG=$LBHOMEDIR/config/system/general.cfg

# Set TMP for femp directory
TMP="/tmp"


# Read MQTT Gateway UDP port
MQTTUDP=$(jq -r '.Mqtt.Udpinport' $LBHOMEDIR/config/system/general.json)
echo Used UDP port from MQTT Gateway: $MQTTUDP

# Set MQTT base topic
TOPIC=alexa2lox