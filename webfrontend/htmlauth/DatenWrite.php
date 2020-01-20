<?php
require_once "loxberry_system.php";

$_home=LBPHTMLAUTHDIR;
$_data=LBPDATADIR;
  
echo exec("sh $_home/del.sh -a");
echo " Cookie wird gelöscht";

echo $_home;
     
$handle = fopen ( "$_home/amazon.txt", "w" );
    fwrite ( $handle, 'EMAIL=' );
    fwrite ( $handle, $_POST['EMAIL'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'Passwort=' );
    fwrite ( $handle, $_POST['Passwort'] );  
    fwrite ( $handle, "\n" );
    fclose ( $handle );
   echo "Einlesen der Daten von Alexa.amazon.com";

 echo exec("sh $_home/start.sh -a");
 echo exec("sh $_home/devices.sh");



	

 echo "Danke - Ihre Daten wurden speichert";
 header('Location: ./switch1.php'); exit;
 
    exit;

 



  
?>