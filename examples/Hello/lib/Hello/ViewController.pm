package Hello::ViewController;
use base 'UIViewController';
use Hello::View;
use UIColor;

sub load_view {
    my ($self) = @_;
    my $view = Hello::View->new();
    $view->background_color(UIColor->blue_color);
    $self->view($view);
}

1;
