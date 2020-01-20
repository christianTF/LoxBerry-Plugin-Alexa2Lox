<?php
require_once "loxberry_system.php";

header('Content-Type: text/plain');

$creds = file(LBPHTMLAUTHDIR."/amazon.txt", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
if( !isset($creds) ) {
	http_response_code(500);
	echo "Configfile amazon.txt not found or empty";
	exit(1);
}

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
	}

putenv("TMP=/tmp");
putenv("EMAIL=$email");
putenv("PASSWORD=$password");
putenv("LANGUAGE='de,en-US;q=0.7,en;q=0.3'");

// Get text
$text = $_GET['text'];

/* For some reason, sending umlauts from php is pronounced wrong as when the came
   commandline is executed from shell. Therefore, as workaround we require to replace
   umlauts.
*/

$toreplace = array( 'Ö', 'ö', 'Ü', 'ü', 'Ä', 'ä', 'ß', '°' );
$replacewith = array( 'Oe', 'oe', 'Ue', 'ue', 'Ae', 'ae', 'ss', ' Grad' );
$text = str_replace( $toreplace, $replacewith, $text );

$command = array ( 
	LBPHTMLAUTHDIR."/alexa_remote_control.sh",
	'-d "' . $_GET['device'] . '"',
	'-e speak:"' . $text . '"'
);
if ( isset($_GET['vol']) ) {
	echo "Setting volume to " . $_GET['vol'] . "\n";
	putenv("SPEAKVOL=".$_GET['vol']);
}

echo "Commandline call:\n";
echo join(' ', $command) . "\n";

passthru( join(' ', $command) );  
