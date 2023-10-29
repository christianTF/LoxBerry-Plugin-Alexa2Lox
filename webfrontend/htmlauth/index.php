<?php
error_log("index.php --------------------------------------------------------------");
require_once "loxberry_system.php";
require_once "loxberry_web.php";
require_once "loxberry_io.php";
require_once "lib/alexa_env.php";

// Print LoxBerry header
$template_title = "ALEXA <--> LOX " . LBSystem::pluginversion();
$helplink = "https://wiki.loxberry.de/plugins/alexa2lox/";
$helptemplate = "help.html";
LBWeb::lbheader($template_title, $helplink, $helptemplate);

// Query alexa_remote_control.sh version
$alexa_remote_version = exec( LBPHTMLAUTHDIR . '/alexa_remote_control.sh --version' );
if( empty($alexa_remote_version) ) {
	$alexa_remote_version = '<span class="red">Keine Versionsnummer angegeben (evt. zu alte Script-Version)</span>';
} else {
	$alexa_remote_version = '<span class="green">'.$alexa_remote_version.'</span>';
}

// Refresh devices and read found devices from json
$output = `$lbphtmlauthdir/alexa_remote_control.sh -a`;
error_log("alexa_remote_control.sh -a OUTPUT:");
error_log($output);
$devicefile = TMP.'/.alexa.devicelist.json';
if( file_exists( $devicefile ) ) {
	$devicelist = json_decode( file_get_contents( $devicefile) );
} else {
	error_log("devicelist does not exist");
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

.green {
	color: green;
	font-weight: bold;
}

.red {
	color: red;
	font-weight: bold;
}

.grey {
	color: #888888;
}

</style>

<div class="wide">Amazon Alexa</div>
<p>
	Du kannst hier Alexanders <a href="https://blog.loetzimmer.de/2021/09/alexa-remote-control-shell-script.html" target="_blank">"Lötzimmer" Alexa-Script</a> aktualisieren. Auf diesem Skript basiert das Plugin.<br>
	Aktuell installierte Version von <span class="mono">alexa_remote_control.sh</span>: <b><span id="arc_version"><?=$alexa_remote_version?></span></b>
</p>

<div class="ui-grid-a">
	<div class="ui-block-a">
		<button id="UpdateAlexaRemoteControl" class="ui-btn">Alexa Remote Control ("Lötzimmer"-Skript) aktualisieren</button>
	</div>
</div>
<br>

<div class="wide">Amazon Token</div>
<p>Die in früheren Pluginversionen verwendeten Authentifizierungsmöglichkeiten (Benutzer+Passwort und 2-Faktor-Authentifizierung) funktionieren nicht mehr. Um das Plugin nutzen
zu können, musst Du einen Token generieren und hier hinterlegen. Mit diesem Token kann sich das Plugin gegenüber Amazon identifizieren und auf die Alexa-API zugreifen.<br><br>
Eine Anleitung zur Erzeugung des Token <a href="https://wiki.loxberry.de/plugins/alexa2lox/alexa2lox_refresh_token_erzeugen" target="_blank">findest Du in unserem Wiki</a>.<br>
</p>
<form id="credentials_form" action="DatenWrite.php" method="post">

	<!-- OAuth credentials -->
	<div id="credblock">
		<div class="ui-field-contain">
			<label for="Refresh_Token">Amazon Refresh Token:</label>
			<textarea id="Refresh_Token" name="Refresh_Token" rows="2"><?=$refresh_token?></textarea>
		</div>
	</div>
	
	<div class="ui-field-contain">
		<label for="listDelimiter">Listen-Trennzeichen:</label>
		<input id="listDelimiter" type="text" name="listDelimiter" value="<?=$listDelimiter?>">
	</div>
		
	
	
	
	<!-- Submit button -->
    <input type="submit" data-icon="check" value="Speichern">

</form>

<!-- Found devices -->
<div class="wide">Gefundene Geräte</div>

<p><a href="/admin/system/tools/logfile.cgi?logfile=system_tmpfs/apache2/php.log&header=html&format=template" target="_blank">Logfile für die Fehlersuche</a></p>

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

	// alexa_remote_control aktualisieren Knopf
	$("#UpdateAlexaRemoteControl").click( function() {
		$("#UpdateAlexaRemoteControl").attr('disabled', 'disabled');
		$("#arc_version").empty();
		$.ajax( 'update.php' )
			.done(function( updateResp ) {
				console.log("New alexa_remote_control version", updateResp.version);
				$("#arc_version").html(updateResp.version).addClass("green");
			})
			.fail(function() {
				console.log("Update alexa_remote_control failed");
				$("#arc_version").html("Update hat nicht funktioniert :-(").addClass("red");
			})
			.always(function() {
				$("#UpdateAlexaRemoteControl").attr('disabled', null);
			});
	});

});


</script>

<?php

// Print LoxBerry footer 
LBWeb::lbfooter();

?>
