@interface PerlMotionUITableViewCell : UITableViewCell

@property PackageObject *pkg;

@end

@implementation PerlMotionUITableViewCell

@end

Value UITaleViewCell_new(ArrayObject *args)
{
	PerlMotionUITableViewCell *cell = [PerlMotionUITableViewCell alloc];
	char *pkg_name = VALUE_TO_CHAR(args->list[0]);
	cell.pkg = get_pkg(pkg_name);
	RETURN(OBJC_PTR_TO_VALUE(UITableViewCell, cell));
}

Value UITableViewCell_init_with_style_reuse_identifier(ArrayObject *args)
{
	UITableViewCell *cell = VALUE_TO_OBJC_PTR(UITableViewCell *, args->list[0]);
	UITableViewCellStyle style = VALUE_PTR_TO_INT(args->list[1]);
	NSString *identifier = VALUE_PTR_TO_NSSTRING(args->list[2]);
	UITableViewCell *new_cell = [cell initWithStyle:style reuseIdentifier:identifier];
	RETURN(OBJC_PTR_TO_VALUE(UITableViewCell, new_cell));
}

Value UITableViewCell_textLabel(ArrayObject *args)
{
	UITableViewCell *cell = VALUE_TO_OBJC_PTR(UITableViewCell *, args->list[0]);
	RETURN(OBJC_PTR_TO_VALUE(UILabel, cell.textLabel));
}

void UITableViewCell_setup(void)
{
	store_method_by_pkg_name("UITableViewCell", "new", UITaleViewCell_new);
	store_method_by_pkg_name("UITableViewCell", "init_with_style_resue_identifier", UITableViewCell_init_with_style_reuse_identifier);
	store_method_by_pkg_name("UITableViewCell", "textLabel", UITableViewCell_textLabel);
}
