package PerlMotion::Builder;
use strict;
use warnings;
use IO::File;
use IO::Handle;
use File::Spec;
use IPC::Run qw(run);
use File::Find qw(find);
use File::Copy qw(copy);
use File::Path qw(make_path remove_tree);
use File::Basename qw(basename dirname);
use YAML qw/LoadFile/;
use PerlMotion::Builder::PerlCompiler;

sub build {
    my $work_dir = 'build';
    my $conf = LoadFile 'app.conf';
    my $app_name = $conf->{app_name};
    my $app_delegate = $conf->{delegate};
    my $runtime_library_file = 'gen/runtime_api.m';
    my $SESSION_NAME = 'C3E39772-441E-4BD1-80D9-F051463BD7C3';

    run_command([qw|/usr/bin/killall iPhone Simulator|]);

    unless ($runtime_library_file) {
        die "could not find runtime library file";
    }

    my $app_dir = File::Spec->catdir(
        $work_dir,
        $app_name.".app"
    );

    make_dir($app_dir);

    my $simulator_app_dir = File::Spec->catdir(
        $ENV{HOME},
        'Library',
        'Application Support',
        'iPhone Simulator',
        '6.1',
        'Applications',
        $SESSION_NAME,
        $app_name.".app"
    );

    # make Info.plist
    build_info_plist("./Info.plist", $app_dir);

    # make ir file
    my $compile_dir = File::Spec->catdir("build");
    make_dir($compile_dir);

    compile_to_ir($runtime_library_file, 'gen');

    my $perl_compiler = PerlMotion::Builder::PerlCompiler->new($app_name);
    $perl_compiler->compile($app_delegate, "build/$runtime_library_file");
    print "compile successfuly\n";

    # make object file
    compile_ir_to_obj("$app_name\.ll", $compile_dir, $app_name);

    # link object files
    link_object_file([$runtime_library_file], $compile_dir, $app_dir, $app_name);

    # make dsym filep
    build_dsym_file($app_dir, $app_name);

    # make PkgInfo
    make_pkg_info($app_dir);

    # copy app to simulator
    remove_tree($simulator_app_dir);
    make_dir($simulator_app_dir);
    File::Copy::move($app_dir, $simulator_app_dir);

    # launch simulator
    exec 'open "/Applications/Xcode.app/Contents/Applications/iPhone Simulator.app"';
}

sub find_source_files {
    my ($dir) = @_;

    return find_files($dir, "m");
}

sub find_resource_files {
    my ($dir) = @_;

    return find_files($dir, "png");
}

sub find_storyboard_files {
    my ($dir) = @_;

    return find_files($dir, "storyboard");
}

sub find_files {
    my ($dir, $suffix) = @_;

    my @files;
    my $find = sub {
        my $file_name = $File::Find::name;
        return unless $file_name =~ m/\.($suffix)$/;
        push @files, $file_name;
    };

    find($find, $dir);

    return @files;
}

sub build_info_plist {
    my ($source, $appdir) = @_;
    my $output_dir = File::Spec->catfile($appdir, "Info.plist");
    system "plutil -convert binary1 $source -o $output_dir";
}

sub copy_file {
    my ($source, $destination_dir) = @_;

    warn "copy: from $source to $destination_dir";
    copy($source, $destination_dir);
}

sub build_dsym_file {
    my ($app_dir, $app_name) = @_;

    my @command = (
        'dsymutil',
        File::Spec->catfile($app_dir, $app_name),
        '-o', $app_dir.".dSYM",
    );

    run_command(\@command);
}

