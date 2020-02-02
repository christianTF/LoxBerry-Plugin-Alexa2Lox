#!/bin/sh
#

. ./_plugindirs.sh
home="$LBPHTMLAUTHDIR"
Ram=/run/shm/alex2lox

jq  '.[]?' /$TMP/.alexa.IMPORTED.list >  /$Ram/IMPORTED
jq  '.[]?' /$TMP/.alexa.prime-sections.list >  /$Ram/prime-sections
jq  '.[]?' /$TMP/.alexa.PURCHASES.list >  /$Ram/PURCHASES
jq  '.[]?' /$TMP/.alexa.prime-playlist-browse-nodes.list >  /$Ram/PLAYLIST

echo DONE....
