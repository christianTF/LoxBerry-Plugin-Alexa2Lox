<?php
require_once "loxberry_system.php";

define("ARCPATH", LBPHTMLAUTHDIR.'/alexa_remote_control.sh');
$email = null;
$password = null;
$token = null;
$use_oauth = null;

read_amazon_creds();


function read_amazon_creds() 
{

	global $email, $password, $token, $use_oauth;
	 
	// Set alexa_remote_control environments

	$creds = file(LBPHTMLAUTHDIR."/amazon.txt", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
	if( !isset($creds) ) {
		http_response_code(500);
		echo "Configfile amazon.txt not found or empty";
	} else {

		// Parse file
		foreach( $creds as $line ) {
			list($param, $value) = explode( '=', $line, 2);
			if(strtolower($param) == 'email') {
				$email = $value;
				continue; 
			}
			elseif (strtolower($param) == 'passwort' ) {
				$password = $value;
				continue;
			}
			elseif (strtolower($param) == 'token' ) {
				$token = $value;
				continue;
			}
			elseif (strtolower($param) == 'use_oauth' ) {
				$use_oauth = is_enabled($value) ? true : false;
				continue;
			}
		}

		putenv("TMP=/tmp");
		putenv("EMAIL=$email");
		putenv("PASSWORD=$password");
		putenv("LANGUAGE='de,en-US;q=0.7,en;q=0.3'");
		// Token auth missing
	}
}