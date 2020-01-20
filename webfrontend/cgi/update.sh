#!/bin/sh
#

home="/opt/loxberry/webfrontend/cgi/plugins/alex2lox"

cp $home/alexa_remote_control.sh $home/alexa_remote_control.backup

wget https://loetzimmer.de/patches/alexa_remote_control.sh 

chmod a+x alexa_remote_control.sh