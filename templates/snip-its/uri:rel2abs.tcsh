	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set value="${cwd}/${value}";
	if( `printf "%s" "${value}" | sed -r 's/(\/)$/\1/'` != "/" ) \
		set value="${value}/";
	set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
	printf "%s" "${value}" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/[/]{2}/\//g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	#printf "[%s]\n" "${escaped_value}";
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		#printf "[%s]\n" "${escaped_value}";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\3/'`" == "/../" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		#printf "[%s]\n" "${escaped_value}";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(\/\.)(\.\/)?.*"\$"/\1/'`" == "/." )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^\/[.]{1,2}\//\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		#printf "[%s]\n" "${escaped_value}";
	end
	#printf "[%s]\n" "${escaped_value}";
	set value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/\/"\$"//'`";
