#!/usr/bin/php
<?php
	/*
	 * (c) 2007-Present Kathryn G. Bohmont <uberChicGeekChick.Com -at- uberChicGeekChick.Com>
	 * 	http://uberChicGeekChick.Com/
	 * Writen by an uberChick, other uberChicks please meet me & others @:
	 * 	http://uberChicks.Net/
	 *I'm also disabled; living with Generalized Dystonia.
	 * Specifically: DYT1+/Early-Onset Generalized Dystonia.
	 * 	http://Dystonia-DREAMS.Org/
	 */

	/*
	 * Unless explicitly acquired and licensed from Licensor under another
	 * license, the contents of this file are subject to the Reciprocal Public
	 * License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
	 * and You may not copy or use this file in either source code or executable
	 * form, except in compliance with the terms and conditions of the RPL.
	 *
	 * All software distributed under the RPL is provided strictly on an "AS
	 * IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
	 * LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
	 * LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	 * PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
	 * language governing rights and limitations under the RPL.
	 *
	 * ------------------------------------------------------------------
	 * |	The RPL 1.5 may be found with this project or online at:    |
	 * |		http://opensource.org/licenses/rpl1.5.txt	    |
	 * ------------------------------------------------------------------
	 */
	
	/*
	 * ALWAYS PROGRAM FOR ENJOYMENT &PLEASURE!!!
	 * Feel comfortable takeing baby steps.  Every moment is another step; step by step; there are only baby steps.
	 * Being verbose in comments, variables, functions, methods, &anything else IS GOOD!
	 * If I forget ANY OF THIS than READ:
	 * 	"Paul Graham's: Hackers &Painters"
	 * 	&& ||
	 * 	"The Mentor's Last Words: The Hackers Manifesto"
	 */
	ini_set( "display_errors", TRUE );
	ini_set( "error_reporting", E_ALL | E_STRICT );
	ini_set( "default_charset", "utf-8" );
	ini_set( "date.timezone", "America/Denver" );

	define( "ALACASTS_INCLUDE_PATH", (preg_replace( "/(.*)\/[^\/]+/", "$1", ( (dirname($_SERVER['argv'][0])!=".") ? (dirname( $_SERVER['argv'][0] )) : $_SERVER['PWD'] ) )) );

	require_once(ALACASTS_INCLUDE_PATH."/classes/alacast.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/titles.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/logger.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/helper.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/playlist.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/playlists/m3u.class.php");
	require_once(ALACASTS_INCLUDE_PATH."/classes/podcatcher/program.class.php");

	//here's where alacast actually starts.
	if( (in_array("--help", $_SERVER['argv']) ))
		help();//displays usage and exits alacast
	
	function help() {
		print( "Usage: alacast.php [options]..."
			."\n\tOptions:"
			."\n"
			."\n"
			."\nUpdate options (i.e., gpodder --run):"
			."\n----------------------------------------------"
			."\n\t--use-gpodder=gpodder_exec"
			."\n\t						Runs gpodder_exec instead of using /usr/bin/gpodder or gpodder"
			."\n\t						that's found in your path."
			."\n"
			."\n\t--update				runs `gpodder --run` automatically before moving podcasts."
			."\n"
			."\n\t--nice[=priority]			Runs gPodder with the specified priority (default: +19)."
			."\n"
			."\n\t--update=detailed			Displays the output from: `gpodder --run`."
			."\n\t						This is usually the URIs of your subscribed podcasts"
			."\n\t						and any new epidodes."
			."\n"
			."\n\t--interactive			Prompts before quiting/continuing."
			."\n"
			."\n"
			."\nOutput options:"
			."\n--------------------"
			."\n\t--quiet"
			."\n\t				This keeps any output from being output to the terminal."
			."\n\t				This is useful when ran as a cron job."
			."\n\t--verbose"
			."\n\t				These effect how much information is displayed about what"
			."\n\t				I'm doing.  These are mostly messages useful for debugging."
			."\n"
			."\n\t--logging"
			."\n\t				This writes all regular, &`--update output to this script's log file."
			."\n"
			."\n"
			."\nSymlink options:"
			."\n-------------------------"
			."\n\t--leave-trails		Leave [GUID].trail symlinks to gPodder's GUID folder."
			."\n"
			."\n\t--clean-trails		This just removes any symlinks that may have been created by"
			."\n\t				previously using the`--leave-trails` option."
			."\n"
			."\n"
			."\nSyncing options:"
			."\n-------------------"
			."\n\t--keep-original		keeps gPodders GUID based named files while making copies of all"
			."\n\t					podcasts with easier to understand directories &filenames."
			."\n"
			."\n\t--player[ = vlc|xine]		different players have issues with different charaters"
			."\n\t				in the path's of podcast's files.  known issues are:"
			."\n\t				- vlc won't play files with colons(:) in their path."
			."\n\t				- xine won't play files with octothorps(#) in their path."
			."\n\t				so adding this option strips these characters from podcasts'"
			."\n\t				sub-directory and file names."
			."\n\t				if --player is alone all characters that might cause problems"
			."\n\t				are removed.  if a value for player is set than just the"
			."\n\t				character(s) known to cause issues with that player will be"
			."\n\t				removed."
			."\n"
			."\n"
			."\nNaming/Title options:"
			."\n----------------------"
			."\n\t--titles-prefix-podcast-name"
			."\n\t--titles-append-pubdate"
			."\n"
			."\n"
			."\n\t--help			displays this screen."
			."\n"
			."\n"
			."\n\t		*wink* &remember alacast.php is written in PHP;"
			."\n\t		so its super easy to customize.  just remember to share ^_~"
			."\n"
			."\n"
		);
		
		exit( 0 );
		
	}//end:function help();



	function load_settings() {
		/*	here's where i setup and check all the directories i need
			to use, find, &rename/move all of my podcasts and their
			names and etc.
		*/
		static $i;
		if(!( (isset( $i )) ))
			$i = 0;
		else if( ($i++) > 10 )
			exit( "-10: I got stuck in my setup loop." );
			/* load_settings calls setup which might call
			   load_settings so just in case something weird goes on.
			*/
		
		if(!( $gPodder_config_fp = fopen( (sprintf("%s/.config/gpodder/gpodder.conf", (getenv( "HOME" )) )), "r" ) ))
			return gPodder_Config_Error( "gpodder.conf is not readable" );//exit(-1);
		
		$gPodder_config = preg_replace( "/[\r\n]+/m", "\t", fread( $gPodder_config_fp, (filesize( (sprintf("%s/.config/gpodder/gpodder.conf", (getenv( "HOME" )) )) )) ) );
		fclose( $gPodder_config_fp );
		
		if(!(
			(define( "GPODDER_SYNC_DIR", (preg_replace( "/.*mp3_player_folder = ([^\t]*).*/", "$1", $gPodder_config )) ))
			&&
			(define( "GPODDER_DL_DIR", (preg_replace( "/.*download_dir = ([^\t]*).*/", "$1", $gPodder_config )) ))
			&&
			(is_dir( GPODDER_DL_DIR ))
			&&
			( is_dir( GPODDER_SYNC_DIR ) )
		))
			return gPodder_Config_Error( "I couldn't load either gPodder's:\n\t\t'download_dir'(".GPODDER_DL_DIR.") or it's 'mp3_player_folder'(".GPODDER_SYNC_DIR.".\n\tPlease check gPodder's settings." );
		
		chdir( dirname( GPODDER_DL_DIR ) );
		
		return TRUE;
	}//end:function load_settings();
	
	
	
	function gPodder_Config_Error( $details = "" ) {
		$GLOBALS['alacast_logger']->output(
			"I couldn't load gPodder's settings from: '"
			.(getenv( "HOME" ))
			."/.config/gpodder/gpodder.conf''"
			.( $details
				? "\n\tDetails: {$details}"
				: ""
			)
			."\n\tWhich basically means I'm done; please fix this by: `Starting gPodder`->`Selecting Podcasts file menu`->`Preferences` and setting it's `Download Directory` & `MP3 Player`.\n",
			TRUE
		);
		exit( -1 );
	}//end:function gPodder_Config_Error();



	Function log_gPodders_downloads( &$gPodders_Output ) {
		//Logs' the URLs that where downloaded by the recently ran `gpodder --run`
		//TODO
	}//end function: log_gPodders_downloads();



	function run_gpodder_and_download_podcasts() {
		if(!(
			(
				(is_executable( ($gPoddersProgie = alacast_helper::preg_match_array($_SERVER['argv'],  "/^\-\-use\-gpodder=(.*)$/", "$1" )) ))
				&&
				(chdir( (dirname( $gPoddersProgie )) ))
				&&
				($gPoddersProgie="./".(basename( $gPoddersProgie ))." --local")
			)
			||
			(is_executable( ($gPoddersProgie = "/usr/bin/gpodder") ))
			||
			(is_executable( ($gPoddersProgie = exec( "which gpodder" )) ))
		))
			return $GLOBALS['alacasts_logger']->output( "I can't try to download any new podcasts because I can't find gPodder.", TRUE );
		
		if( (in_array("--nice", $_SERVER['argv'])) )
			$gPoddersProgie = "/usr/bin/nice --adjustment=19 {$gPoddersProgie}";
		
		$gPoddersProgie = "unset http_proxy; {$gPoddersProgie}";
		$GLOBALS['alacasts_logger']->output( ($GLOBALS['podcatcher']->set_status( "downloading new podcasts" )) );
		if( ($gPoddersExec = alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-use\-gpodder=(.*)$/", "$1" )) )
			$GLOBALS['alacasts_logger']->output( "~*~*~* Using {$gPoddersExec} *~*~*~\n" );
		
		$lastLine = "";
		switch( TRUE ) {
			/*case in_array("--logging", $_SERVER['argv']) :
				$gPodders_Output = array();
				$lastLine = exec("{$gPoddersProgie} --run 2> /dev/null", $gPodders_Output);
				
				if( (in_array("--update=detailed", $_SERVER['argv'])) )
					$GLOBALS['alacasts_logger']->output( (alacast_helper->array_to_string( $gPodders_Output, "\n" )), "", TRUE );
				
				if( (preg_match("/^D/", (ltrim($lastLine)) )) )
					log_gPodders_downloadss( $gPodders_Output );
			break;
			*/
			case in_array("--update=detailed", $_SERVER['argv']) :
				$lastLine = system("{$gPoddersProgie} --run > /dev/tty 2> /dev/null");
			break;
			
			default:
				$lastLine = exec("{$gPoddersProgie} --run > /dev/null 2> /dev/null");
			break;
		}
		
		$GLOBALS['alacasts_logger']->output( ($GLOBALS['podcatcher']->set_status( "downloading new podcasts", FALSE )) );
		
		if(!( (preg_match("/^D/", (ltrim($lastLine)) )) ))
			return FALSE;
		
		/*
		 * gPodder 0.10.0 need a lot longer than 5 seconds.
		 * So I've moved it to 31 seconds just to be okay.
		 */
		printf( "\nPlease wait while gPodder finishes downloading your podcasts new episodes" );
		for($i = 0; $i<33; $i++) {
			if(!($i%3))
				print( "." );
			
			usleep(500000); // waits for one half second.
		}
		print( "\n" );
		
		return TRUE;
		
	}//end:function run_gpodder_and_download_podcasts();
	


	function leave_symlink_trail( &$podcastsGUID, &$podcastsName ) {
		$podcastsTrailSymlink = (sprintf( "%s/%s/%s.trail", GPODDER_DL_DIR, $podcastsName, $podcastsGUID ));
		if( 
			(in_array( "--leave-trails", $_SERVER['argv'] ))
			&&
			(!( (file_exists( $podcastsTrailSymlink )) ))
		)
			return symlink(
				(sprintf( "%s/%s", GPODDER_DL_DIR, $podcastsGUID )),
				$podcastsTrailSymlink
			);
		
		if( 
			(in_array( "--clean-trails", $_SERVER['argv'] ))
			&&
			(file_exists( $podcastsTrailSymlink ))
		)
			return unlink( $podcastsTrailSymlink );
	}//end funtion: leave_symlink_trail();.
	
	
	
	function generate_podcasts_info( &$podcastsInfo, $totalPodcasts, $start = 1 ) {
		static $untitled_podcasts;
		if(!( (isset( $untitled_podcasts )) ))
			$untitled_podcasts = 1;
		
		if(!(
			(isset( $podcastsInfo[0] ))
			&&
			$podcastsInfo[0]
		)) {
			$podcastsInfo[0] = "Untitled podcast(s)";
			$untitled_podcasts +=  $start;
		}
		
		for($i = $start; $i<$totalPodcasts; $i++ )
			if(!(
				(isset( $podcastsInfo[$i] ))
				&&
				$podcastsInfo[$i]
			))
				$podcastsInfo[$i]=sprintf(
					"%s'%s episode %d from %s",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0] ))
						? ""
						: "s"
					),
					$untitled_podcasts++,
					(date( "r" ))
				);
	}//end:function generate_podcasts_info()



	function get_episode_titles( &$podcastsInfo, $podcastsXML_filename ) {
		if(!( (filesize($podcastsXML_filename)) ))
			return FALSE;
			
		$podcastsTempInfo = array();
		$podcastsXML_fp = fopen( $podcastsXML_filename, 'r' );
		$podcastsTempInfo = preg_replace("/[\r\n]+/m" , " - ",
					(fread(
						$podcastsXML_fp,
						(filesize($podcastsXML_filename))
					))
				);
		fclose($podcastsXML_fp);
		
		$podcastsTitles=preg_split(
					"/(<title>[^<]+<\/title>)/m", $podcastsTempInfo, -1,
					PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
		);
		
		if( (in_array( "--titles-append-pubdate", $_SERVER['argv'] )) )
			$podcastsPubDates=preg_split(
						"/(<pubDate>[^<]+<\/pubDate>)/m", $podcastsTempInfo, -1,
						PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
			);
		
		unset($podcastsTempInfo);
		
		if(!( (isset( $podcastsTitles[0] )) ))
			return FALSE;
		
		if($podcastsTitles[0] == $podcastsTitles[1])
			array_shift($podcastsTitles);
		
		$podcastsTitles['total'] = count($podcastsTitles);
		
		/* formats podcast & episode titles. */
		for($i=1; $i<$podcastsTitles['total']; $i++ )
			if( (preg_match("/^<title>[^<]*<\/title>$/", $podcastsTitles[$i])) )
				if(!isset($podcastsInfo[0]))
					$podcastsInfo[ $podcastsInfo['total']++ ] = html_entity_decode( preg_replace("/<title>[\ \t]*([^<]+)[\ \t]*<\/title>/", "$1", $podcastsTitles[$i]) );
				else{
					if( (in_array( "--titles-append-pubdate", $_SERVER['argv'] )) )
						$podcastsInfo[ $podcastsInfo['total']++ ] = html_entity_decode(sprintf("%s%s, released on: %s", ( (in_array( "--titles-prefix-podcast-name", $_SERVER['argv'] )) ?(sprintf("%s: ", $podcastsInfo[0])) :"" ), preg_replace("/<title>[\ \t]*([^<]*)[\ \t]*<\/title>/", "$1", $podcastsTitles[$i]), preg_replace("/<pubDate>[\ \t]*([^<]+)[\ \t]*<\/pubDate>/", "$1", $podcastsPubDates[($i-2)] ) ) );
					else
						$podcastsInfo[ $podcastsInfo['total']++ ] = html_entity_decode(sprintf("%s%s", ( (in_array( "--titles-prefix-podcast-name", $_SERVER['argv'] )) ?(sprintf("%s: ", $podcastsInfo[0])) :"" ), preg_replace("/<title>[\ \t]*([^<]*)[\ \t]*<\/title>/", "$1", $podcastsTitles[$i]) ) );
				}
		
		if(getenv("ALACAST_DEBUG")){
			print("Found podcastTitles:\n");
			print_r($podcastsTitles);
			print("\n\nFound podcastPubDates:\n");
			print_r($podcastsPubDates);
			print("\n\nFound podcastsInfo:\n");
			print_r($podcastsInfo);
		}
		unset($podcastsTitles);
		unset($podcastsPubDates);
		
		if( (in_array( "--verbose", $_SERVER['argv'] )) )
			$GLOBALS['alacasts_logger']->output(
				(sprintf(
					"\n*DEBUG*: I searched for %s'%s titles in %s.\nI've found titles for %d new episodes.",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0] ))
							?"s"
							:""
					),
					$podcastsXML_filename,
					( $podcastsInfo['total']-1 )
				))
			);
		
		return TRUE;
	}//end:function get_episode_titles()
	

	function get_characters_to_strip_from_titles(){
		static $bad_chars;
		
		if(isset($bad_chars)) return $bad_chars;

		if(!($bad_chars=alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-strip\-characters=?(.*)$/", "$1"))) $bad_chars="";
		
		switch(alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-player=?(.*)$/", "$1")){
			case FALSE: return $bad_chars;
			case "gstreamer":
				return ($bad_chars=sprintf("%s#", $bad_chars));
			case "vlc":
				return ($bad_chars=sprintf("%s:", $bad_chars));
			default:
				return ($bad_chars=sprintf("%s#:", $bad_chars));
		}
	}
	
	function clean_podcasts_info( &$podcastsInfo ) {
		/* replaces forward slashes with hyphens & strips leading dots('.').
		 * both for obvious(Linux) reasons. Other characters are stripped as well
		 * these are due to know issues that GStreamer, 
		*/
		for($i=0; $i<$podcastsInfo['total']; $i++)
			$podcastsInfo[$i]=preg_replace( "/^[~\.]+(.*)[~\.]+$/", "$1",
						(preg_replace( "/[\/]/", "-",
							(preg_replace( (sprintf("/[%s]/", get_characters_to_strip_from_titles())), "",
									(html_entity_decode(
										$podcastsInfo[$i],
									ENT_QUOTES,
									"UTF-8"
								))
							))
						))
			); //for( $i<$podcastInfo['total'] )
		
		$podcastsInfo[0]=preg_replace( "/^(the)\s+(.*)$/i", "$2, $1", $podcastsInfo[0] );
	}//end:function clean_podcasts_info();
	
	
	
	function set_podcasts_info( &$podcastsXML_filename, &$podcasts_info, &$podcastsGUID, &$totalPodcasts ) {
		get_episode_titles( $podcasts_info, $podcastsXML_filename );
		clean_podcasts_info( $podcasts_info );
		$GLOBALS['alacasts_titles']->reorder_titles( $podcasts_info );
		generate_podcasts_info( $podcasts_info, $totalPodcasts, $podcasts_info['total'] );
		$GLOBALS['alacasts_titles']->prefix_episope_titles_with_podcasts_title( $podcasts_info );
	}//end:function set_podcasts_info();



	function set_podcasts_new_episodes_filename( $podcastsName, $podcastsEpisode, $podcastsExtension ) {
		static $untitled_podcast_count;
		if( !(isset( $untitled_podcast_count )) )
			$untitled_podcast_count=0;
		
		if(!( $podcastsName && $podcastsEpisode)) {
			$podcastsEpisode=sprintf(
							"%d%s %s",
								((++$untitled_podcast_count)),
								($GLOBALS['alacasts_titles']->get_numbers_suffix( $untitled_podcast_count ) ),
								($podcastsName ?$podcastsName :"untitled podcast" )
			);
			
			if(!$podcastsName)
				$podcastsName="Untitled Podcast(s)";
		}

		$podcastsExtra = "";
		do {
			$Podcasts_New_Filename = sprintf(
				"%s/%s/%s%s.%s",
				GPODDER_SYNC_DIR,
				$podcastsName,
				$podcastsEpisode,
				$podcastsExtra,
				$podcastsExtension
			);
			
			$podcastsExtra = sprintf(
				"(copy from %s)",
				(date( "c" ))
			);
			
			sleep( 1 );
		} while( (file_exists( $Podcasts_New_Filename )) );

		return $Podcasts_New_Filename;
	}//end:function set_podcasts_new_episodes_filename()



	function do_I_need_to_run_gPodder() {
		static $do_I_update;
		if(!( (isset($do_I_update)) ))
			$do_I_update = alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-update/");
		
		
		if( $do_I_update )
			run_gpodder_and_download_podcasts();
	}//end:function do_I_need_to_run_gPodder();



	function move_gPodders_Podcasts() {
		
		do_I_need_to_run_gPodder();
		
		$GLOBALS['alacasts_logger']->output( ($GLOBALS['podcatcher']->set_status( "syncronizing podcasts" )) );
		
		$totalMovedPodcasts=0;
		$gPoddersPodcastDir = opendir(GPODDER_DL_DIR);
		while($podcastsGUID = readdir($gPoddersPodcastDir)) {
			if(!(
				(is_dir( (sprintf( "%s/%s", GPODDER_DL_DIR, $podcastsGUID )) ))
				&&
				(preg_match("/^[^.]+/", $podcastsGUID))
				&&
				(file_exists( ($podcastsXML_filename=(sprintf( "%s/%s/index.xml", GPODDER_DL_DIR, $podcastsGUID )) ) ))
			))
				continue;
			
			exec("touch {$podcastsXML_filename}");
			
			if( (isset( $podcastsFiles )) )
				unset( $podcastsFiles );
			$podcastsFiles=array();
			exec( (sprintf( "/bin/ls -t --width=1 --quoting-style=c %s/%s/*.*", GPODDER_DL_DIR, $podcastsGUID )), $podcastsFiles );
			
			if( ( ($podcastsFiles['total']=(count($podcastsFiles)) ) <= 1 ) ) continue;
			
			if( (isset( $podcastsInfo )) ) unset( $podcastsInfo );
			$podcastsInfo = array( 'total'  => 0 );
			set_podcasts_info( $podcastsXML_filename, $podcastsInfo, $podcastsGUID, $podcastsFiles['total'] );
			
			if(!(
				(is_dir(GPODDER_SYNC_DIR."/".$podcastsInfo[0]))
				||
				(mkdir(GPODDER_SYNC_DIR."/".$podcastsInfo[0], 0774, TRUE))
			)) {
				$GLOBALS['alacasts_logger']->output( "\n\tI've had to skip {$podcastsInfo[0]} because I couldn't create it's directory.\n\t\tPlease edit '{$podcastsXML_filename}' to fix this issue.", TRUE );//*wink*, it just kinda felt like a printf moment :P
				continue;
			}
			
			$GLOBALS['alacasts_logger']->output(
				(wordwrap(
					(
						"\n\n\t*w00t*! {$podcastsInfo[0]} has "
						.( $podcastsFiles['total']-1 )
						." new episode"
						.( ($podcastsFiles['total']>2)
							? "s!  They're"
							: "!  Its"
						)
						.":"
					),
					72,
					"\n\t\t"
				))
			);
			
			leave_symlink_trail( $podcastsGUID, $podcastsInfo[0] );
			
			$totalMovedPodcasts += move_podcasts_episodes( $podcastsGUID, $podcastsFiles, $podcastsInfo );
			
		}
		closedir($gPoddersPodcastDir);
		
		$GLOBALS['alacasts_logger']->output(  "\n\n\t"  );
		
		if( $totalMovedPodcasts )
			$GLOBALS['alacasts_logger']->output(  "^_^ *w00t*, you have {$totalMovedPodcasts} new podcasts!"  );
		else
			$GLOBALS['alacasts_logger']->output(  "^_^ There are no new podcasts."  );
		
		$GLOBALS['alacasts_logger']->output(
			"  Have fun! ^_^\n\n"
			. ($GLOBALS['podcatcher']->set_status( "syncronizing podcasts", FALSE ))
		);
		
		return TRUE;
	}// end 'move_gPodders_Podcasts' function.



	function get_filenames_extension( &$podcastsFilename ) {
		switch( ($ext = preg_replace(
			"/^.*\.([a-zA-Z0-9]{2,7})[\ ]*$/",
			"$1",
			(rtrim( $podcastsFilename ))
		)) ) {
			case "xml": case "html":
				return null;
			
			/*case "pdf":
				return null;*/
			
			case "m4v": case "mov":
				return "mp4";
			
			case "divx": case "xvid":
				return "avi";
			
			case "torrent":
				/*TODO: implement torent download.
				 * 1st - vby forking a program.
				 *soon I'd like to write a PECL torrent extension.
				*/
				return "torrent";
			
			default:
				return $ext;
		}//switch( $ext );
	}//function: function get_filenames_extension( &$podcastsFilename );



	function move_podcasts_episodes( &$podcastsGUID, &$podcastsFiles, &$podcastsInfo ) {
		$movedPodcasts=0;
		
		for($i=1, $z=($podcastsInfo['total']-1); $i<$podcastsFiles['total']; $i++, $z--) {
			$podcastsFiles[$i]=preg_replace('/^"(.*)"$/', '$1', $podcastsFiles[$i]);
			if(!( ($ext = get_filenames_extension( $podcastsFiles[$i] )) ))
				continue;
			
			$Podcasts_New_Filename
			=
			set_podcasts_new_episodes_filename( $podcastsInfo[0], $podcastsInfo[$z], $ext );
			
			if( (in_array("--verbose", $_SERVER['argv'])) )
				$GLOBALS['alacasts_logger']->output(
					(sprintf(
						"\n\t*DEBUG*: I'm moving:\n\t%s\n\t\t-to\n\t%s",
						$Podcasts_New_Filename
					))
				);
			
			if(
				(in_array( "--keep-original", $_SERVER['argv'] ))
				&&
				( (file_exists( $Podcasts_New_Filename )) )
			)
				continue;

			if(!(file_exists($podcastsFiles[$i])))
				continue;
			
			$cmd=sprintf("%s %s %s",
					(in_array("--keep-original", $_SERVER['argv']) ?"cp" : "mv"),
					preg_replace('/([\ \r\n])/', '\\\$1', $podcastsFiles[$i]),
					escapeshellarg($Podcasts_New_Filename)
			);
			
			$null_output=array();
			$link_check=-1;
			exec($cmd, $null_output, $link_check);
			if($link_check){
				printf("**ERROR:** failed to move podcast.\n\t link used:%s\n\terrno:%d\n\terror:\n\t%s\n", $cmd, $link_check, $null_output);
				continue;
			}
			
			$movedPodcasts++;
			
			//Prints the new episodes name:
			$GLOBALS['alacasts_logger']->output( "\n\t\t" . (wordwrap( $podcastsInfo[$i], 72, "\n\t\t\t" )) );
		}
		return $movedPodcasts;
	}//end:function move_podcasts_episodes();
	
	// Program == `alacast.php` starts here.
	
	if(!( (load_settings()) ))
		exit( -1 );

	$podcatcher = new alacasts_podcatcher_program();
	$alacasts_titles=new alacasts_titles();

	$alacasts_logger = new alacasts_logger(
		GPODDER_SYNC_DIR,
		"alacast",
		(in_array( "--logging", $_SERVER['argv'] )),
		(in_array( "--quiet", $_SERVER['argv'] ))
	);
	
	while( (move_gPodders_Podcasts()) ) {
		if(!( (in_array("--interactive", $_SERVER['argv'])) ))
			break;
		
		print( "\nPlease press [enter] to continue; [enter] 'q' to quit: " );
		if( (trim( (fgetc( STDIN )) ))  ==  'q' )
			break;
	}//while( (move_gPodders_Podcasts( )) );

?>
