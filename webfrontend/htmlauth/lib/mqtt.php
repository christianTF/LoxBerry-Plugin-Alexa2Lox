<?php


// ##################################################################################
// # MQTT functions                                                                 #
// ##################################################################################

// Read MQTT connection details and credentials from MQTT plugin
function mqtt_connectiondetails() {

	# Check if MQTT Gateway plugin is installed
	$mqttplugindata = LBSystem::plugindata("mqttgateway");
	$pluginfolder = $mqttplugindata['PLUGINDB_FOLDER'];
	if(empty($pluginfolder)) {
		return;
	}

	// $mqttconf;
    // $mqttcred;
	
		# Read connection details
		$mqttconf = json_decode(file_get_contents(LBHOMEDIR . "/config/plugins/" . $pluginfolder . "/mqtt.json" ));
		$mqttcred = json_decode(file_get_contents(LBHOMEDIR . "/config/plugins/" . $pluginfolder . "/cred.json" ));

	if( $mqttconf === FALSE || $mqttcred === FALSE ) {
		error_log("loxberry_io connectiondetails: Failed to read/parse connection details");
		return;
	}
	
	$cred = array ();
	
	@list($brokerhost, $brokerport) = explode(':', $mqttconf->{'Main'}->{'brokeraddress'}, 2);
	$brokerport = $brokerport ? $brokerport : 1883;
	$cred['brokeraddress'] = $brokerhost.":".$brokerport;
	$cred['brokerhost'] = $brokerhost;
	$cred['brokerport'] = $brokerport;
	$cred['brokeruser'] = $mqttcred->Credentials->brokeruser;
	$cred['brokerpass'] = $mqttcred->Credentials->brokerpass;
	$cred['udpinport'] = $mqttconf->Main->udpinport;
	return $cred;

}

