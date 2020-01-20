<?php
require_once "loxberry_system.php";

$_home=LBPHTMLAUTHDIR;
$_data=LBPDATADIR;

//B&B Technik OG
//Peter Bazala
//02/2017

 echo("<br />\n");
 echo("<br />\n");

echo("B&B Technik OG:<br />\n");
echo("<br />\n");
echo("Daten werden aufbereitet, bitte um etwas Geduld<br />\n");
echo("<br />\n");
 echo("<br />\n");

$Ram="/run/shm/alex2lox";


echo exec("sh /$_home/start.sh -i"); 
echo exec("sh /$_home/start.sh -p");
echo exec("sh /$_home/start.sh -S");
echo exec("sh /$_home/start.sh -P");
echo exec("sh /$_home/daten.sh");   

?>
Bluethooth Daten:<br />

<textarea rows="50" cols="100"><?php
 $filename = "$Ram/bt.txt";
 $file = fopen($filename, "rb");
 echo fread($file, filesize($filename));
 fclose($file);
?></textarea>
</select>
<hr />	

Liste der bei Amazon gekauften Tracks:<br />

<textarea rows="100" cols="300"><?php
 $filename1 = "$Ram/PURCHASES";
 $file = fopen($filename1, "rb");
 echo fread($file, filesize($filename1));
 fclose($file);
?></textarea>
</select>
<hr />	

Liste aller Amazon Stationen:<br />

<textarea rows="100" cols="300"><?php
 $filename2 = "$Ram/prime-sections";
 $file = fopen($filename2, "rb");
 echo fread($file, filesize($filename2));
 fclose($file);
?></textarea>
</select>
<hr />	

Liste der zu Amazon hochgeladenen Tracks:<br />

<textarea rows="100" cols="300"><?php
 $filename3 = "$Ram/IMPORTED";
 $file = fopen($filename3, "rb");
 echo fread($file, filesize($filename3));
 fclose($file);
?></textarea>
</select>
<hr />	

Liste aller Amazon Playlists:<br />

<textarea rows="100" cols="300"><?php
 $filename4 = "$Ram/PLAYLIST";
 $file = fopen($filename4, "rb");
 echo fread($file, filesize($filename4));
 fclose($file);
?></textarea>
</select>
<hr />	