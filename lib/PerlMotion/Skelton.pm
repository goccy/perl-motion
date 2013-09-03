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
    my $conf = {
        app_name => $app_name,
        delegate => "$app_name\::AppDelegate"
    };
    make_path("$app_name/lib/$app_name");
    open my $fh, '>', "$app_name/lib/$app_name/AppDelegate.pm";
    print $fh $code;
    close $fh;
    print "generate $app_name\n";
    print "generate $app_name/lib\n";
    print "generate $app_name/lib/$app_name\n";
    print "generate $app_name/lib/$app_name/AppDelegate.pm\n";
    open $fh, '>', "$app_name/app.conf";
    print $fh Dump $conf;
    close $fh;
    print "generate $app_name/app.conf\n";
}

1;

__DATA__
package %s::AppDelegate;
use base 'UIApplicationDelegate';
use UIAlertView;

# this method is entrypoint of your application
sub application {
    my ($app, $options) = @_;
    my $alert = UIAlertView->new({
        init_with_title => 'HelloSample',
        message         => 'Hello PerlMotion!!'
    });
    $alert->show();
}

1;
