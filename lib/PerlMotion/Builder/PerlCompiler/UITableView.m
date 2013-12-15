@interface PerlMotionUITableView : UITableView

@property PackageObject *pkg;

@end

@implementation PerlMotionUITableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	DBG_PL("called UITableView_touches_began");
	CodeRefObject *overrided_method = get_overrided_method(self.pkg, "touches_began");
	if (overrided_method) {
		DBG_PL("found overrided method");
		ArrayObject *args = make_array(3);
		*args->list[0] = new_FFI("UITableView", (__bridge_retained void *)self);
		DBG_PL("invoke touches_began");
		overrided_method->code(args);
	}
}

@end

Value UITableView_new(ArrayObject *args)
{
	DBG_PL("called UITableView_new");
	PerlMotionUITableView *view = [[PerlMotionUITableView alloc] init];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	view.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UITableView, view));
}

Value UITableView_begin_updates(ArrayObject *args)
{
	DBG_PL("called UITableView_begin_updates");
	UITableView *view = VALUE_TO_OBJC_PTR(UITableView *, args->list[0]);
	[view beginUpdates];
	RETURN_VOID();
}

Value UITableView_dequeue_reusable_cell_with_identifier(ArrayObject *args)
{
	DBG_PL("called UITableView_dequeue_reusable_cell_with_identifier");
	UITableView *view = VALUE_TO_OBJC_PTR(UITableView *, args->list[0]);
	NSString *identifier = VALUE_PTR_TO_NSSTRING(args->list[1]);
	UITableViewCell *cell = [view dequeueReusableCellWithIdentifier:identifier];
	RETURN(OBJC_PTR_TO_VALUE(UITableViewCell, cell));
}

void UITableView_setup(void)
{
	add_base_name("UITableView", "UIView");
	store_method_by_pkg_name("UITableView", "new", UITableView_new);
	store_method_by_pkg_name("UITableView", "begin_updates", UITableView_begin_updates);
	store_method_by_pkg_name("UITableView", "dequeue_reusable_cell_with_identifier", UITableView_dequeue_reusable_cell_with_identifier);
}
