Value NSIndexPath_new(ArrayObject *args)
{
	DBG_PL("called NSIndexPath_new");
	NSIndexPath *indexPath = [[NSIndexPath alloc] init];
	RETURN(OBJC_PTR_TO_VALUE(NSIndexPath, indexPath));
}

Value NSIndexPath_row(ArrayObject *args)
{
	DBG_PL("called NSIndexPath_row");
	NSIndexPath *indexPath = VALUE_TO_OBJC_PTR(NSIndexPath *, args->list[0]);
	NSUInteger row = indexPath.row;
	RETURN_INT(row);
}

void NSIndexPath_setup(void)
{
	store_method_by_pkg_name("NSIndexPath", "new", NSIndexPath_new);
	store_method_by_pkg_name("NSIndexPath", "row", NSIndexPath_row);
}
