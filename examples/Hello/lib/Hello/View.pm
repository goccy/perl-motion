package Hello::View;
use base 'UITableView';
use UIColor;
use UIImage;

sub touches_began {
    my ($self) = @_;
    my $image = UIImage->image_named('yapc2013.png');
    my $color = UIColor->new->init_with_pattern_image($image);
    $self->background_color($color);
}

1;
