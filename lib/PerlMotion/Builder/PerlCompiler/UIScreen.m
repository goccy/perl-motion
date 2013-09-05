Value UIScreen_main_screen(ArrayObject *args)
{
	UIScreen *screen = [UIScreen mainScreen];
    RETURN(OBJC_PTR_TO_VALUE(UIScreen, screen));
}

Value UIScreen_bounds(ArrayObject *args)
{
	UIScreen *screen = VALUE_TO_OBJC_PTR(UIScreen *, args->list[0]);
	CGRect rect = [screen bounds];
	CGRect *rect_ptr = (CGRect *)malloc(sizeof(CGRect));
	rect_ptr->origin = rect.origin;
	rect_ptr->size = rect.size;
	RETURN(PTR_TO_VALUE(CGRect, rect_ptr));
}

void UIScreen_setup(void)
{
	store_method_by_pkg_name("UIScreen", "main_screen",  UIScreen_main_screen);
	store_method_by_pkg_name("UIScreen", "bounds",  UIScreen_bounds);
}
