#!/usr/bin/php
<?php


require_once "loxberry_system.php";
require_once "$lbphtmlauthdir/lib/alexa_env.php";

define ("CURL", "curl");
define ("ALEXA", "alexa.amazon.de");
define ("AMAZON", "amazon.de");
define ("COOKIE", "/tmp/.alexa.cookie");


$cookies = extractCookies(file_get_contents(COOKIE));
foreach( $cookies as $cookie) {
	if ( $cookie['domain'] == '.'.AMAZON and $cookie['name'] == 'csrf' ) {
		$csrf = $cookie['value'];
		break;
	}
}
define ("CSRF", $csrf);



$DEVICESERIALNUMBER = "G090L91174120RHS";
$DEVICETYPE = "A3S5BH2HU6VAYF";

$output = alexa_call("https://layla.amazon.de/api/media/state?deviceSerialNumber=$DEVICESERIALNUMBER&deviceType=$DEVICETYPE");



var_dump($output);










function alexa_call($url)
{
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_COOKIEFILE, COOKIE);
	curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:1.0) bash-script/1.0');
	$headerArr = array (
		"DNT: 1",
		"Connection: keep-alive",
		"Content-Type: application/json; charset=UTF-8",
		"Referer: https://alexa.".AMAZON."/spa/index.html",
		"Origin: https://alexa.".AMAZON,
		"csrf: ".CSRF,
	);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headerArr);
	$output = curl_exec($ch);
	curl_close($ch);
	
	return json_decode($output);
	
}




/* Lötzimmer script call devlist */
/*
${CURL} ${OPTS} -s -b ${COOKIE} -A "${BROWSER}" -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.${AMAZON}/spa/index.html" -H "Origin: https://alexa.${AMAZON}"\
 -H "csrf: $(awk "\$0 ~/.${AMAZON}.*csrf[ \\s\\t]+/ {print \$7}" ${COOKIE})"\
 "https://${ALEXA}/api/devices-v2/device?cached=false" > ${DEVLIST}


${CURL} 
	${OPTS} 
	-s 
	-b ${COOKIE} 
	-A "${BROWSER}" 
	-L
	-H "DNT: 1" 
	-H "Connection: keep-alive" 
	-H "Content-Type: application/json; charset=UTF-8" 
	-H "Referer: https://alexa.${AMAZON}/spa/index.html" 
	-H "Origin: https://alexa.${AMAZON}"
	-H "csrf: $(awk "\$0 ~/.${AMAZON}.*csrf[ \\s\\t]+/ {print \$7}" ${COOKIE})" "https://${ALEXA}/api/devices-v2/device?cached=false" 
	> ${DEVLIST}






*/










/* 

Bash code von Peter



curl -s -b  ${COOKIE} -A "Mozilla/5.0" --compressed -H "DNT: 1" -H "Connection: keep-alive" -L\
 -H "Content-Type: application/json; charset=UTF-8" -H "Referer: https://alexa.amazon.de/spa/index.html" -H "Origin: https://alexa.amazon.de"\
 -H "csrf: $(awk '$0 ~/.amazon.de.*csrf[\s\t]/ {print $7}' ${COOKIE})"\
 "https://alexa.amazon.de/api/namedLists/" > $Ram/listid.txt
jq '.[]' /$Ram/listid.txt >  /$Ram/listid.json
cat /run/shm/alex2lox/listid.json | jq '.[].itemId' | /bin/sed 's/"//g'>/$Ram/ListIds.txt
read ShoppingListId  < /run/shm/alex2lox/ListIds.txt
echo ShoppingListId  $ShoppingListId 


*/

/**
 * Extract any cookies found from the cookie file. This function expects to get
 * a string containing the contents of the cookie file which it will then
 * attempt to extract and return any cookies found within.
 *
 * @param string $string The contents of the cookie file.
 * 
 * @return array The array of cookies as extracted from the string.
 *
 */
function extractCookies($string) {
    $cookies = array();
 
    $lines = explode("\n", $string);
 
    // iterate over lines
    foreach ($lines as $line) {
 
        // we only care for valid cookie def lines
        if (isset($line[0]) && substr_count($line, "\t") == 6) {
 
            // get tokens in an array
            $tokens = explode("\t", $line);
 
            // trim the tokens
            $tokens = array_map('trim', $tokens);
 
            $cookie = array();
 
            // Extract the data
            $cookie['domain'] = $tokens[0];
            $cookie['flag'] = $tokens[1];
            $cookie['path'] = $tokens[2];
            $cookie['secure'] = $tokens[3];
 
            // Convert date to a readable format
            echo "Tokens 4: $tokens[4]\n";
			$cookie['expiration'] = date('Y-m-d h:i:s', intval($tokens[4]));
			
            $cookie['name'] = $tokens[5];
            $cookie['value'] = $tokens[6];
 
            // Record the cookie.
            $cookies[] = $cookie;
        }
    }
 
    return $cookies;
}
