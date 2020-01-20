#!/bin/bash
. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"

unlink $home/alexa_remote_control.backup
mv $home/alexa_remote_control.sh $home/alexa_remote_control.backup

wget https://raw.githubusercontent.com/thorsten-gehrig/alexa-remote-control/master/alexa_remote_control.sh

if [ ! -e $home/alexa_remote_control.sh ]; then
	mv $home/alexa_remote_control.backup $home/alexa_remote_control.sh
fi

chmod +x $home/alexa_remote_control.sh
