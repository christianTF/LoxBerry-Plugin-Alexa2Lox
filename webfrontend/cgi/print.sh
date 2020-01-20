#!/bin/sh
#

Data=$1

echo Druck wird gestartet

lp $Data

/usr/sbin/lpadmin -p Thermodrucker -E
