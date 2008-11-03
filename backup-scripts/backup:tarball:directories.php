#!/usr/bin/php
<?php
	if(!((isset($_SERVER['argv']))&&(isset($_SERVER['argv'][1]))&&(is_dir($_SERVER['argv'][1])))){
		printf("Usage: %s [directory...]", basename($_SERVER['argv'][0]));
		exit(-1);
	}

	function create_tarballs($directory){
		$dir_fp=opendir($directory);
		while( ($directory=readdir($dir_fp)) )
			if((preg_match("/^[^\.]/",$directory))&&(is_dir($directory))){
				printf("Creating Tarball of: %s",$directory);
				exec((sprintf("tar -cjf '%s.tar.bz2' '%s/'\n", (basename($directory)), $directory)));
				if(!(file_exists((sprintf("%s.tar.bz2",$directory))))){
					printf("\t[failed]");
					continue;
				}

				printf("\t[done]\nRemoving: %s",$directory);
				exec((sprintf("rm -r '%s/'",$directory)));
				sleep(5);
				if(!(is_dir($directory)))
					printf("\t[done]");
				else
					printf("\t[failed]");
			}
		closedir($dir_fp);
	}

	for($n=1; $n<$_SERVER['argc']; $n++)
		create_tarballs($_SERVER['argv'][$n]);
?>
