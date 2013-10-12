@interface PerlMotionUIResponder : UIResponder

@property PackageObject *pkg;

@end

@implementation PerlMotionUIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	DBG_PL("called UIResponder_touches_began");
	CodeRefObject *overrided_method = get_overrided_method(self.pkg, "touches_began");
	if (overrided_method) {
		DBG_PL("found overrided method");
		ArrayObject *args = make_array(3);
		*args->list[0] = new_FFI("UIResponder", (__bridge_retained void *)self);
		DBG_PL("invoke touches_began");
		overrided_method->code(args);
	}
}

@end

Value UIResponder_new(ArrayObject *args)
{
	DBG_PL("called UIResponder_new");
	PerlMotionUIResponder *responder = [[PerlMotionUIResponder alloc] init];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	responder.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UIResponder, responder));
}

void UIResponder_setup(void)
{
	store_method_by_pkg_name("UIResponder", "new",  UIResponder_new);
}
