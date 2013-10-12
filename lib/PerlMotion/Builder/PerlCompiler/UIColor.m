Value UIColor_new(ArrayObject *args)
{
	DBG_PL("called UIColor_new");
	UIColor *color = [UIColor alloc];
	RETURN(OBJC_PTR_TO_VALUE(UIColor, color));
}

Value UIColor_blue_color(ArrayObject *args)
{
	DBG_PL("called UIColor_blue_color");
	UIColor *color = [UIColor blueColor];
    RETURN(OBJC_PTR_TO_VALUE(UIColor, color));
}

Value UIColor_red_color(ArrayObject *args)
{
	DBG_PL("called UIColor_red_color");
	UIColor *color = [UIColor redColor];
    RETURN(OBJC_PTR_TO_VALUE(UIColor, color));
}

Value UIColor_init_with_pattern_image(ArrayObject *args)
{
	DBG_PL("called UIColor_init_with_pattern_image");
	UIColor *color = VALUE_TO_OBJC_PTR(UIColor *, args->list[0]);
	UIImage *image = VALUE_TO_OBJC_PTR(UIImage *, args->list[1]);
	UIColor *ret = [color initWithPatternImage:image];
    RETURN(OBJC_PTR_TO_VALUE(UIColor, ret));
}

void UIColor_setup(void)
{
	store_method_by_pkg_name("UIColor", "new",  UIColor_new);
	store_method_by_pkg_name("UIColor", "blue_color",  UIColor_blue_color);
    store_method_by_pkg_name("UIColor", "red_color",  UIColor_red_color);
    store_method_by_pkg_name("UIColor", "init_with_pattern_image",  UIColor_init_with_pattern_image);
}
