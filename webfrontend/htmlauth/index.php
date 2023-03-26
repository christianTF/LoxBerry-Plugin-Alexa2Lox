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
	Du kannst hier die Amazon Alexa Webseite öffnen, und Alexanders <a href="https://blog.loetzimmer.de/2017/10/amazon-alexa-hort-auf-die-shell-echo.html" target="_blank">"Lötzimmer" Alexa-Script</a> aktualisieren.<br>
	Aktuelle Version von <span class="mono">alexa_remote_control.sh</span>: <b><span id="arc_version"><?=$alexa_remote_version?></span></b>
</p>

<div class="ui-grid-a">
	<div class="ui-block-a">
		<a href="https://alexa.amazon.de" target="_blank" id="OpenAlexaWeb" class="ui-btn">Alexa Webinterface öffnen</a>
	</div>
	<div class="ui-block-b">
		<button id="UpdateAlexaRemoteControl" class="ui-btn">Alexa Remote Control aktualisieren</button>
	</div>
</div>
<br>

<div class="wide">Amazon Zugangsdaten</div>
<p>Zur Abfrage und Steuerung von Alexa wird ein Token benötigt. Dieses kannst du mit dem <a href="https://github.com/adn77/alexa-cookie-cli" target="_blank"><span class="mono">alexa-cookie-cli</span></a> von Alexander erstellen.
Der Token wird dann für die Authentifizierung verwendet und funktioniert (nach aktueller Erkenntnis) ohne weitere, manuelle Eingriffe.
</p>
<form id="credentials_form" action="DatenWrite.php" method="post">
	
	<!-- OAuth credentials -->
	<div id="credblock_oath">
		<div class="ui-field-contain">

<?php

if (!isset($devicelist)) {

?>

			<label for="amazon_token">Amazon Refresh Token:</label>
			<input id="amazon_token" type="text" name="Token" value="<?=$token?>">
			<!-- <textarea id="amazon_token" name="Token"><?=$token?></textarea> -->

<?php

} else {

?>

			<label for="amazon_token">Amazon Refresh Token:</label><div style="color:green;margin:.5em 2% 0 0"><b>Du bist angemeldet.</b></div>
			<input id="amazon_token" type="hidden" name="Token" value="<?=$token?>">

<?php

}

?>	
			
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
	$("#cred_oath").attr("checked", <?=$use_oath?>);
	$("#cred_userpass").attr("checked", <?=!$use_oath?>);
	$("input[type='radio']").checkboxradio("refresh");


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

	// oathtool Schlüssel abrufen und anzeigen
	$("#oathtoolkey").click( function () {
		$("#oathtoolkey").attr('disabled', 'disabled');
		$("#oathresponse").html('Schlüssel wird abgefragt...');
		$("#oathresponse").removeClass("red").addClass("grey");
		
		$.post( 'oathrequest.php', $("#credentials_form").serialize() )
			.done(function( oathResp ) {
				console.log("oathrequest.php response", oathResp );
				$("#oathresponse").removeClass("grey");
				$("#oathresponse").html('Einmal-Schlüssel bei Amazon eingeben: <span class="green" style="font-size:130%">'+oathResp.key+'</span><br><b>Speichern nicht vergessen!');
				
			})
			.fail(function( oathResp ) {
				console.log("oathrequest.php failed", oathResp);
				$("#oathresponse").html("Abfrage ist fehlgeschlagen");
				if( typeof oathResp.responseJSON.errormsg != 'undefined' ) {
					$("#oathresponse").append(": "+oathResp.responseJSON.errormsg);
				}
				$("#oathresponse").removeClass("grey").addClass("red");
			})
			.always(function() {
				$("#oathtoolkey").attr('disabled', null);
		});
	});	
	
	
	// Hilfe öffnen und schließen bei Klick
	$(".openhelp").click( function() {
		$("#infopanel").panel("toggle");
	});

});


</script>

<?php
	
	// Print LoxBerry footer 


	LBWeb::lbfooter();
	
?>