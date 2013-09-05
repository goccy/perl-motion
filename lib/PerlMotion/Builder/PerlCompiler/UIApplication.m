Value UIApplication_window(ArrayObject *args)
{
	DBG_PL("called UIApplication_window");
	UIApplication *app = VALUE_TO_OBJC_PTR(UIApplication *, args->list[0]);
	Value ret;
	if (args->size > 1) {
		UIWindow *window = VALUE_TO_OBJC_PTR(UIWindow *, args->list[1]);
		AppDelegate *delegate = [app delegate];
		delegate.window = window;
		ret = *args->list[1];
	} else {
		AppDelegate *delegate = [app delegate];
		UIWindow *window = delegate.window;
		ret = OBJC_PTR_TO_VALUE(UIWindow, window);
	}
	RETURN(ret);
}

void UIApplication_setup(void)
{
	store_method_by_pkg_name("UIApplication", "window",  UIApplication_window);
}
