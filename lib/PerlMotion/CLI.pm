package PerlMotion::CLI;
use strict;
use warnings;
use Getopt::Long;
use PerlMotion::Skelton;
use PerlMotion::Builder;

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub run {
    my ($self, $args) = @_;

    my @argv;
    my $p = Getopt::Long::Parser->new(
        config => ["no_ignore_case", "pass_through"],
    );
    $p->getoptionsfromarray(
        $args,
        "h|help"     => sub { unshift @argv, 'help' },
    );
    push @argv, @$args;

    my $command = shift @argv;
    if (defined $command && (my $cmd_code = $self->can("command_$command"))) {
        $cmd_code->(\@argv);
    } else {
        warn <<HELP;
Command not Found
HELP
        return 1;
    }

    return 0;
}

sub command_help {
    my $msg = <<"HELP";
Usage: perl-motion <command> [<args>]
Commands:
    create <ApplicationName>
    build
    help
HELP
    print $msg, "\n";
}

sub command_create {
    my ($argv) = @_;
    PerlMotion::Skelton::generate_skelton(@$argv);
}

sub command_build {
    my ($argv) = @_;
    PerlMotion::Builder->new->build;
}

1;
