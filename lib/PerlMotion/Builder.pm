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
use PerlMotion::Builder::InfoPlist;

sub new {
    my ($class) = @_;
    my $work_dir = 'build';
    my $conf = LoadFile 'app.conf';
    chomp(my $bin_dir = `llvm-config --bindir`);
    my $clang = "$bin_dir/clang";
    die 'could not find clang' unless $clang;
    my $app_name = $conf->{app_name};

    my $self = {
        app_name     => $app_name,
        app_delegate => $conf->{delegate},
        app_dir      => File::Spec->catdir($work_dir, "$app_name\.app"),
        build_dir    => 'build',
        simulator_app_dir => simulator_dir($app_name),
        storyboard_files => [ find_storyboard_files('.') ],
        clang        => $clang,
        'llvm-link'  => "$bin_dir/llvm-link",
        perl_motion_core_libs => dirname(__FILE__) . '/Builder/PerlCompiler/perl_motion_core_libs'
    };

    return bless $self, $class;
}

sub build {
    my ($self) = @_;

    run_command([qw|/usr/bin/killall iPhone Simulator|]);

    make_dir($self->{app_dir});

    $self->build_localize_file('.', $self->{app_dir});

    $self->build_storyboard($_) foreach @{$self->{storyboard_files}};

    $self->build_info_plist();

    make_dir($self->{build_dir});

    $self->build_simulator_code();

    build_dsym_file($self->{app_dir}, $self->{app_name});

    make_pkg_info($self->{app_dir});

    # copy app to simulator
    remove_tree($self->{simulator_app_dir});
    make_dir($self->{simulator_app_dir});
    File::Copy::move($self->{app_dir}, $self->{simulator_app_dir});

    # launch simulator
    exec 'open "/Applications/Xcode.app/Contents/Applications/iPhone Simulator.app"';
}

sub simulator_dir {
    my ($app_name) = @_;

    my $sdk_version = '6.1';
    my $SESSION_NAME = 'C3E39772-441E-4BD1-80D9-F051463BD7C3';

    return File::Spec->catdir(
        $ENV{HOME},
        'Library',
        'Application Support',
        'iPhone Simulator',
        $sdk_version,
        'Applications',
        $SESSION_NAME,
        "$app_name\.app"
    );
}

sub build_simulator_code {
    my ($self) = @_;

    my $i386_core_libs = $self->{perl_motion_core_libs} . '_32';
    $self->compile_to_ir($i386_core_libs);

    my $output_ir_name = 'build/' . $self->{app_name} . '.ll';
    my $perl_compiler = PerlMotion::Builder::PerlCompiler->new($output_ir_name);
    $perl_compiler->compile($self->{app_delegate}, "$i386_core_libs.ll");

    print "compile successfuly\n";

    $self->compile_ir_to_obj();

    $self->link_object_file();
}

sub compile_to_ir {
    my ($self, $core_libs) = @_;

    my $basename = basename $core_libs;
    my $dirname = dirname $core_libs;

    my $path = dirname $INC{'Compiler/CodeGenerator/LLVM.pm'};
    my $runtime_api_header_path = "$path/LLVM";
    my $runtime_api_ir = "$runtime_api_header_path/runtime_api_32.ll";

    my ($in, $out, $err);

    run_command([
        $self->{clang},
        qw(
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
        ),
        "-I$runtime_api_header_path",
        '-MMD',
        '-MT',
        'dependencies',
        '--serialize-diagnostics',
        File::Spec->catfile($dirname, $basename.".dia"),
        '-c',
        File::Spec->catfile($dirname, $basename.".m"),
        '-o',
        File::Spec->catfile($dirname, $basename.".ll")
    ]);

    run_command([
        $self->{'llvm-link'},
        '-o',
        File::Spec->catfile($dirname, $basename.".ll"),
        File::Spec->catfile($dirname, $basename.".ll"),
        $runtime_api_ir
    ]);
}

sub compile_ir_to_obj {
    my ($self) = @_;
    my $app_name = $self->{app_name};

    run_command([qw(
       llc
       -filetype=obj
       -march=x86
       ),
       '-o',
       File::Spec->catfile($self->{build_dir}, "$app_name\.o"),
       File::Spec->catfile($self->{build_dir}, "$app_name\.ll"),
    ]);
}

sub link_object_file {
    my ($self) = @_;

    my $app_name = $self->{app_name};
    my $list_file_name = File::Spec->catfile($self->{build_dir}, "LinkFileList");
    my $link_list_file = IO::File->new($list_file_name, 'w');
    $link_list_file->print(File::Spec->catfile($self->{build_dir}, "$app_name\.o"));
    $link_list_file->print("\n");
    $link_list_file->close;

    run_command([
        $self->{clang},
        qw(
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
        '-o', File::Spec->catfile($self->{app_dir}, $self->{app_name}),
    ]);
}

sub find_resource_files {
    my ($self) = @_;

    return find_files($self->{app_dir}, "png");
}

sub find_storyboard_files {
    my ($app_dir) = @_;

    return find_files($app_dir, "storyboard");
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

sub build_storyboard {
    my ($self, $storyboard_file) = @_;

    my $app_dir = $self->{app_dir};
    my $basename = basename($storyboard_file, ".storyboard");
    run_command([
        qw(
              /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/ibtool
              --errors
              --warnings
              --notices
              --output-format human-readable-text
              --sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk
        ),
        '--compile',
        File::Spec->catdir($app_dir, 'en.lproj', $basename.".storyboardc"),
        $storyboard_file,
    ]);
}

sub build_localize_file {
    my ($self, $base_dir) = @_;

    my $app_dir = $self->{app_dir};
    make_dir(File::Spec->catdir($app_dir, 'en.lproj'));
    my @command = (
        'plutil',
        '-convert', 'binary1',
        File::Spec->catfile($base_dir, 'en.lproj', 'InfoPlist.strings'),
        '-o',
        File::Spec->catfile($app_dir, 'en.lproj', 'InfoPlist.strings'),
    );

    run_command(\@command);
}

sub build_info_plist {
    my ($self) = @_;

    PerlMotion::Builder::InfoPlist->make(
        $self->{build_dir},
        $self->{app_dir},
        {
            app_name       => $self->{app_name},
            use_storyboard => scalar @{$self->{storyboard_files}}
        }
    );
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
        warn $err if ($err);
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
