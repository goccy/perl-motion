package Hello::AppDelegate;
use base 'UIApplicationDelegate';
use UIAlertView;
use UIWindow;
use UIScreen;
use Hello::ViewController;

# this method is entrypoint of your application
sub application {
    my ($app) = @_;
    my $alert = UIAlertView->new->init_with_title('Hello', {
        message => 'Hello PerlMotion!!'
    });
    $alert->add_button_with_title("Button");
    my $title = $alert->button_title_at_index(0);
    $alert->dismiss_with_clicked_button_index(0, { animated => 1 });
    $alert->show();
    my $window = UIWindow->new()->init_with_frame(UIScreen->main_screen->bounds);
    $window->root_view_controller(Hello::ViewController->new);
    $window->root_view_controller->wants_full_screen_layout(1);
    $window->make_key_and_visible;
    $app->window($window);
}

1;
