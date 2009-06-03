<?php
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
	 */
	class alacasts_titles extends alacast {
		public $renumbering_regular_expressions;
		
		public function __construct(){
			$this->load_renumbering_regular_expressions();
		}//__construct
		
		
		
		private function load_renumbering_regular_expressions(){
			$this->renumbering_regular_expressions=require_once(ALACASTS_INCLUDE_PATH."/settings/reordering.inc.php");
		}//load_renumbering_regular_expressions
		

		
		public function reorder_titles( &$podcasts_info ){
			return;
			for($i=0; $i<$podcasts_info['total']; $i++)
				for( $a=0; $a<$this->renumbering_regular_expressions['total']; $a++ )
					for( $n=0; $n<$this->renumbering_regular_expressions[$a]['total']; $n++ )
						if( (preg_match(
							$this->renumbering_regular_expressions[$a][$n][0],
							$podcasts_info[$i]
						)) )
							$podcasts_info[$i] = preg_replace(
								$this->renumbering_regular_expressions[$a][$n][0],
								$this->renumbering_regular_expressions[$a][$n][1],
								$podcasts_info[$i]
							);
		}//reorder_titles
		
		
		
		public function get_numbers_suffix( $number ){
			switch( $number ){
				case preg_match("/^[0-9]*1$/", $number):
					return "st";
				case preg_match("/^[0-9]*2$/", $number):
					return "nd";
				case preg_match("/^[0-9]*3$/", $number):
					return "rd";
				case preg_match("/^[0-9]*[4-9]$/", $number):
					return "th";
			}
		}//get_numbered_suffix
		
		
		
		public function prefix_episope_titles_with_podcasts_title( &$podcasts_info ) {
			if( !(alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-prefix\-episodes\-with\-podcast\-title/")) ) return;
		
			for( $i=1; $i<$podcasts_info['total']; $i++ )
				if( !(preg_match( "/^{$podcasts_info[0]}/", $podcastInfo[$i] )) )
					$podcasts_info[$i] = "{$podcasts_info[0]} - "
					.(preg_replace(
						"/{$podcasts_info[0]}/",
						"",
						$podcasts_info[$i]
					));
		}//prefix_episopes_titles( $podcasts_info );
		
		
		
		public function __destruct(){
		}//__destruct
		
	}//alacast::titles
?>

