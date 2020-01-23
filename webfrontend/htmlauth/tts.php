<?php
require_once "loxberry_system.php";
require_once "lib/alexa_env.php";
require_once "lib/mqtt.php";

header('Content-Type: text/plain');

if( !isset($email) or !isset($password) ) {
	http_response_code(500);
	echo "Configfile amazon.txt not found, empty or invalid";
	exit(1);
}

// Get text
$text = $_GET['text'];

/* For some reason, sending umlauts from php is pronounced wrong as when the came
   commandline is executed from shell. Therefore, as workaround we require to replace
   umlauts.
*/

$toreplace = array( 'Ö', 'ö', 'Ü', 'ü', 'Ä', 'ä', 'ß', '°' );
$replacewith = array( 'Oe', 'oe', 'Ue', 'ue', 'Ae', 'ae', 'ss', ' Grad' );
$ttstext = str_replace( $toreplace, $replacewith, $text );

$command = array ( 
	LBPHTMLAUTHDIR."/alexa_remote_control.sh",
	'-d "' . $_GET['device'] . '"',
	'-e speak:"' . $ttstext . '"'
);
if ( isset($_GET['vol']) ) {
	echo "Setting volume to " . $_GET['vol'] . "\n";
	putenv("SPEAKVOL=".$_GET['vol']);
}

echo "Commandline call:\n";
echo join(' ', $command) . "\n";

passthru( join(' ', $command) );  

echo "TTS finished ... sending text to MQTT\n";
http_response_code(200);

/* Send text to MQTT */

// Get correct device name
$devicelist = json_decode( file_get_contents( TMP.'/.alexa.devicelist.json' ) );
if ( !isset($devicelist) or !isset($devicelist->devices) ) {
	echo "Could not read device list. Cannot send to MQTT";
	exit(1);
}

foreach( $devicelist->devices as $device ) {
	if(strtolower( str_replace( '_', ' ', $device->accountName ) ) == strtolower( str_replace('_', ' ', $_GET['device'] ) ) ) {
		$realDeviceName = $device->accountName;
		break;
	}
}

if (!isset( $realDeviceName ) ) {
	echo "Could not find device in devicelist. Cannot send to MQTT";
	exit(1);
}

// Query MQTT Settings
$mqttcred = mqtt_connectiondetails();
$sendTopicText = TOPIC.'/'.$realDeviceName.'/lastTTStext';
$sendTopicTime = TOPIC.'/'.$realDeviceName.'/lastTTSloxtime';
$sendValueText = json_encode( array( 'topic' => $sendTopicText, 'value' => $text, 'retain' => 0 ) );
$sendValueTime = json_encode( array( 'topic' => $sendTopicTime, 'value' => epoch2lox(), 'retain' => 0 ) );

$sock = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
socket_sendto ( $sock , $sendValueText , strlen($sendValueText) , 0 , 'localhost' , $mqttcred['udpinport'] );
socket_sendto ( $sock , $sendValueTime , strlen($sendValueTime) , 0 , 'localhost' , $mqttcred['udpinport'] );
socket_close( $sock );

