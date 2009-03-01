#!/usr/bin/perl

#This needs to be converted to perl & than this command needs to be parsed to find "the movie":
#`/Programs/bin/HandBrakeCLI --input /dev/hda --title 0 | sort | uniq`

my $handbrake_exec = "/programs/bin/HandBrakeCLI";
my $dvd_device = "/dev/hda";

my $audio_quality = -1;

my $movies_title = `mount | grep "${dvd_device}" | cut -d'/' -f5 | cut -d' ' -f1 | sed 's/_/\ /g'`;
$movies_title =~ s/[\r\n]//g;

my $audio_codec = "";
my $extension = "";
my $final_extension = "";
if ( $audio_quality > 0 ) {
	$audio_codec="vorbis";
	$extension = "ogg";
	$final_extension = $extension;
} else {
	$audio_codec = "mp3";
	$extension = "avi";
	$final_extension = "xvid";
}

my $video_filename = "/media/movies/$movies_title-[Xvid][$audio_codec]";

my $rip_cmd="$handbrake_exec --input $dvd_device --title 1 --encoder xvid --aencoder $audio_codec --output '$video_filename.$extension'";

`$rip_cmd`;

if ( $extension != $final_extension ) {
	`mv '$video_filename.$extension' '$video_filename.$final_extension'`;
}

`eject $dvd_device`;
