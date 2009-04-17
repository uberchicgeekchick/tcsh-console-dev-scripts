<?php
	
	$aggregators=array(
		"podnova", "odeo", "miro", "podcast_ready",
		'total'=>4
	);
	
	$subscribe=require_once("settings/exportFormats.php");
	if( (my_isset($subscribe)) )
		return $subscribe;

	unset($subscribe);

	switch($_GET['subscribe']) {
		case "odeo":
			return array(
				'uri'	=>	"http://odeo.com/listen/subscribe",
				'get'	=>	"feed",
				'count'	=>	false
			);
		
		case "miro":
			return array(
				'uri'   =>      "http://subscribe.getmiro.com/",
				'get'   =>      "url",
				'count' =>      true
			);
		
		case "podcast_ready":
			return array(
				'uri'	=>	"http://www.podcastready.com/oneclick_bookmark.php",
				'get'	=>	"url",
				'count'	=>	false
			);
		
		case "podnova": default:
			$_GET['subscribe'] = "podnova";
			return array(
				'uri'   =>      "http://www.podnova.com/add.srf",
				'get'   =>      "url",
				'count' =>      false
			);
	}

?>