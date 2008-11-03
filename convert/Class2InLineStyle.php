#!/usr/bin/php
<?php
/*class2style: converts class='class' to style='style:details;'
	given that class2style's first argument is a css file &the second is a an html file.
*/
	if(!(
		(isset($_SERVER['argv']))
		&&
		(isset($_SERVER['argv'][0]))
		&&
		(isset($_SERVER['argv'][1]))
		&&
		(is_readable($_SERVER['argv'][0]))
		&&
		(is_readable($_SERVER['argv'][1]))
	)) {
		print("usage: class2style");
		exit(-1);
	}

?>