Value UIWindow_new(ArrayObject *args)
{
	DBG_PL("called UIWindow_new");
	UIWindow *window = [UIWindow alloc];
	RETURN(OBJC_PTR_TO_VALUE(UIWindow, window));
}

Value UIWindow_init_with_frame(ArrayObject *args)
{
	DBG_PL("called UIWindow_init_with_frame");
	UIWindow *window = VALUE_TO_OBJC_PTR(UIWindow *, args->list[0]);
	CGRect *rect = VALUE_PTR_TO_PTR(CGRect *, args->list[1]);
	UIWindow *new_window = [window initWithFrame:*rect];
	RETURN(OBJC_PTR_TO_VALUE(UIWindow, new_window));
}

Value UIWindow_root_view_controller(ArrayObject *args)
{
	DBG_PL("called UIWindow_root_view_controller");
	UIWindow *window = VALUE_TO_OBJC_PTR(UIWindow *, args->list[0]);
	Value ret;
	if (args->size > 1) {
		UIViewController *vc = VALUE_TO_OBJC_PTR(UIViewController *, args->list[1]);
		window.rootViewController = vc;
		ret = *args->list[1];
	} else {
		UIViewController *vc = window.rootViewController;
		ret = OBJC_PTR_TO_VALUE(UIViewController, vc);
	}
	RETURN(ret);
}

Value UIWindow_make_key_and_visible(ArrayObject *args)
{
	UIWindow *window = VALUE_TO_OBJC_PTR(UIWindow *, args->list[0]);
	[window makeKeyAndVisible];
	RETURN_VOID();
}

void UIWindow_setup(void)
{
	store_method_by_pkg_name("UIWindow", "new",  UIWindow_new);
	store_method_by_pkg_name("UIWindow", "init_with_frame",  UIWindow_init_with_frame);
	store_method_by_pkg_name("UIWindow", "root_view_controller",  UIWindow_root_view_controller);
	store_method_by_pkg_name("UIWindow", "make_key_and_visible",  UIWindow_make_key_and_visible);
}
