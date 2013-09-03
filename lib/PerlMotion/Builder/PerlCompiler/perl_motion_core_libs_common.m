@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//fprintf(stderr, "called AppDelegate::application\n");
	pthread_mutex_lock(&mutex);
	size_t key_size = pkg_map->size;
	StringObject **keys = pkg_map->keys;
	PackageObject *app_delegate_pkg = NULL;
	for (size_t i = 0; i < key_size; i++) {
		if (!keys[i]) continue;
		PackageObject *pkg = to_Package(pkg_map->table[keys[i]->hash].o);
		for (size_t j = 0; j < pkg->isa->size; j++) {
			PackageObject *base = to_Package(pkg->isa->list[j]->o);
			if (!strncmp(base->name, "UIApplicationDelegate", sizeof("UIApplicationDelegate"))) {
				app_delegate_pkg = pkg;
				break;
			}
		}
	}
	pthread_mutex_unlock(&mutex);
	StringObject *application_method = to_String((new_String("application")).o);
	CodeRefObject *app = to_CodeRef(app_delegate_pkg->table[application_method->hash].o);
	fprintf(stderr, "application = [%p]\n", application);
	fprintf(stderr, "app = [%p]\n", app);
	fprintf(stderr, "app->code = [%p]\n", app->code);
	Value **list = (Value **)malloc(sizeof(Value *));
	Value *o = (Value *)fetch_object();
	*o = new_FFI("UIApplication", (__bridge_retained void *)application);
	list[0] = o;
	ArrayObject *args = to_Array((new_Array(list, 1)).o);
	fprintf(stderr, "app? [%p]\n", (to_FFI(args->list[0]->o))->ptr);
	app->code(args);
	return YES;
}

@end

@interface PerlMotionUIView : UIView

@property PackageObject *pkg;

@end

@implementation PerlMotionUIView

@end

@interface PerlMotionUIViewController : UIViewController

@property PackageObject *pkg;

@end

@implementation PerlMotionUIViewController

- (void)loadView
{
	fprintf(stderr, "called PerlMotionUIViewController::loadView\n");
	pthread_mutex_lock(&mutex);
	StringObject *s = to_String(new_String("load_view").o);
	UnionType mtd = self.pkg->table[s->hash];
	CodeRefObject *code_ref = NULL;
	if (TYPE(mtd.o) == CodeRef) {
		code_ref = to_CodeRef(mtd.o);
	} else {
		for (size_t i = 0; i < self.pkg->isa->size; i++) {
			PackageObject *base = to_Package(self.pkg->isa->list[i]->o);
			UnionType mtd = base->table[s->hash];
			if (TYPE(mtd.o) == CodeRef) {
				code_ref = to_CodeRef(mtd.o);
				break;
			}
		}
	}
	pthread_mutex_unlock(&mutex);
	if (code_ref) {
		fprintf(stderr, "found overrided method\n");
		Value **list = (Value **)malloc(sizeof(Value *));
		Value *o = (Value *)fetch_object();
		*o = new_FFI("UIViewController", (__bridge_retained void *)self);
		list[0] = o;
		ArrayObject *args = to_Array((new_Array(list, 1)).o);
		fprintf(stderr, "invoke load_view\n");
		code_ref->code(args);
	}
}

@end

UnionType ios_init(ArrayObject *args)
{
	//fprintf(stderr, "called ios_init\n");
	UnionType ret;
	ret.o = INT_init(UIApplicationMain(0, NULL, nil, NSStringFromClass([AppDelegate class])));
	return ret;
}

