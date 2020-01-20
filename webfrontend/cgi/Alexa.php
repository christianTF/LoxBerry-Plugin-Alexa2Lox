<?php
$_home= "/opt/loxberry/webfrontend/cgi/plugins/alex2lox";
//B&B Technik OG
//Peter Bazala
//02/2017

 echo("<br />\n");
 echo("<br />\n");

echo("B&B Technik OG:<br />\n");
echo("<br />\n");
echo("<br />\n");

$Daten = ($_GET["daten"]);




echo shell_exec("bash /$_home/start.sh $Daten"); 



echo " Datenübergabe: ","$Daten<br />\n";






?>