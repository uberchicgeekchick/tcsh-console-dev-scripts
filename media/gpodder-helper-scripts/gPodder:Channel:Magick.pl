#!/usr/bin/perl -w
use strict;
my $command="gpodder";
my $what_to_do="display";
my $what_to_find;

sub what_to_do_what_to_do{
	if( "$_"eq"subscribe" || "$_"eq"add" ){ return "add"; }
	if( "$_"eq"unsubscribe" || "$_"eq"delete" ){ return "del"; }
	return "display";
}#sub what_to_do_what_to_do

sub parse_arguments{
	foreach(@ARGV){
		my $option=$_;
		$option=~s/\-\-([^=]+)?=(.*)$/$1/;
		my $value=$_;
		$value=~s/\-\-([^=]+)?=(.*)$/$1/;
		if( "$option"eq"action" ){
			$what_to_do=what_to_do_what_to_do($value);
			next;
		}
	}#foreach(@ARGV)
}#sub parse_arguments

parse_arguments();

set action = "display"
foreach( $ARGV ){
	set attrib = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
	if ( "${attrib}" == "" ) continue
	
	set value = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
	shift;
	set values;
	switch ( "${attrib}" )
	case "title":
	case "xmlUrl":
	case "htmlUrl":
	case "text":
	case "description":
		set values = ( "${value}" );
		breaksw

	case "titles-in":
	case "xmlUrls-in":
	case "htmlUrls-in":
	case "texts-in":
	case "descriptions-in":
		set attrib = `printf "${attrib}" | sed 's/^\(.*\)s\-in$/\1/'`
		if ( ! -e "${value}" ) continue
		set values = "`cat ${value}`"
		#foreach value ( "`cat '${value}'`" )
		#	set values = ( ${values} "${value}" )
		#end
		breaksw
	default:
		printf "\t%s is not supported.\n\tSupported options are --[titles-in|xmlUrls-in|htmlUrls-in|texts-in|descriptions-in]="\""[file_listing_values (one per line)]"\""\n\tFor more information see %s --help\n" "${attrib}" `basename "${0}"`
		continue
	endsw
	
	foreach value ( "`echo '${values}'`" )
		echo "-->${value}<--\n"
		continue
		set found_podcast = "FALSE"
		foreach podcast ( "`/usr/bin/grep -i --perl-regex -e '${attrib}=["\""'\''].*${value}.*["\""'\'']' '${HOME}/.config/gpodder/channels.opml' | sed 's/\([\|\>]\)/\\\1/g'`" )
			set title = "`echo ${podcast} | sed 's/.*title=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			set text = "`echo ${podcast} | sed 's/.*text=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			set xmlUrl = "`echo ${podcast} | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			printf "%s: %s ( %s )\t[found]\n" "${xmlUrl}" "${title}" "${text}"
			continue
			if ( "${found_podcast}" == "FALSE" ) set found_podcast = "TRUE"
			switch( "${action}" )
			case "delete":
				printf "Deleting: %s ( %s ) @ %s\n" "${title}" "${text}" "${xmlUrl}"
				gpodder --del="${xmlUrl}"
				breaksw
			case "display":
			default:
				printf "%s: %s ( %s )\t[found]\n" "${xmlUrl}" "${title}" "${text}"
				breaksw
			endsw
		end
		continue
		if ( "${found_podcast}" == "TRUE" ) continue
		
		switch( "${action}" )
		case "add":
			if ( "${attrib}" != "xmlUrl" ) then
				printf "Only xmlUrl(s) may be subscribed to\n\t%s was not found\n" "${value}"
			else
				printf "Adding: %s\n" "${value}"
				gpodder --add="${value}"
			endif
			breaksw
		case "display":
		default:
			printf "%s: %s\t[not found]\n" "${attrib}" "${value}"
			breaksw
		endsw
	end
end
}#foreach
exit

usage:
	printf "Usage: %s [--help] [--display(default) or --del,--delete,--unsubscribe or --add, --subscribe] --[title(s-in)|xmlUrl(s-in)|htmlUrl(s-in)|text(s-in)|description(s-in)]="\""[a regex, or file containing regexes, to search for]"\""\n" "`basename '${0}'`"
	exit
