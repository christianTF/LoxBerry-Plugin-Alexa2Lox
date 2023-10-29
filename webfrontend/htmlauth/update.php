<?php
require_once "loxberry_system.php";
exec("$lbphtmlauthdir/update.sh", $output, $exitcode);
if( $exitcode != 0 ) {
	http_response_code(500);
	exit;
}	
	
$alexa_remote_version = exec( LBPHTMLAUTHDIR . '/alexa_remote_control.sh --version' );
header("Content-Type: application/json");
if(isset($alexa_remote_version) ) {
	http_response_code(200);
	echo json_encode( array( "version" => $alexa_remote_version, "output" => $output ) );
} else {
	http_response_code(500);
}
exit;

?>
