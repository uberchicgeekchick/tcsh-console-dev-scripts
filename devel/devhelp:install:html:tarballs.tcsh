#!/bin/tcsh -f
set gtk_doc_dir="/usr/share/gtk-doc/html";
set gtk_doc_tgz="/projects/reference/gtk/GNOME/00-tarballs";

cd "${gtk_doc_tgz}"

if( ${?1} && "${1}" != "" && -d "${1}" ) cd "${1}"

foreach manual ( *html*.tar.gz )
	set extracted_to=`printf "%s" "${manual}" | sed 's/\(.*\)\.tar\.gz/\1/g'`;
	set book=`printf "%s" "${manual}" | sed 's/\(.*\)\-html\-[0-9\.]\+\.tar\.gz/\1/g'`;
	if( -d "${extracted_to}" ) \
		continue;
	printf "================ Extracting and installing ================\n\t%s" ${book};
	tar -C .. -xzf ${manual};
	if( -l "${gtk_doc_dir}/${book}" ) then
		rm "${gtk_doc_dir}/${book}";
	else if( -d "${gtk_doc_dir}/${book}" ) then
		rm -r "${gtk_doc_dir}/${book}";
	else if( -e "${gtk_doc_dir}/${book}" ) then
		rm "${gtk_doc_dir}/${book}";
	endif
	printf "\t\t\t[finished]\n"
	ln -sf ${cwd}/../${extracted_to} ${gtk_doc_dir}/${book};
end

