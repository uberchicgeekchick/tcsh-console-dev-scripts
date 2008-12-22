#!/usr/bin/perl

#This needs to be converted to perl & than this command needs to be parsed to find "the movie":
#`/Programs/bin/HandBrakeCLI --input /dev/hda --title 0 | sort | uniq`

my $handbrake_exec = "/programs/bin/HandBrakeCLI";
my $dvd_device = "/dev/hda";

my $movies_title = `mount | grep "${dvd_device}" | cut -d'/' -f5 | cut -d' ' -f1 | sed 's/_/\ /g'`;
$movies_title =~ s/[\r\n]//g;
my $video_filename = "/media/movies/${movies_title}-[xvid][vorbis]";

my $rip_cmd="$handbrake_exec --input $dvd_device --title 1 --encoder xvid --aencoder vorbis --output '$video_filename.ogg'";

`$rip_cmd`;

`eject $dvd_device`;
