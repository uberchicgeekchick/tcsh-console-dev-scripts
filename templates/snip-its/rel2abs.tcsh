	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set value="${cwd}/${value}";
	set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
	printf "%s" "${value}" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	unset escaped_value;
