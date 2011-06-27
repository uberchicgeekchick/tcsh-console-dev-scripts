#!/usr/bin/php
<?PHP
	$Directories=Array();
	exec( "sudo chown -R usGirls:usGirls /home/usGirls" );
	exec( "sudo find /home/usGirls -type d", $Directories );
	foreach( $Directories as $Directory ) {
		fprintf(STDOUT, "Fixing: %s\n", $Directory );
		exec( "sudo chmod ug+rwx "
			.(escapeshellarg($Directory))
		);
	}

?>
