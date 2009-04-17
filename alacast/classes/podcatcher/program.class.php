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
	 * ---------------------------------------------------------------------------------
	 * |	A copy of the RPL 1.5 may be found with this project or online at	|
	 * |		http://opensource.org/licenses/rpl1.5.txt					|
	 * ---------------------------------------------------------------------------------
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
	class alacasts_podcatcher_program {
		private $starting_dir;
		private $working_dir;
		
		private $command;
		private $config_path;
		
		private $options;
		private $nice;
		
		public $status;
		
		public function __construct( $command = "/usr/bin/gpodder", $options = "--run", $config_path = "~/.config/gpodder/gpodder.conf", $nice = null ) {
			$this->starting_dir = exec( "pwd" );
			$this->working_dir = dirname( $_SERVER['argv'][0] );
			
			if( ($this->nice=$nice) && (preg_match( "/^[+-]{1}[0-9]{1,2}$/", $nice )) ) {
				$this->setup_nice( $nice );
			} else
				$this->nice = "";
			
			$this->status = "waiting";
		}//method:public function __construct( $command = "/usr/bin/gpodder", $options = "--run", $config_path = "~/.config/gpodder/gpodder.conf" );
		
		private function setup_nice() {
			if( (preg_match( "/^\+/", $this->nice )) ) {
				$root_passwd=fscanf( STDIN, "%s" );
			}
			
			if( (isset( $root_passwd )) )
				unset( $root_passwd );
		}//method:private function setup_nice( $nice );
		
		public function set_status( $action = "", $starting = true ) {
			if( $starting && $action )
				$this->status = $action;
			else
				$this->status = "waiting";
			
			return sprintf(
				"~*~*~* I've %s %s @ %s *~*~*~\n",
				( $starting
					?"started"
					:"finished"
				),
				$action,
				(date( "c" ))
			);
		}//method:public function set_status( $action = "running", $finished = false );
		
		public function destruct() {
			chdir( $this->starting_dir );
		}//method:public function destruct();
	}//namespace: uberChicGeekChicks::gPodder; class: exec.
?>
