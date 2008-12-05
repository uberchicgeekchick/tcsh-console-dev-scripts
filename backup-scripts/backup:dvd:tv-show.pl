#!/usr/bin/perl
use strict;

#This needs to be converted to perl & than this command needs to be parsed to find "the movie":
#`/Programs/bin/HandBrakeCLI --input /dev/hda --title 0 | sort | uniq`

my $handbrake_exec = "/programs/bin/HandBrakeCLI";
my $dvd_device = "/dev/hda";

my $series_title = `mount | grep "$dvd_device" | cut -d'/' -f5 | cut -d' ' -f1 | sed 's/_/\ /g'`;
$series_title =~ s/[\r\n]//g;
if ( ! $series_title ) {
	print("I'm unable to find any correct t.v. show or mounted DVD.$series_title");
	exit(-1);
}
lc($series_title);
my $series_path = "/media/tv-shows/$series_title";

while ( ! -d "$series_path" ) {
	`mkdir -p "$series_path"`;
}

# $title needs to be set by running `HandBrakeCLI --title 0`
# to find all of the titles with durations long enough to be backed up.
my $episode = 0;
my $video_filename="";
for (my $n; $n<@ARGV; $n++ ) {

	do{
		$episode++;
		$video_filename="$series_path/$series_title - Episode $episode - [xvid][vorbis].ogg";
	} while ( -e "$video_filename" );

	my $handbrake_cli = "$handbrake_exec --cpu 1 --input $dvd_device --title $ARGV[$n] --encoder xvid --aencoder vorbis --output '$video_filename'";
	`$handbrake_cli`;
}

`sudo eject $dvd_device`;

