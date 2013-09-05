@interface PerlMotionUIViewController : UIViewController

@property PackageObject *pkg;

@end

@implementation PerlMotionUIViewController

- (void)loadView
{
	DBG_PL("called PerlMotionUIViewController::loadView");
	CodeRefObject *overrided_load_view = get_overrided_method(self.pkg, "load_view");
	if (overrided_load_view) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *));
		Value *o = (Value *)fetch_object();
		*o = new_FFI("UIViewController", (__bridge_retained void *)self);
		list[0] = o;
		ArrayObject *args = to_Array((new_Array(list, 1)).o);
		DBG_PL("invoke load_view");
		overrided_load_view->code(args);
	}
}

@end

Value UIViewController_new(ArrayObject *args)
{
	DBG_PL("called UIViewController_new");
	PerlMotionUIViewController *view_controller = [[PerlMotionUIViewController alloc] init];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	view_controller.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UIViewController, view_controller));
}

Value UIViewController_add_child_view_controller(ArrayObject *args)
{
	UIViewController *view_controller = VALUE_TO_OBJC_PTR(UIViewController *, args->list[0]);
	UIViewController *child_controller = VALUE_TO_OBJC_PTR(UIViewController *, args->list[1]);
	[view_controller addChildViewController:child_controller];
	RETURN_VOID();
}

Value UIViewController_view(ArrayObject *args)
{
	DBG_PL("called UIViewController_view");
	UIViewController *view_controller = VALUE_TO_OBJC_PTR(UIViewController *, args->list[0]);
	Value ret;
	if (args->size > 1) {
		UIView *view = VALUE_TO_OBJC_PTR(UIView *, args->list[1]);
		view_controller.view = view;
		ret = *args->list[1];
	} else {
		UIView *view = view_controller.view;
		ret = OBJC_PTR_TO_VALUE(UIView, view);
	}
	RETURN(ret);
}

Value UIViewController_wants_full_screen_layout(ArrayObject *args)
{
	UIViewController *view_controller = VALUE_TO_OBJC_PTR(UIViewController *, args->list[0]);
	BOOL is_fullscreen = (BOOL)VALUE_PTR_TO_INT(args->list[1]);
	view_controller.wantsFullScreenLayout = is_fullscreen;
	RETURN_INT(0);
}

void UIViewController_setup(void)
{
	store_method_by_pkg_name("UIViewController", "new",  UIViewController_new);
	store_method_by_pkg_name("UIViewController", "view",  UIViewController_view);
	store_method_by_pkg_name("UIViewController", "add_child_view_controller",  UIViewController_add_child_view_controller);
	store_method_by_pkg_name("UIViewController", "wants_full_screen_layout",  UIViewController_wants_full_screen_layout);
}
