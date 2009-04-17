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
	class alacasts_playlist{
		private $playlist_filename;
		private $playlist_fp;
		private $total;

		public function __construct(array &$new_podcasts){
			if(!($this->total=count($new_podcasts)) )
				return;
			$this->playlist_fp=fopen($this->playlist_filename);
		}//__construct
		
		public function __destruct(){
			if( (isset($this->playlist_fp)) )
				fclose($this->playlist_fp);
		}//__destruct
		
	}
?>
