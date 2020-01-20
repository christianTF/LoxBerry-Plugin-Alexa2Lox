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

$handle = fopen ( "/run/shm/alex2lox/print.txt", "w" );
    
    fwrite ( $handle, $_GET['daten'] );  
    fwrite ( $handle, "\n" );
    fclose ( $handle );
   


echo shell_exec("bash /$_home/print.sh /run/shm/alex2lox/print.txt"); 



echo " Datenübergabe: ","$Daten<br />\n";






?>