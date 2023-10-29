<?php
// $locale='de_DE.UTF-8';
// setlocale(LC_ALL,$locale);
// putenv('LC_ALL='.$locale);
// error_log ( exec('locale charmap') );

require_once "loxberry_system.php";

define("ARCPATH", LBPHTMLAUTHDIR.'/alexa_remote_control.sh');
define('TMP', '/tmp');
define('TOPIC', 'alexa2lox');

$email = null;
$password = null;
$token = null;
$refresh_token = null;
$use_oath = null;
$listDelimiter = null; 
read_amazon_creds();


function read_amazon_creds() 
{

	global $email, $password, $token, $use_oath, $listDelimiter, $refresh_token;
	 
	// Set alexa_remote_control environments

	$creds = file(LBPCONFIGDIR."/amazon.cfg", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
	if( !isset($creds) ) {
		echo "Configfile amazon.cfg not found or empty";
	} else {

		// Parse file
		foreach( $creds as $line ) {
			list($param, $value) = explode( '=', $line, 2);
			if(strtolower($param) == 'email') {
				$email = $value;
				error_log("Email: $email");
				continue; 
			}
			elseif (strtolower($param) == 'passwort' ) {
				$password = $value;
				continue;
			}
			elseif (strtolower($param) == 'token' ) {
				$token = $value;
				error_log("Token: $token");
				continue;
			}
			elseif (strtolower($param) == 'refresh_token' ) {
				$refresh_token = $value;
				error_log("Refresh Token: $refresh_token");
				continue;
			}
			elseif (strtolower($param) == 'use_oath' ) {
				$use_oath = is_enabled($value) ? true : false;
				error_log("use_oath: $use_oath");
				continue;
			}
			elseif (strtolower($param) == 'listdelimiter' ) {
				$listDelimiter = $value;
				error_log("listDelimiter: $listDelimiter");
				continue;
			}
		}

		putenv("ALEXA2LOXENV=php");
		putenv("TMP=/tmp");
		putenv("EMAIL=$email");
		putenv("PASSWORD=$password");
		putenv("LANGUAGE='de,en-US;q=0.7,en;q=0.3'");
		putenv('REFRESH_TOKEN=' . $refresh_token . '');
		if( $use_oath ) {
			putenv('OATHTOOL=/usr/bin/oathtool');
			putenv('MFA_SECRET=' . $token . '');
		} else {
			putenv('MFA_SECRET=');
		}
		putenv("ALEXA2LOX_listDelimiter=$listDelimiter");
		
	}
}
