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
	class alacasts_logger {
		private $programs_name;
		
		private $logging_enabled;
		private $silence_output;
		private $logs_path;
		
		private $year;
		private $month;
		private $day;
		
		private $current_hour;
		private $starting_hour;
		private $ending_hour;
		
		private $log_file;
		private $logs_fp;
		
		public function __construct( $logs_path = ".", $programs_name = "uberChick's progam", $logging_enable = TRUE, $silence_output = FALSE ) {
			$this->program_name = $programs_name;
			
			if( $silence_output )
				$this->silence_output=TRUE;
			else
				$this->silence_output=FALSE;
			
			if( ! $logging_enable )
				return $this->disable_logging();
			
			$this->log_file = "";
			if(!( (is_dir( $logs_path )) ))
				$this->logs_path = ".";
			else
				$this->logs_path = preg_replace( "/\/$/", "", $logs_path );
			
			$this->logging_enabled = TRUE;
			$this->setup_logging_data();
		}//method: public function __construct();
		
		private function disable_logging() {
			$this->logging_enabled = FALSE;
			
			$this->year = null;
			$this->month = null;
			$this->day = null;
			
			$this->current_hour = date( "H" );
			$this->starting_hour = null;
			
			$this->logs_fp = null;
		}//method: private function disable_logging();
		
		private function setup_logging_data() {
			$this->year = date("Y");
			$this->month = date("m");
			$this->day = date("d");
			
			$this->current_hour=date("H");
			
			$this->starting_hour = $this->current_hour - ( $this->current_hour % 6 );
			$this->ending_hour = $this->starting_hour + 5;
			
			$this->log_file=sprintf("%s/%s's log for %s-%s-%s from %s%s:00 through %s%s:59.log", $this->logs_path, $this->program_name, $this->year, $this->month, $this->day, (($this->starting_hour<10) ?"0" :""), $this->starting_hour, (($this->ending_hour<10) ?"0" :""), $this->ending_hour);
		}//method: private function setup_logging_data();
		
		private function check_log() {
			if( ! (
				(
					$this->log_file
					&&
					file_exists( $this->log_file )
				)
				&&
				$this->logs_fp
				&&
				($this->current_hour=date( "H" )) <= $this->ending_hour
				&&
				$this->current_hour > $this->starting_hour
			) )
				return TRUE;
			
			return FALSE;
		}//method:private function check_log();
		
		private function rotate_log() {
			if(!($this->check_log()) )
				return FALSE;
			
			$this->setup_logging_data();
			if( $this->logs_fp )
				fclose( $this->logs_fp );
			
			if(!( ($this->logs_fp = fopen( $this->log_file, "a" )) )) {
				fwrite( STDERR, (utf8_encode("I was unable to load the log file:\n\t\"{$this->log_file}\"\nLogging will be disabled.\n")) );
				$this->disable_logging();
				return FALSE;
			}
			return TRUE;
		}//method: private function rotate_log();
		
		public function log_output( &$string, &$error ) {
			if(!($this->logging_enabled))
				return;
			
			$this->rotate_log();
			fwrite( $this->logs_fp, (utf8_encode( (($error==TRUE) ? "*ERROR*:" : "" ) . $string )) );
		}//method: private function log_output();
		
		public function output( $string, $error = FALSE ) {
			$this->log_output( $string, $error );
		
			if( $error === TRUE )
				return fwrite( STDERR, (utf8_encode($string)) );
			
			if( $this->silence_output )
				return FALSE;
			
			return fwrite( STDOUT, (utf8_encode($string)) );
		}//method:public function output( $error = FALSE );
		
		private function close_log() {
			if( $this->logs_fp )
				fclose( $this->logs_fp );
		}//method:private function close_log();
		
		public function __destruct() {
			$this->close_log();
		}//method: public function __destruct();
	}//namespace: uberChicGeekChick; class: helper

?>
