package PerlMotion::CLI;
use strict;
use warnings;
use Getopt::Long;
use PerlMotion::Skelton;
use PerlMOtion::Builder;

sub new {
    my ($class) = @_;
    my $self = {};
    return bless $self, $class;
}

sub run {
    my ($self, $args) = @_;
    local @ARGV = @$args;
    my $p = Getopt::Long::Parser->new(
        config => ["no_ignore_case", "pass_through"],
    );
    $p->getoptions(
        "h|help"     => \$self->{help},
        "b|build"    => \$self->{build},
        "c|create=s" => \$self->{create},
    );
    if ($self->{help}) {
        $self->usage;
        return;
    }
    if ($self->{create}) {
        # create skelton code
        PerlMotion::Skelton::generate_skelton($self->{create});
    } elsif ($self->{build}) {
        print "build\n";
        PerlMotion::Builder::build();
    }
}

sub usage {
    my $self = shift;
    my $msg = <<"HELP";
Usage: perl-motion [--create=<ApplicationName>] [--help]
HELP
    print $msg, "\n";
}

1;
