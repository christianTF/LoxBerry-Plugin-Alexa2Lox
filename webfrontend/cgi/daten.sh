#!/bin/sh
#
home=/opt/loxberry/webfrontend/cgi/plugins/alex2lox
Ram=/run/shm/alex2lox
Tmp=/tmp


jq  '.[]?' /$Tmp/.alexa.IMPORTED.list >  /$Ram/IMPORTED
jq  '.[]?' /$Tmp/.alexa.prime-sections.list >  /$Ram/prime-sections
jq  '.[]?' /$Tmp/.alexa.PURCHASES.list >  /$Ram/PURCHASES
jq  '.[]?' /$Tmp/.alexa.prime-playlist-browse-nodes.list >  /$Ram/PLAYLIST

echo DONE....
