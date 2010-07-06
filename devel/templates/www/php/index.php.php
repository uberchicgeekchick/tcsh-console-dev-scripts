<?php
	/*
	 * (c) 2007-Present Kaity G. B. <uberChick -at- uberChicGeekChick.Com>
	 * 	http://uberChicGeekChick.Com/
	 *
	 * Hey!, I'm not the only uberChick trying to change &improve our world!
	 * We express ourselves, create our own art form, &hack our lives!
	 * You say "WHAT...HUH...WTF?!?" - Yup we're here.  Learn about us, our projects, &our lives:
	 *	@http://uberChicks.Net/
	 *
	 * ATTN: Any girl out here, reading this, please join &meet your peers.
	 */

	/*
	 * I live with a debilitating progressive neuro-muscular disease named Generalized Dystonia.
	 * If you find my software useful please let me know; &learn more about my life with GD:
	 * 	@http://Dystonia-DREAMS.Org/
	 * 		-and-
	 * 	@http://www.dystonia-foundation.org/pages/more_info/61.php
	 */

	/*
	 * NOTE: Currently I'm releasing all of my software under the RPL, but I'm working
	 * on my own license focused on software writen by myself and other
	 * open source internet artists(i.e. internet programmers, developers, designers, &etc).
	 * This new liscense will focus on internet based apps.  I've far to often seen
	 * internet applications improved, modified, or even re-factored but because they're
	 * never officially `released` companies never have to release or share their code.
	 * Since I've began writing mostly internet focused apps for the last several years.
	 * Either browser based or other style apps.  I want to ensure that my intention of
	 * my software being kept in the spirit of `free as in freedom`.  As an open source
	 * developers creating internet based software.  And my software can re-coded or
	 * whatever and since it may never be `released`, code never has to be recontributed.
	 * Which is problem I want to resolve for all of my future apps.  I'd stick with RPL
	 * but it seriously restricts options when it comes to REST based &APIs for my software.
	 * If you can help contribute to this new internet based open source license
	 * please, please, pretty please contact me.
	 */

	/*
	 * Unless explicitly acquired and licensed from Licensor under another license,
    	 * the contents of this file are subject to the Reciprocal Public License
    	 * ("RPL")
    	 * Version 1.3, or subsequent versions as allowed by the RPL, and You
    	 * may not copy or use this file in either source code or executable
    	 * form, except in compliance with the terms and conditions of the RPL.
	 * 
	 * All software distributed under the RPL is provided strictly on an
	 * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
    	 * LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING
    	 * WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR
    	 * A PARTICULAR PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the
    	 * RPL for specific language governing rights and limitations under
    	 * the RPL.
	 *
	 * ------------------------------------------------------------------------------
	 * |	a copy of the RPL may be found with this project or online at		|
	 * |	http://www.technicalpursuit.com/licenses/RPL_1.3.html			|
	 * --------------------------- current RPL disclaimer ---------------------------
	 */
	ini_set( "display_errors", TRUE );
	ini_set( "error_reporting", E_ALL | E_STRICT );
	ini_set( "date.timezone", "UTC" );
	
        /*      
         * TODO
         *      Have fun with this project!
         *      If not pick another or do something different.
         *      Find joy!
         */
        	
	header( "Content-Style-Type: text/css" );
	header( "Content-Type: text/html; charset=utf-8" );
	header( "Content-disposition: inline; filename={filename}.{extension}" );
	
	// And now, *gulp*, just do each step; step by step, baby steps, comment &verbose variables are fun.
	// program for fun.  If I forget than read 'Hackers &Painters' &'Hackers Manifesto'.
	print <<<XHTML
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>
	<head>
		<title>{$sites_title} - {$pages_title}</title>
		
		<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
		<meta name='description' value='{$sites_description} - {$pages_description}'/>
		<meta name='keywords' content='{$sites_tags},{$pages_tags}'/>
		
		<link rel='shortcut icon' href='./images/favicon.png'/>
		
		<!--
		<link rel='alternate' type='application/rss+xml' title='RSS 2.0' href='./rss2'/>
		<link rel='alternate' type='application/atom+xml' title='Atom 0.3 Feed' href='./atom.xml'/>
		-->
		
		<!--
		<script language='javascript' src='./javascript.json.js'></script>
		-->
		
		<!-- XML-RPC meta-tags:
		<link rel='pingback' type='application/pingback+xml' href='./xmlrpc.php'/>
		<link rel='EditURI' type='application/rsd+xml' title='RSD' href='./xmlrpc.php/rsd/>
		-->
		
		<!-- Stylesheets
		NOTE: Firebug can't debug @import rules.
		<style type='text/css'> @import url('./{$sites_stylesheet}.css'); </style>
		<link rel='stylesheet' href='./{$sites_stylesheet}.css' type='text/css'/>
		-->
	</head>
	<body>
		*Sqwee*... here I go.
	</body>
</html>
XHTML;

?>
