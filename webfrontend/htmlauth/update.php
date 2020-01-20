<?php
echo hallo;
shell_exec("sh /opt/loxberry/webfrontend/cgi/plugins/alex2lox/update.sh");
echo hallo;
 header('Location: ./switch1.php'); 



exit;

?>