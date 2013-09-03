package PerlMotion::Builder::PerlCompiler;
use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Compiler::CodeGenerator::LLVM;

sub new {
    my ($class, $output_name) = @_;
    my $self = {
        output => $output_name,
        library_path => ['lib'],
        debug  => 1
    };
    return bless $self, $class;
}

sub compile {
    my ($self, $delegate_name, $link_file_name) = @_;
    my $ast = $self->__make_ast(sprintf(<<CODE, $delegate_name));
IOS::store_ios_native_library(1);
use %s;
IOS::init(1);
CODE
    my $generator = Compiler::CodeGenerator::LLVM->new({
        '32bit'          => 1,
        runtime_api_path => $link_file_name
    });
    my $llvm_ir = $generator->generate($ast);
    open my $fh, '>', $self->{output};
    print $fh $llvm_ir;
    close $fh;
}

sub __make_ast {
    my ($self, $code) = @_;

    my $lexer = Compiler::Lexer->new('-');
    my $parser = Compiler::Parser->new();
    $lexer->set_library_path($self->{library_path});
    my $results = $lexer->recursive_tokenize($code);
    my %ast;
    foreach my $module_name (keys %$results) {
        my $tokens = $results->{$module_name};
        next unless @$tokens;
        $ast{$module_name} = $parser->parse($tokens);
    }
    $parser->link_ast(\%ast);
    my $main_ast = $ast{main};

    if ($self->{debug}) {
        my $renderer = Compiler::Parser::AST::Renderer->new();
        $renderer->render($main_ast);
    }

    return $main_ast;
}

1;
