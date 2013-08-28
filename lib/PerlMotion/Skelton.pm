package PerlMotion::Skelton;
use strict;
use warnings;
use File::Path qw/make_path/;
use YAML qw/Dump/;

sub generate_skelton {
    my ($app_name) = @_;
    generate_app_delegate_code($app_name);
}

sub generate_app_delegate_code {
    my ($app_name) = @_;
    my $app_delegate_code = do { local $/; <DATA> };
    my $code = sprintf($app_delegate_code, $app_name);
    make_path("extlib/$app_name");
    open my $fh, '>', "extlib/$app_name/AppDelegate.pm";
    print $fh $code;
    close $fh;
    print "generate extlib/$app_name/AppDelegate.pm\n";
    my $conf = {
        app_name => $app_name,
        delegate => "$app_name\::AppDelegate"
    };
    open $fh, '>', 'app.conf';
    print $fh Dump $conf;
    close $fh;
}

1;

__DATA__
package %s::AppDelegate;
use base 'AppDelegate';
use UIAlertView;

# this method is entrypoint of your application
sub application {
    my ($self, $options) = @_;
    my $alert = UIAlertView->new({
        init_with_title => 'HelloSample',
        message         => 'Hello PerlMotion!!'
    });
    $alert->show();
}

1;
