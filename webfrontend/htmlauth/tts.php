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
$realDeviceNames = array( );
$allowedDevices = array ("ECHO", "KNIGHT", "ROOK", "WHA");

foreach( $devicelist->devices as $device ) {
	// Skip devices not online
	if( $device->online != true ) {
		continue;
	}
	// Skip devices not in allowed list of deviceTypes
	if( !in_array( $device->deviceFamily, $allowedDevices ) ) {
		continue;
	}
	// Handle device ALL
	if ( $_GET['device'] == 'ALL' ) {
		// Put all devices to an array - no name compare required
		array_push($realDeviceNames, $device->accountName);
		continue;
	}
	// In all other cases, search for the real device name
	if(strtolower( str_replace( '_', ' ', $device->accountName ) ) == strtolower( str_replace('_', ' ', $_GET['device'] ) ) ) {
		array_push($realDeviceNames, $device->accountName);
		break;
	}
}

if ( !isset( $realDeviceNames ) ) {
	echo "Could not find device in devicelist. Cannot send to MQTT";
	exit(1);
}

// Query MQTT Settings
$mqttcred = mqtt_connectiondetails();
$sock = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);

// Loop through all TTS devices
foreach( $realDeviceNames as $realDeviceName ) {
	$sendTopicText = TOPIC.'/'.$realDeviceName.'/lastTTStext';
	$sendValueText = json_encode( array( 'topic' => $sendTopicText, 'value' => utf8_encode($text), 'retain' => 0 ) );
	socket_sendto ( $sock , $sendValueText , strlen($sendValueText) , 0 , 'localhost' , $mqttcred['udpinport'] );
	
	$sendTopicLoxtime = TOPIC.'/'.$realDeviceName.'/lastTTSloxtime';
	$sendValueLoxtime = json_encode( array( 'topic' => $sendTopicLoxtime, 'value' => epoch2lox(), 'retain' => 0 ) );
	socket_sendto ( $sock , $sendValueLoxtime , strlen($sendValueLoxtime) , 0 , 'localhost' , $mqttcred['udpinport'] );
	
	$sendTopicTime = TOPIC.'/'.$realDeviceName.'/lastTTStime';
	$sendValueTime = json_encode( array( 'topic' => $sendTopicTime, 'value' => currtime('hr'), 'retain' => 0 ) );
	socket_sendto ( $sock , $sendValueTime , strlen($sendValueTime) , 0 , 'localhost' , $mqttcred['udpinport'] );
}
socket_close( $sock );
