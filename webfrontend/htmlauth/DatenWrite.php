<?php
require_once "loxberry_system.php";
require_once "lib/alexa_env.php";
       
$handle = fopen ( LBPCONFIGDIR."/amazon.cfg", "w" );
    fwrite ( $handle, 'EMAIL=' );
    fwrite ( $handle, $_POST['EMAIL'] );  
    fwrite ( $handle, "\n" );
    fwrite ( $handle, 'Passwort=' );
    fwrite ( $handle, $_POST['Passwort'] );  
    fwrite ( $handle, "\n" );
	fwrite ( $handle, 'TOKEN=' );
    fwrite ( $handle, $_POST['Token'] );  
    fwrite ( $handle, "\n" );
	fwrite ( $handle, 'use_oath=' );
	if( is_enabled($_POST['cred_selection']) ) {
		fwrite ( $handle, 'true' );
	} else {
		fwrite ( $handle, 'false' );
	}
	fwrite ( $handle, "\n" );
	fwrite ( $handle, 'listDelimiter=' );
	if( !isset($_POST['listDelimiter']) ) {
		$_POST['listDelimiter'] = '|';
	}
	fwrite ( $handle, $_POST['listDelimiter'] );
	fwrite ( $handle, "\n" );
	
	
fclose ( $handle );

// Delete cookie
unlink('/tmp/.alexa.cookie');

// Re-read amazon.cfg credentials
read_amazon_creds(); 

// Refresh devices
exec( LBPHTMLAUTHDIR . '/alexa_remote_control.sh -a' );

http_response_code(200);
header('Location: ' . $_SERVER['HTTP_REFERER']);
  
?>