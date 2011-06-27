#!/usr/bin/perl
use strict;

#This needs to be converted to perl & than this command needs to be parsed to find "the movie":
#`/Programs/bin/HandBrakeCLI --input /dev/hda --title 0 | sort | uniq`

my $handbrake_exec="/programs/bin/HandBrakeCLI";
my $dvd_device="/dev/sr0";
my $media_dir="/media";
#my $media_dir="/projects/media";

my $series_title=`mount | grep "$dvd_device" | cut -d'/' -f5 | cut -d' ' -f1 | sed 's/_/\ /g'`;
$series_title =~ s/[\r\n]//g;
if ( ! $series_title ) {
	print("I'm unable to find any correct t.v. show or mounted DVD.$series_title");
	exit(-1);
}
lc($series_title);
my $series_path="$media_dir/tv-shows/$series_title";
while ( ! -d "$series_path" ) {
	`mkdir -p "$series_path"`;
}

#my $audio_quality=-1;#xvid w/mp3
my $audio_quality=1;#xvid w/ogg
my $audio_codec="";
my $extension="";
my $final_extension="";
if ( $audio_quality > 0 ) {
	$audio_codec="vorbis";
	$extension="ogg";
	$final_extension=$extension;
} else {
	$audio_codec="mp3";
	$extension="avi";
	$final_extension="xvid";
}


# $title needs to be set by running `HandBrakeCLI --title 0`
# to find all of the titles with durations long enough to be backed up.
my $episode=0;
my $video_filename="";
for (my $n; $n<@ARGV; $n++ ) {

	do{
		$episode++;
		$video_filename="$series_path/$series_title - Episode $episode - [xvid][$audio_codec].$extension";
	} while ( -e "$video_filename" );

	my $handbrake_cli="$handbrake_exec --input $dvd_device --title $ARGV[$n] --encoder xvid --aencoder vorbis --output '$video_filename'";
	`$handbrake_cli`;
	if ( $extension != $final_extension ) {
		`mv '$video_filename.$extension' '$video_filename.$final_extension'`;
	}
}

`eject $dvd_device`;

