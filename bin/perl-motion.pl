#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Spec;
use lib File::Spec->catdir(dirname(__FILE__), "..", "lib");
use PerlMotion::CLI;

PerlMotion::CLI->new()->run(\@ARGV);
