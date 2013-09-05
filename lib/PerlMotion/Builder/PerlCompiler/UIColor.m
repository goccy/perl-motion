Value UIColor_blue_color(ArrayObject *args)
{
	DBG_PL("called UIColor_blue_color");
	UIColor *color = [UIColor blueColor];
    RETURN(OBJC_PTR_TO_VALUE(UIColor, color));
}

void UIColor_setup(void)
{
	store_method_by_pkg_name("UIColor", "blue_color",  UIColor_blue_color);
}
