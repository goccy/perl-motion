@interface PerlMotionUIView : UIView

@property PackageObject *pkg;

@end

@implementation PerlMotionUIView

@end

Value UIView_new(ArrayObject *args)
{
	DBG_PL("called UIView_new");
	PerlMotionUIView *view = [[PerlMotionUIView alloc] init];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	view.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UIView, view));
}

Value UIView_background_color(ArrayObject *args)
{
	DBG_PL("called UIView_background_color");
	UIView *view = VALUE_TO_OBJC_PTR(UIView *, args->list[0]);
	Value ret;
	if (args->size > 1) {
		UIColor *color = VALUE_TO_OBJC_PTR(UIColor *, args->list[1]);
		view.backgroundColor = color;
		ret = *args->list[1];
	} else {
		UIColor *color = view.backgroundColor;
		ret = OBJC_PTR_TO_VALUE(UIColor, color);
	}
	RETURN(ret);
}

void UIView_setup(void)
{
	store_method_by_pkg_name("UIView", "new",  UIView_new);
	store_method_by_pkg_name("UIView", "background_color",  UIView_background_color);
}
