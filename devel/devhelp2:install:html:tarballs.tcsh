#!/bin/tcsh -f
set gtk_doc_dir="/usr/share/gtk-doc/html";

foreach manual ( *html*.tar.gz )
	set extracted_to=`printf "${manual}" | sed 's/\(.*\)\.tar\.gz/\1/g'`;
	set book=`printf "${manual}" | sed 's/\(.*\)\-html\-[0-9\.]\+\.tar\.gz/\1/g'`;
	if ( -d "${extracted_to}" ) continue;
	printf "================ Extracting and installing ================\n\t%s" ${book};
	tar -xzf ${manual};
	if ( -l "${gtk_doc_dir}/${book}" ) then
		rm "${gtk_doc_dir}/${book}";
	else if ( -d "${gtk_doc_dir}/${book}" ) then
		rm -r "${gtk_doc_dir}/${book}";
	else if ( -e "${gtk_doc_dir}/${book}" ) then
		rm "${gtk_doc_dir}/${book}";
	endif
	printf "\t\t\t[done]\n"
	ln -sf ${cwd}/${extracted_to} ${gtk_doc_dir}/${book};
end
