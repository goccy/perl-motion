@interface PerlMotionUITableViewController : UITableViewController

@property PackageObject *pkg;

@end

@implementation PerlMotionUITableViewController

- (void)viewDidLoad
{
	DBG_PL("called PerlMotionUITableViewController::viewDidLoad");
	CodeRefObject *overrided_load_view = get_overrided_method(self.pkg, "view_did_load");
	if (overrided_load_view) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *));
		Value *o = (Value *)fetch_object();
		*o = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o;
		ArrayObject *args = to_Array((new_Array(list, 1)).o);
		DBG_PL("invoke view_did_load");
		overrided_load_view->code(args);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	DBG_PL("called PerlMotionUITableViewController::numberOfSectionsInTableView:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "number_of_sections_in_table_view");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*2);
		Value *o1 = (Value *)fetch_object();
		*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
	  	*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		ArrayObject *args = to_Array((new_Array(list, 2)).o);
		DBG_PL("invoke number_of_sections_in_table_view");
		Value ret = overrided->code(args);
		return VALUE_TO_INT(ret);
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	DBG_PL("called PerlMotionUITableViewController::tableView:numberOfRowsInSection:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "table_view_number_of_rows_in_section");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*3);
		Value *o1 = (Value *)fetch_object();
	   	*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
   		*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		Value *o3 = (Value *)fetch_object();
   		(*o3).o = INT_init(section);
		list[2] = o3;
		ArrayObject *args = to_Array((new_Array(list, 3)).o);
		DBG_PL("invoke number_of_rows_in_section");
		Value ret = overrided->code(args);
		return VALUE_TO_INT(ret);
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBG_PL("called PerlMotionUITableViewController::tableView:cellForRowAtIndexPath:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "table_view_cell_for_row_at_index_path");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*3);
		Value *o1 = (Value *)fetch_object();
	   	*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
	   	*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		Value *o3 = (Value *)fetch_object();
	   	*o3 = OBJC_PTR_TO_VALUE(NSIndexPath, indexPath);
		list[2] = o3;
		ArrayObject *args = to_Array((new_Array(list, 3)).o);
		DBG_PL("invoke cell_for_row_at_index_path");
		Value ret = overrided->code(args);
		UITableViewCell *cell = VALUE_TO_OBJC_PTR(UITableViewCell *, ret);
		return cell;
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBG_PL("called PerlMotionUITableViewController::tableView:canEditRowAtIndexPath:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "table_view_can_edit_row_at_index_path");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*3);
		Value *o1 = (Value *)fetch_object();
	  	*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
	   	*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		Value *o3 = (Value *)fetch_object();
	   	*o3 = OBJC_PTR_TO_VALUE(NSIndexPath, indexPath);
		list[2] = o3;
		ArrayObject *args = to_Array((new_Array(list, 3)).o);
		DBG_PL("invoke table_view_can_edit_row_at_index_path");
		Value ret = overrided->code(args);
		return VALUE_TO_INT(ret);
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBG_PL("called PerlMotionUITableViewController::tableView:commitEditingStyle:forRowAtIndexPath:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "table_view_commit_editing_style_for_row_at_index_path");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*4);
		Value *o1 = (Value *)fetch_object();
	  	*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
	   	*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		Value *o3 = (Value *)fetch_object();
	   	(*o3).o = INT_init(editingStyle);
		list[2] = o3;
		Value *o4 = (Value *)fetch_object();
	   	*o4 = OBJC_PTR_TO_VALUE(NSIndexPath, indexPath);
		list[3] = o4;
		ArrayObject *args = to_Array((new_Array(list, 4)).o);
		DBG_PL("invoke table_view_can_edit_row_at_index_path");
		overrided->code(args);
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBG_PL("called PerlMotionUITableViewController::tableView:canMoveRowAtIndexPath:");

	CodeRefObject *overrided = get_overrided_method(self.pkg, "table_can_move_row_at_index_path");
	if (overrided) {
		DBG_PL("found overrided method");
		Value **list = (Value **)malloc(sizeof(Value *)*3);
		Value *o1 = (Value *)fetch_object();
	   	*o1 = OBJC_PTR_TO_VALUE(UITableViewController, self);
		list[0] = o1;
		Value *o2 = (Value *)fetch_object();
   		*o2 = OBJC_PTR_TO_VALUE(UITableView, tableView);
		list[1] = o2;
		Value *o3 = (Value *)fetch_object();
   		*o3 = OBJC_PTR_TO_VALUE(NSIndexPath, indexPath);
		list[2] = o3;
		ArrayObject *args = to_Array((new_Array(list, 3)).o);
		DBG_PL("invoke table_can_move_row_at_index_path");
		Value ret = overrided->code(args);
		return VALUE_TO_INT(ret);
	}
	return NO;
}

@end

Value UITableViewController_new(ArrayObject *args)
{
	DBG_PL("called UITableViewController_new");
	PerlMotionUITableViewController *view_controller = [[PerlMotionUITableViewController alloc] init];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	view_controller.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UITableViewController, view_controller));
}

void UITableViewController_setup(void)
{
	store_method_by_pkg_name("UITableViewController", "new",  UITableViewController_new);
}
