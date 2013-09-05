package Hello::ViewController;
use base 'UIViewController';
use Hello::View;
use UITableView;
use UIColor;

sub load_view {
    my ($self) = @_;
    my $view = Hello::View->new();
    $view->background_color(UIColor->blue_color);
    my $table_view = UITableView->new();
    $table_view->background_color(UIColor->blue_color);
    $self->view($table_view);
}

1;
