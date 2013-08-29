package PerlMotion::Builder::InfoPlist;
use strict;
use warnings;

use JSON qw(encode_json);
use IO::File;
use IO::Handle;
use File::Spec;

my $TEMPLATE = {
    "UIRequiredDeviceCapabilities" => ["armv7"],
    "CFBundleInfoDictionaryVersion" => "6.0",
    "CFBundleVersion" => "1.0",
    "LSRequiresIPhoneOS" => 1,
    "UISupportedInterfaceOrientations" => [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight"
    ],
    "UISupportedInterfaceOrientations~ipad" => [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationPortraitUpsideDown",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight"
    ],
    "CFBundleSignature" => "????",
    "CFBundlePackageType" => "APPL",
    "CFBundleDevelopmentRegion" => "en",
    "CFBundleShortVersionString" => "1.0"
};

sub make {
    my ($class, $work_dir, $app_dir, $args) = @_;

    my $temporary_info = $TEMPLATE;
    $temporary_info->{CFBundleExecutable} = $args->{app_name};
    $temporary_info->{CFBundleIdentifier} = "com.".$args->{app_name};
    $temporary_info->{CFBundleDisplayName} = $args->{app_name};
    if ($args->{use_storyboard}) {
        $temporary_info->{UIMainStoryboardFile} = "MainStoryboard_iPhone";
        $temporary_info->{"UIMainStoryboardFile~ipad"} = "MainStoryboard_iPad";
    }

    my $tmp_file = File::Spec->catfile($work_dir, "info.plist.tmp");
    warn $tmp_file;
    my $fh = IO::File->new($tmp_file, 'w');
    $fh->print(encode_json($temporary_info));
    $fh->close;

    my $info_plist = File::Spec->catfile($app_dir, "Info.plist");
    system "plutil -convert binary1 $tmp_file -o $info_plist";
}

1;
__END__
