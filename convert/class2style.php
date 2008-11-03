#!/usr/bin/php
<?php
#class2style:
#converts class='class' to style='style:details;' given the first file being a css file &the second being an xhtml file.

if(!((isset($argv))&&(isset($argv[0]))&&(isset($argv[1])))) {
	print("usage:");
	exit(1);
}

?>