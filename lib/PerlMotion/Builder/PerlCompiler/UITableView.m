@interface PerlMotionUITableView : UITableView

@property PackageObject *pkg;

@end

@implementation PerlMotionUITableView

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

void UITableView_setup(void)
{
	add_base_name("UITableView", "UIView");
	store_method_by_pkg_name("UITableView", "new", UITableView_new);
	store_method_by_pkg_name("UITableView", "begin_updates", UITableView_begin_updates);
}
