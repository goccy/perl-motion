Value UIImage_image_named(ArrayObject *args)
{
	DBG_PL("called UIImage_image_named");
	NSString *name = VALUE_PTR_TO_NSSTRING(args->list[1]);
	UIImage *image = [UIImage imageNamed:name];
    RETURN(OBJC_PTR_TO_VALUE(UIImage, image));
}

void UIImage_setup(void)
{
	store_method_by_pkg_name("UIImage", "image_named",  UIImage_image_named);
}
