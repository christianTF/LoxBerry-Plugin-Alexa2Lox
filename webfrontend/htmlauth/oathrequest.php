<?php
require_once "loxberry_system.php";

$response = array();

header('Content-Type: application/json');

if( $_POST['Token'] == "" ) {
	$response['error'] = 2;
	$response['errormsg'] = 'Der Amazon Token muss vorher eingegeben werden!';
	http_response_code(500);
}
else {

	exec( 'oathtool -b --totp "' . $_POST['Token'] . '"', $output, $exitcode);

	$response['error'] = $exitcode;
	if( $exitcode != 0 ) {
		http_response_code(500);
		$response['errormsg'] = $output[0];
	} else {
		http_response_code(200);
		$response['key'] = $output[0];
	}
}

echo json_encode($response);