sub link_object_file {
    my ($files, $compile_dir, $app_dir, $app_name) = @_;

    my $list_file_name = File::Spec->catfile($compile_dir, "LinkFileList");
    my $link_list_file = IO::File->new(
        $list_file_name,
        'w'
    );
    for (@$files) {
        $link_list_file->print(
            File::Spec->catfile($compile_dir, "$app_name\.o"),
        );
        $link_list_file->print("\n");
    }
    $link_list_file->close;

    my @command = (qw(
        /usr/local/bin/clang
        -arch i386
        -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk
        -Xlinker
        -objc_abi_version
        -Xlinker 2
        -fobjc-arc
        -fobjc-link-runtime
        -Xlinker
        -no_implicit_dylibs
        -mios-simulator-version-min=6.1
        -framework UIKit
        -framework Foundation
        -framework CoreGraphics
    ),
        '-filelist', $list_file_name,
        '-o', File::Spec->catfile($app_dir, $app_name),
    );

    run_command(\@command);
}

sub compile_ir_to_obj {
    my ($file, $compile_dir, $app_name) = @_;

    #my $basename = basename($file, ".ll");
    my @command = (qw(
       llc
       -filetype=obj
       -march=x86
       ),
       '-o',
       File::Spec->catfile($compile_dir, "$app_name\.o"),
       File::Spec->catfile($compile_dir, "$app_name\.ll")
    );
    run_command(\@command);
}

sub compile_to_ir {
    my ($file, $compile_dir) = @_;

    my ($in, $out, $err);
    my $basename = basename($file, ".m");
    my @command = (qw(
        /usr/local/bin/clang
        -S
        -emit-llvm
        -x objective-c
        -arch i386
        -fmessage-length=0
        -std=gnu99
        -fobjc-arc
        -Wno-trigraphs
        -fpascal-strings
        -O0
        -Wno-missing-field-initializers
        -Wno-missing-prototypes
        -Wreturn-type
        -Wno-implicit-atomic-properties
        -Wno-receiver-is-weak
        -Wduplicate-method-match
        -Wformat
        -Wno-missing-braces
        -Wparentheses
        -Wswitch
        -Wno-unused-function
        -Wno-unused-label
        -Wno-unused-parameter
        -Wunused-variable
        -Wunused-value
        -Wempty-body
        -Wuninitialized
        -Wno-unknown-pragmas
        -Wno-shadow
        -Wno-four-char-constants
        -Wno-conversion
        -Wconstant-conversion
        -Wint-conversion
        -Wenum-conversion
        -Wno-shorten-64-to-32
        -Wpointer-sign
        -Wno-newline-eof
        -Wno-selector
        -Wno-strict-selector-match
        -Wno-undeclared-selector
        -Wno-deprecated-implementations
        -DDEBUG=1
        -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk
        -fexceptions
        -fasm-blocks
        -fstrict-aliasing
        -Wprotocol
        -Wdeprecated-declarations
        -g
        -Wno-sign-conversion
        -fobjc-abi-version=2
        -fobjc-legacy-dispatch
        -mios-simulator-version-min=6.1
        -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
        -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
        -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
        -MMD
        -MT
        dependencies
    ),
        '--serialize-diagnostics',
        File::Spec->catfile($compile_dir, $basename.".dia"),
        '-c',
        $file,
        '-o',
        File::Spec->catfile($compile_dir, $basename.".lli")
    );
    run_command(\@command);
}

sub make_pkg_info {
    my ($app_dir) = @_;

    my $pkg_info = IO::File->new(
        File::Spec->catfile($app_dir, "PkgInfo"),
        'w'
    );
    $pkg_info->print("APPL????\n");
    $pkg_info->close;
}

sub run_command {
    my ($command, $dont_died_if_has_error) = @_;

    warn join(" ", @$command);
    my ($in, $out, $err);
    run $command, \$in, \$out, \$err;

    unless ($dont_died_if_has_error) {
        if ($err) {
            warn $err;
            #die $err;
        }
    }
}

sub make_dir {
    my ($dir) = @_;
    my $cdir = File::Spec->abs2rel($dir);
    warn "make_path: ".$cdir;
    make_path($cdir);
}

1;
__END__