Value UIApplication_window(ArrayObject *args)
{
	fprintf(stderr, "called UIApplication_window\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIApplication *app = (__bridge UIApplication *)ffi->ptr;
	FFIObject *ffi_window = to_FFI(args->list[1]->o);
	UIWindow *window = (__bridge UIWindow *)ffi_window->ptr;
	AppDelegate *delegate = [app delegate];
	delegate.window = window;
	//TODO
	Value ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIAlertView_new(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_new\n");
	UIAlertView *alert = [UIAlertView alloc];
	UnionType ret = new_FFI("UIAlertView", (__bridge_retained void *)alert);
	return ret;
}

Value UIAlertView_init_with_title(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_init_with_title\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	NSString *ns_title = [NSString stringWithUTF8String: (to_String(args->list[1]->o))->s];
	TYPE_CHECK(args->list[2]->o, HashRef);
	HashRefObject *hash_ref = to_HashRef(args->list[2]->o);
	HashObject *options = to_Hash(hash_ref->v.o);
	StringObject *_message = to_String((new_String("message")).o);
	UnionType message = Hash_get(options, _message);
	NSString *ns_message = [NSString stringWithUTF8String: (to_String(message.o))->s];
	UIAlertView *response = [alert
		initWithTitle:ns_title
		message:ns_message
		delegate:nil
		cancelButtonTitle:nil
		otherButtonTitles:@"OK", nil
	];
	Value ret = new_FFI("UIAlertView", (__bridge_retained void *)response);
	return ret;
}

UnionType UIAlertView_show(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_show\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	[alert show];
	UnionType ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIAlertView_add_button_with_title(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_add_button_with_title\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	char *title = (to_String(args->list[1]->o))->s;
	NSString *ns_title = [NSString stringWithUTF8String: title];
	NSInteger response = [alert addButtonWithTitle:ns_title];
	Value ret;
	ret.o = INT_init(response);
	return ret;
}

Value UIAlertView_button_title_at_index(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_button_title_at_index\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	int index = to_Int(args->list[1]->o);
	NSString *response = [alert buttonTitleAtIndex:index];
	Value ret;
	ret.o = STRING_init([response UTF8String]);
	return ret;
}

Value UIAlertView_dismiss_with_clicked_button_index(ArrayObject *args)
{
	fprintf(stderr, "called UIAlertView_dismiss_with_clicked_button_index\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	int index = to_Int(args->list[1]->o);
	TYPE_CHECK(args->list[2]->o, HashRef);
	HashRefObject *hash_ref = to_HashRef(args->list[2]->o);
	HashObject *options = to_Hash(hash_ref->v.o);
	StringObject *_animated = to_String((new_String("animated")).o);
	UnionType animated = Hash_get(options, _animated);
	BOOL is_animated = (BOOL)to_Int(animated.o);
	[alert dismissWithClickedButtonIndex:index animated:is_animated];
	Value ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIWindow_new(ArrayObject *args)
{
	fprintf(stderr, "called UIWindow_new\n");
	UIWindow *window = [UIWindow alloc];
	Value ret = new_FFI("UIWindow", (__bridge_retained void *)window);
	return ret;
}

Value UIWindow_init_with_frame(ArrayObject *args)
{
	fprintf(stderr, "called UIWindow_init_with_frame\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIWindow *window = (__bridge UIWindow *)ffi->ptr;
	CGRect *rect = (CGRect *)((to_FFI(args->list[1]->o))->ptr);
	UIWindow *new_window = [window initWithFrame:*rect];
	Value ret = new_FFI("UIWindow", (__bridge_retained void *)new_window);
	return ret;
}

Value UIWindow_root_view_controller(ArrayObject *args)
{
	fprintf(stderr, "called UIWindow_root_view_controller\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIWindow *window = (__bridge UIWindow *)ffi->ptr;
	Value ret;
	if (args->size > 1) {
		fprintf(stderr, "set root_view_controller\n");
		UIViewController *view_controller = (__bridge UIViewController *)((to_FFI(args->list[1]->o))->ptr);
		window.rootViewController = view_controller;
		ret = *args->list[1];
	} else {
		fprintf(stderr, "get root_view_controller\n");
		UIViewController *view_controller = window.rootViewController;
		ret = new_FFI("UIViewController", (__bridge_retained void *)view_controller);
	}
	return ret;
}

Value UIWindow_make_key_and_visible(ArrayObject *args)
{
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIWindow *window = (__bridge UIWindow *)ffi->ptr;
	[window makeKeyAndVisible];
	Value ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIScreen_main_screen(ArrayObject *args)
{
	UIScreen *screen = [UIScreen mainScreen];
	Value ret = new_FFI("UIScreen", (__bridge_retained void *)screen);
	return ret;
}

Value UIScreen_bounds(ArrayObject *args)
{
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIScreen *screen = (__bridge UIScreen *)ffi->ptr;
	CGRect rect = [screen bounds];
	CGRect *rect_ptr = (CGRect *)malloc(sizeof(CGRect));
	rect_ptr->origin = rect.origin;
	rect_ptr->size = rect.size;
	Value ret = new_FFI("CGRect", (void *)rect_ptr);
	return ret;
}

Value UIViewController_new(ArrayObject *args)
{
	fprintf(stderr, "called UIViewController_new\n");
	PerlMotionUIViewController *view_controller = [[PerlMotionUIViewController alloc] init];
	char *pkg_name = (to_String(args->list[0]->o))->s;
	fprintf(stderr, "pkg_name = [%s]\n", pkg_name);
	view_controller.pkg = get_pkg(pkg_name);
	Value ret = new_FFI("UIViewController", (__bridge_retained void *)view_controller);
	return ret;
}

Value UIViewController_add_child_view_controller(ArrayObject *args)
{
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIViewController *view_controller = (__bridge UIViewController *)ffi->ptr;
	UIViewController *child_controller = (__bridge UIViewController *)(to_FFI(args->list[1]->o))->ptr;
	[view_controller addChildViewController:child_controller];
	Value ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIViewController_view(ArrayObject *args)
{
	fprintf(stderr, "called UIViewController_view\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIViewController *view_controller = (__bridge UIViewController *)ffi->ptr;
	Value ret;
	if (args->size > 1) {
		fprintf(stderr, "set view\n");
		UIView *view = (__bridge UIView *)((to_FFI(args->list[1]->o))->ptr);
		view_controller.view = view;
		ret = *args->list[1];
	} else {
		fprintf(stderr, "get view\n");
		UIView *view = view_controller.view;
		ret = new_FFI("UIView", (__bridge_retained void *)view);
	}
	return ret;
}

Value UIViewController_wants_full_screen_layout(ArrayObject *args)
{
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIViewController *view_controller = (__bridge UIViewController *)ffi->ptr;
	BOOL is_fullscreen = (BOOL)to_Int(args->list[1]->o);
	view_controller.wantsFullScreenLayout = is_fullscreen;
	Value ret;
	ret.o = INT_init(0);
	return ret;
}

Value UIView_new(ArrayObject *args)
{
	fprintf(stderr, "called UIView_new\n");
	PerlMotionUIView *view = [[PerlMotionUIView alloc] init];
	char *pkg_name = (to_String(args->list[0]->o))->s;
	fprintf(stderr, "pkg_name = [%s]\n", pkg_name);
	view.pkg = get_pkg(pkg_name);
	Value ret = new_FFI("UIView", (__bridge_retained void *)view);
	return ret;
}

Value UIView_background_color(ArrayObject *args)
{
	fprintf(stderr, "called UIView_background_color\n");
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIView *view = (__bridge UIView *)ffi->ptr;
	Value ret;
	if (args->size > 1) {
		fprintf(stderr, "set color\n");
		UIColor *color = (__bridge UIColor *)((to_FFI(args->list[1]->o))->ptr);
		view.backgroundColor = color;
		ret = *args->list[1];
	} else {
		fprintf(stderr, "get color\n");
		UIColor *color = view.backgroundColor;
		ret = new_FFI("UIColor", (__bridge_retained void *)color);
	}
	return ret;
}

Value UIColor_blue_color(ArrayObject *args)
{
	fprintf(stderr, "called UIColor_blue_color\n");
	UIColor *color = [UIColor blueColor];
	Value ret = new_FFI("UIColor", (__bridge_retained void *)color);
	return ret;
}

Value store_ios_native_library(ArrayObject *args)
{
	store_method_by_pkg_name("UIApplication", "window",  UIApplication_window);

	store_method_by_pkg_name("UIAlertView", "new",  UIAlertView_new);
	store_method_by_pkg_name("UIAlertView", "init_with_title",  UIAlertView_init_with_title);
	store_method_by_pkg_name("UIAlertView", "show", UIAlertView_show);
	store_method_by_pkg_name("UIAlertView", "add_button_with_title", UIAlertView_add_button_with_title);
	store_method_by_pkg_name("UIAlertView", "button_title_at_index", UIAlertView_button_title_at_index);
	store_method_by_pkg_name("UIAlertView", "dismiss_with_clicked_button_index", UIAlertView_dismiss_with_clicked_button_index);

	store_method_by_pkg_name("UIScreen", "main_screen",  UIScreen_main_screen);
	store_method_by_pkg_name("UIScreen", "bounds",  UIScreen_bounds);

	store_method_by_pkg_name("UIWindow", "new",  UIWindow_new);
	store_method_by_pkg_name("UIWindow", "init_with_frame",  UIWindow_init_with_frame);
	store_method_by_pkg_name("UIWindow", "root_view_controller",  UIWindow_root_view_controller);
	store_method_by_pkg_name("UIWindow", "make_key_and_visible",  UIWindow_make_key_and_visible);

	store_method_by_pkg_name("UIView", "new",  UIView_new);
	store_method_by_pkg_name("UIView", "background_color",  UIView_background_color);

	store_method_by_pkg_name("UIColor", "blue_color",  UIColor_blue_color);

	store_method_by_pkg_name("UIViewController", "new",  UIViewController_new);
	store_method_by_pkg_name("UIViewController", "view",  UIViewController_view);
	store_method_by_pkg_name("UIViewController", "add_child_view_controller",  UIViewController_add_child_view_controller);
	store_method_by_pkg_name("UIViewController", "wants_full_screen_layout",  UIViewController_wants_full_screen_layout);

	Value ret;
	ret.o = INT_init(0);
	return ret;
}
