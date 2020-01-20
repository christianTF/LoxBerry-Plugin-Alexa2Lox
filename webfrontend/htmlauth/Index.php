<?php
require_once "loxberry_system.php";
require_once "loxberry_web.php";

// Local MQTT lib to provide LB1.x compatibility
require_once "lib/mqtt.php";

define('TMP', '/tmp');


// Print LoxBerry header
$template_title = "ALEXA <--> LOX " . LBSystem::pluginversion();
$helplink = "https://www.loxwiki.eu/x/FAHqAw";
$helptemplate = "help.html";
LBWeb::lbheader($template_title, $helplink, $helptemplate);

// Read credentials from amazon.txt credentials file
$creds = file(LBPHTMLAUTHDIR."/amazon.txt", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
if( isset($creds) ) {
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
}

// Query alexa_remote_control.sh version
$alexa_remote_version = exec( LBPHTMLAUTHDIR . '/alexa_remote_control.sh --version' );
if( empty($alexa_remote_version) ) {
	$alexa_remote_version = '<span style="color:red">Keine Versionsnummer angegeben (evt. zu alte Script-Version)</span>';
} else {
	$alexa_remote_version = '<span style="color:green">'.$alexa_remote_version.'</span>';
}

// Read found devices from json
$devicefile = TMP.'/.alexa.devicelist.json';
if( file_exists( $devicefile ) ) {
	$devicelist = json_decode( file_get_contents( $devicefile) );
}

// Query MQTT Settings
$mqttcred = mqtt_connectiondetails();


?>
<style>
.mono {
	font-family: monospace;
	font-weight: bold;
	font-size: 135%;
}

</style>



<div class="wide">Amazon Alexa</div>
<p>
	Du kannst hier die Amazon Alexa Webseite öffnen, und Alexanders <a href="https://blog.loetzimmer.de/2017/10/amazon-alexa-hort-auf-die-shell-echo.html" target="_blank">"Lötzimmer" Alexa-Script</a> aktualisieren.<br>
	Aktuelle Version von <span class="mono">alexa_remote_control.sh</span>: <b><?=$alexa_remote_version?></b>
</p>

<div class="ui-grid-a">
	<div class="ui-block-a">
		<button id="OpenAlexaWeb" class="ui-btn">Alexa Webinterface öffnen</button>
	</div>
	<div class="ui-block-b">
		<button id="UpdateAlexaRemoteControl" class="ui-btn">Alexa Remote Control aktualisieren</button>
	</div>
</div>
<br>

<div class="wide">Amazon Zugangsdaten</div>
<p>Zur Abfrage und Steuerung von Alexa gibt es zwei Authentifizierungsmethoden: Entweder Amazon Username+Passwort, oder OAUTH Authentifizierung. 
Bei Benutzer+Passwort besteht die Gefahr, dass Amazon regelmäßig sogenannte Captcha's anfordert, wodurch keine Automatisierung mehr möglich ist. 
Bei OAUTH-Authentifizierung musst du einen OAUTH-Token über die Webseite von Amazon erstellen. Dieser wird dann für die Authentifizierung verwendet und dürfte viel länger funktionieren.
</p>
<div class="ui-grid-a">
	<div class="ui-block-a">
		<label for="cred_oauth">OAuth-Authentifizierung</label>
		<input type="radio" name="cred_selection" id="cred_oauth" class="custom">
	</div>
	<div class="ui-block-b">
		<label for="cred_userpass">Benutzer+Passwort</label>
		<input type="radio" name="cred_selection" id="cred_userpass" class="custom">
	</div>
</div>

<!-- User/Pass credentials -->
<div id="credblock_userpass">
	<div class="ui-field-contain">
		<label for="amazon_email">Amazon E-Mail-Adresse:</label>
		<input id="amazon_email" type="text" name="EMAIL" value="<?=$email?>">
	</div>
	<div class="ui-field-contain">
		<label for="amazon_pass">Amazon Passwort:</label>
		<input id="amazon_pass" type="password" name="Passwort" value="<?=$password?>">
	</div>
</div>

<!-- OAuth credentials -->
<div id="credblock_oauth">
	<div class="ui-field-contain">
		<label for="amazon_token">Amazon Token:</label>
		<input id="amazon_token" type="text" name="Token" value="<?=$token?>">
	</div>
</div>

<!-- Found devices -->
<div class="wide">Gefundene Geräte</div>

<?php

	if( isset($devicelist) ) {
		echo '<!-- Devices Flexbox container -->'."\n";
		echo '<div style="display:flex;flex-wrap:wrap;">'."\n";

		foreach( $devicelist->devices as $device ) {
			echo '<div style="padding:20px;margin:15px;border-style:solid;border-width:1px;">'."\n";
			echo "<b>". $device->accountName . "</b><br>\n";
			if( $device->online == true ) {
				echo '<span style="color:green;">Online</span>'."<br>\n";
			} else {
				echo '<span style="color:red;">Offline</span>'."<br>\n";
			}
			echo '<span style="font-size:80%">';
			echo "Typ " . $device->deviceFamily . "<br>\n";
			echo "Firmware " . $device->softwareVersion . "<br>\n";
			echo '</span>'."\n";
			echo '</div>'."\n";
		}
		
		echo '</div>'."\n";
		echo '<!-- Devices Flexbox End -->'."\n";
	
	} else {
		echo '<p>Keine Echo-Geräte gefunden.</p>';
	}
	
	
?>	


<!-- MQTT -->
<div class="wide">MQTT</div>
<p>Alle Daten werden per MQTT übertragen. Die Subscription dafür lautet <span class="mono">alexa2lox/#</span> und wird im MQTT Gateway Plugin automatisch eingetragen.</p>

<?php

	if ( !isset($mqttcred) ) {

?>
		<p style="color:red"><b>MQTT Gateway nicht installiert!</b></p>
		
<?php

	} else {
		
?>

		<p style="color:green"><b>MQTT Gateway gefunden und wird verwendet.</b></p>
		
<?php

	}
	
?>

<!-- JavaScript code -->
<script>
$(function() {
	// Radio button Auth setzen
	$("#cred_oauth").attr("checked", <?=$use_oauth?>);
	$("#cred_userpass").attr("checked", <?=!$use_oauth?>);
	$("input[type='radio']").checkboxradio("refresh");

	

});


</script>

<?php
	
	// Print LoxBerry footer 


	LBWeb::lbfooter();
	
?>