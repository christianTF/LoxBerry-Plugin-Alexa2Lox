<?php
header('Content-Type: text/plain');

require_once "loxberry_system.php";
require_once "./lib/alexa_env.php";

//B&B Technik OG
//Peter Bazala
//02/2017

echo("B&B Technik OG\n");

$params = $_GET;

if( isset($_GET['original']) ) {
	$use_original=true;
	$commandline = "--original ";
} else {
	$use_original=false;
}

foreach( $params as $param => $value ) {
	if($param == "original") {
		continue;
	}
	echo "$param";
	if($use_original) {
		$commandline .= "$param ";
	} else {
		$commandline .= "--$param ";
	}
	if(!empty($value)) {
		echo " --> $value";
		$commandline .= "\"$value\" ";
	}
	echo "\n";
}

$commandline = LBPHTMLAUTHDIR."/start.sh $commandline";
echo "\nCalling $commandline ...\n\n";
passthru($commandline); 

?>