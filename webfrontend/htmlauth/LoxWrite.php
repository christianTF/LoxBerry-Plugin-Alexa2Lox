<?php
require_once "loxberry_system.php";

//$_SERVER['HTTP_REFERER']; 
$_home = LBPHTMLAUTHDIR;
$_data = LBPDATADIR;
   
echo "Danke - Ihre Daten wurden geschrieben";

$datei=$_POST['AlexaNr'];
 
  
$handle = fopen ( "$_home/$datei.conf", "w" );
    fwrite ( $handle, 'LOXIP=' );
    fwrite ( $handle, $_POST['LOXIP'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'LOXUSER=' );
    fwrite ( $handle, $_POST['LOXUSER'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'LOXPASS=' );
    fwrite ( $handle, $_POST['LOXPASS'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'LoxTitel=VTI' );
    fwrite ( $handle, $_POST['LOXTitel'] );  
    fwrite ( $handle, "\n" );
  
    fwrite ( $handle, 'LoxInterpret=VTI' );
    fwrite ( $handle, $_POST['LOXInterpret'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'LoxAlbum=VTI' );
    fwrite ( $handle, $_POST['LOXAlbum'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'UDPPORT=' );
    fwrite ( $handle, $_POST['UDPPORT'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'HTTPPORT=' );
    fwrite ( $handle, $_POST['HTTPPORT'] );  
    fwrite ( $handle, "\n" );
    fclose ( $handle );
   
    fclose ( $handle );

$handle = fopen ( "$_home/MS.conf", "w" );
    fwrite ( $handle, 'LOXIP=' );
    fwrite ( $handle, $_POST['LOXIP'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'UDPPORT=' );
    fwrite ( $handle, $_POST['UDPPORT'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'HTTPPORT=' );
    fwrite ( $handle, $_POST['HTTPPORT'] );  
    fwrite ( $handle, "\n" );
    fclose ( $handle );


    echo "Danke - Ihre Daten wurden speichert";
header('Location: ./index.cgi'); exit;



//header('Location: ./umleit.php'); exit;
//header('Location: ./Index.php'); exit;
//header('Location:'.$_SERVER['HTTP_REFERER']);  
?>