<?php
require_once "loxberry_system.php";
require_once "lib/alexa_env.php";
require_once "lib/mqtt.php";

header('Content-Type: text/plain');

$sock = null;
$mqttcred = null;

if( !isset($email) or !isset($password) ) {
	http_response_code(500);
	echo "Configfile amazon.cfg not found, empty or invalid";
	exit(1);
}

//
// Text processing 
//

// Get text
if(isset($_GET['text'])) {
	$text = $_GET['text'];
} elseif (isset($_GET['t'])) {
	$text = $_GET['t'];
} else {
	echo "Missing text! Should I ask Alexa to sing a song?\n";
	echo "Try alexa.php?device=<yourdevice>&execute=singasong  ;-)\n";
	exit(1);
}

/* For some reason, sending umlauts from php is pronounced wrong as when the came
   commandline is executed from shell. Therefore, as workaround we require to replace
   umlauts.
*/

$toreplace = array( 'Ö', 'ö', 'Ü', 'ü', 'Ä', 'ä', 'ß', '°' );
$replacewith = array( 'Oe', 'oe', 'Ue', 'ue', 'Ae', 'ae', 'ss', ' Grad' );
$ttstext = str_replace( $toreplace, $replacewith, $text );

echo "Incoming Text: $text\n";
echo "Text for TTS : $ttstext\n";

//
// Volume processing
//

if ( isset($_GET['vol']) ) {
	echo "Setting volume to " . $_GET['vol'] . "\n";
	putenv("SPEAKVOL=".$_GET['vol']);
}


//
// Device processing
//

if( isset($_GET['devices']) ) {
	$devices = $_GET['devices'];
} elseif( isset($_GET['d']) ) {
	$devices = $_GET['d'];
}

if($devices == 'ALL') {
	$devices = array ( "ALL" );
} else {
	$devices = array_unique( array_filter ( explode( ',', strtolower( $devices ) ) ) );
}

echo "Devices: " . join(',', $devices) . "\n";

if( empty( $devices ) ) {
	http_response_code(500);
	echo "No device sent. Have you used the device=... parameter?\n";
	exit(1);
}

//
// Get Amazon devicelist from cache
//

if ( ! file_exists( TMP.'/.alexa.devicelist.json' ) ) {
	// First query Amazon to get our devices
	echo "Amazon devicelist not present yet, requesting from Amazon...\n";
	exec( LBPHTMLAUTHDIR."/alexa_remote_control.sh -a" );
}

// Get correct device name
echo "Reading cached devicelist\n"; 
$devicelist = json_decode( file_get_contents( TMP.'/.alexa.devicelist.json' ) );
if ( !isset($devicelist) or !isset($devicelist->devices) ) {
	http_response_code(500);
	echo "Could not read devicelist or devicelist is invalid. Sorry, cannot talk to you :-(\n";
	exit(1);
}

$realDeviceNames = array( );
$allowedDevices = array ("ECHO", "KNIGHT", "ROOK");

$deviceparamCount = count($devices);
echo "Number of device params: $deviceparamCount\n";

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
	if ( $devices[0] == 'ALL' ) {
		// Send for ALL - no name compare required
		alexaTTS($device->accountName, $ttstext);
		sendMQTT($device->accountName, $text);
		array_push($realDeviceNames, $device->accountName);
		continue;
	}

	// This searches non-casesensitive for the current devicename in the devices provided by the user
	$arrpos = array_search( strtolower($device->accountName), $devices );
	
	# echo "Current Alexa: ".$device->accountName.", Position in array: $arrpos\n";
	if( $arrpos !== false ) {
		echo "Current Alexa: $device->accountName\n";
		// HERE WE MAKE THE TTS CALL
		alexaTTS($device->accountName, $ttstext);
		sendMQTT($device->accountName, $text);
		array_push($realDeviceNames, $device->accountName);
		unset($devices[$arrpos]);
		$deviceparamCount--;
	}
	if( $deviceparamCount == 0 ) {
		// All devices found, we needn't to further iterate
		break;
	}
}

if ( empty ( $realDeviceNames ) ) {
	http_response_code(500);
	echo "Could not find any given device in devicelist. Sorry, better luck next time :-(\n";
	exit(1);
}

	http_response_code(200);
	// echo "Real device names: " . join( ', ', $realDeviceNames) . "\n";

if( $sock) {
	socket_close( $sock );
}
exit(0);



function alexaTTS ( $devicename, $text ) {
		
	$command = array ( 
		LBPHTMLAUTHDIR."/alexa_remote_control.sh",
		'-d "' . $devicename . '"',
		'-e speak:"' . $text . '"',
		'>/dev/null &'
	);

	echo "Commandline call: ";
	echo join(' ', $command) . "\n";
	exec(join(' ', $command));
	usleep(200000); // 200ms
}



function sendMQTT ( $realDeviceName, $text ) {

	global $mqttcred, $sock;

	// Query MQTT Settings
	if( ! function_exists("mqtt_connectiondetails" ) ) {
		echo "sendMQTT: Your LoxBerry versions seems to be to old to send MQTT data.\n"; 
		return;
	}
	if( !isset($mqttcred) ) {
		$mqttcred = mqtt_connectiondetails();
	}
	if( !isset($sock) ) {
		$sock = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
	}
	
	echo "Sending your text of $realDeviceName to MQTT Gateway\n";
	
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



