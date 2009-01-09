#!/usr/bin/perl
use strict;

foreach(`pidof -x gpodder`){`kill -INT $_`;}