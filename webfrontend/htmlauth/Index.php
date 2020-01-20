<div style="text-align: center;">
<?php
require_once "loxberry_system.php";
include ("switch_2.php"); 

//B&B Technik OG
//Peter Bazala
//02/2017
echo("<br />\n");
echo("<br />\n");
echo("B&B Technik OG:    Alexa <-> Lox 3.0<br />\n");

echo("-------------------------------------------------------------------------------------------------------------------------------------<br />\n"); 

$Pfad=getcwd();


			
?>
<style type="text/css">

test [id=test] {
    padding:15px 15px; 
    background:#ccc; 
    -webkit-border-radius: 5px;
    border-radius: 5px;
	width:6px;
	height:20px; 
}

td {
        
       
	
	height:30px;
	color:#FFFFFFF;
      }

</style>



</form>



<table>
<table align=center>
<tr><td><font color='#008000'><span style="font-size:15pt">Update alexa_remote_control.sh von www.Loetzimmer.de</td></tr>

<tr><td width="400">

<form action="update.php">
    <input type="submit" value="Do It">
</form>
</td></tr>

</table>


<?php
echo("<br />\n");



		

$Pfad=getcwd();
echo("<br />\n");






?>

<table>
<table align=center>
<tr><td <align=center> <width="500"><p><font color='#008000'><span style="font-size:18pt">Amazon Zugangsdaten eingeben<br></td></tr>

</table>
</table>






<form action="DatenWrite.php" method="post">
<table>
<table align=center>
<tr><td width="400"><p>E-Mailadresse:<br></td></tr>
<tr><td width="400"><input type="Text" name="EMAIL"></p></td></tr>

<tr><td><p>Passwort:<br></td></tr>
<tr><td><input type="Text" name="Passwort"></p></td></tr>


<table align=center>
<tr><td width="120"> <input type="submit" name="" value="Speichern u. Daten einlesen (kann ein paar Minuten dauern)"></td></tr>
</table>
</form>


<?php

echo("-------------------------------------------------------------------------------------------------------------------------------------<br />\n");

?>




<table>
<table align=center>


<tr><td>.</td></tr>
<tr><td width="300"><p><font color='#008000'><span style="font-size:20pt">Daten Vom Miniserver<br></td></tr>
<tr><td>.</td></tr>
<tr><td>.</td></tr>
</table>
</form>
</table>

<form action="LoxWrite.php" method="post">
<table>
<table align=center>

<?php
$_home=LBPHTMLAUTHDIR;
$file=LBPHTMLAUTHDIR."/alexa.devicelist.json";
$msdaten= file_get_contents(LBSCONFIGDIR.'/general.cfg');				
$json = file_get_contents(LBPHTMLAUTHDIR.'/devices.conf');


$filename = LBPHTMLAUTHDIR.'/devices.conf'; 

     $_content = file( $filename ); 

     $menge=count($_content); 


echo "Es stehen $menge Amazon Geraete zur verfuegung, ";
echo("<br />\n");


echo("<br />\n");


$lines = file(LBPHTMLAUTHDIR.'/devices.conf');




$menge = $menge+1;
for($i=0; $i < $menge; $i++) {
${Wert.$i}=$lines[$i];


echo "<font color='#FF0000'> | </font>","<font color='#0a10c2'>",$lines[$i], "</font>"; 

}
echo("<br />\n");

echo("<br />\n");









?>






<tr><td>.</td></tr>
<tr><td width="400"><p>Bitte Name von Alexa Auswaehlen (es duerfen keine Umlaute/Sonderzeichen enthalten sein) <br></td></tr>

<tr><td>
<select name="AlexaNr">
	<option value = <?php echo $Wert0; ?>><?php echo $Wert0; ?></option>
	<option value = <?php echo $Wert1; ?>><?php echo $Wert1; ?></option>
	<option value = <?php echo $Wert2; ?>><?php echo $Wert2; ?></option>
	<option value = <?php echo $Wert3; ?>><?php echo $Wert3; ?></option>
	<option value = <?php echo $Wert4; ?>><?php echo $Wert4; ?></option>
	<option value = <?php echo $Wert5; ?>><?php echo $Wert5; ?></option>
	<option value = <?php echo $Wert6; ?>><?php echo $Wert6; ?></option>
	<option value = <?php echo $Wert7; ?>><?php echo $Wert7; ?></option>
	<option value = <?php echo $Wert8; ?>><?php echo $Wert8; ?></option>
	<option value = <?php echo $Wert9; ?>><?php echo $Wert9; ?></option>
 </select>


<tr><td><p>Lox IP xx.xx.xx.xx:xx<br></td></tr>
<tr><td><input type="Text" name="LOXIP"></p></td></tr>

<tr><td><p>Lox User<br></td></tr>
<tr><td><input type="Text" name="LOXUSER"></p></td></tr>

<tr><td><p>Lox Passwort<br></td></tr>
<tr><td><input type="Text" name="LOXPASS"></p></td></tr>

<tr><td><p>UDP Port (volume,Status,Shuffle,..) <br></td></tr>
<tr><td><input type="Text" name="UDPPORT"></p></td></tr>

<tr><td><p>HTTP Port (ohne Angabe wird automatisch 80 vorgegeben) <br></td></tr>
<tr><td><input type="Text" name="HTTPPORT"></p></td></tr>

<tr><td><p>VTI f Titel ohne VTI<br></td></tr>
<tr><td><input type="Text" name="LOXTitel"></p></td></tr>

<tr><td><p>VTI f Interpret ohne VTI<br></td></tr>
<tr><td><input type="Text" name="LOXInterpret"></p></td></tr>

<tr><td><p>VTI f Album ohne VTI<br></td></tr>
<tr><td><input type="Text" name="LOXAlbum"</p></td></tr>

<tr><td width="100"><input type="submit" name="" value="speichern"></td></tr>
</table>
</form>




</table>

</form>
<?php include(LBSTEMPLATEDIR.'/de/footer.html'); ?>
