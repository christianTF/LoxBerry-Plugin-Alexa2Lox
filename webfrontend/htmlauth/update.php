<?php
require_once "loxberry_system.php";

echo hallo;
shell_exec("sh $lbphtmlauthdir/update.sh");
echo hallo;
 header('Location: ./switch1.php'); 



exit;

?>