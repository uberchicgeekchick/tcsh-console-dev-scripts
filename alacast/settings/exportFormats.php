<?php

	$exportFormats=array(
		"OPML", "VLC", "flat list",
		'total'=>3
	);
	
	if(!((isset($_GET['format']))))
		$_GET['format']=$exportFormats[0];

	if($_GET['subscribe']!="export")
		return FALSE;

	for($i=0; $i<$exportFormats['total']; $i++)
		if(($_GET['format']==$exportFormats[$i]))
			return array(
				'uri'   =>      "./",
				'get'   =>      NULL,
				'count' =>      FALSE
			);

	$_GET['format']=$exportFormats[0];

	return array(
		'uri'   =>      "./",
		'get'   =>      NULL,
		'count' =>      FALSE
	);

?>