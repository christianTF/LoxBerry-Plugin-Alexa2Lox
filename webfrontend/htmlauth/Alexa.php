<?php
header('Content-Type: text/plain');

require_once "loxberry_system.php";
require_once "lib/alexa_env.php";

$_home=LBPHTMLAUTHDIR;
$_data=LBPDATADIR;

//B&B Technik OG
//Peter Bazala
//02/2017

echo("\n");

echo("B&B Technik OG:\n");
echo("\n\n");

$Daten = ($_GET["daten"]);

passthru("bash /$_home/start.sh $Daten"); 

echo " Datenübergabe: ","$Daten\n";

?>