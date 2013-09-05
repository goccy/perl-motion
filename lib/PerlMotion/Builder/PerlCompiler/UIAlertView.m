Value UIAlertView_new(ArrayObject *args)
{
	DBG_PL("called UIAlertView_new");
	UIAlertView *alert = [UIAlertView alloc];
	RETURN(OBJC_PTR_TO_VALUE(UIAlertView, alert));
}

Value UIAlertView_init_with_title(ArrayObject *args)
{
	DBG_PL("called UIAlertView_init_with_title");
	UIAlertView *alert = VALUE_TO_OBJC_PTR(UIAlertView *, args->list[0]);
	NSString *title = VALUE_PTR_TO_NSSTRING(args->list[1]);
	HashObject *options = DEREF_TO_HASH(VALUE_TO_HASHREF(args->list[2]));
	NSString *message = VALUE_TO_NSSTRING(Hash_get_by_char(options, "message"));
	UIAlertView *response = [alert
		initWithTitle:title
		message:message
		delegate:nil
		cancelButtonTitle:nil
		otherButtonTitles:@"OK", nil
	];
	RETURN(OBJC_PTR_TO_VALUE(UIAlertView, response));
}

Value UIAlertView_show(ArrayObject *args)
{
	DBG_PL("called UIAlertView_show");
	UIAlertView *alert = VALUE_TO_OBJC_PTR(UIAlertView *, args->list[0]);
	[alert show];
	RETURN_VOID();
}

Value UIAlertView_add_button_with_title(ArrayObject *args)
{
	DBG_PL("called UIAlertView_add_button_with_title");
	UIAlertView *alert = VALUE_TO_OBJC_PTR(UIAlertView *, args->list[0]);
	NSString *title = VALUE_PTR_TO_NSSTRING(args->list[1]);
	NSInteger response = [alert addButtonWithTitle:title];
	RETURN_INT(response);
}

Value UIAlertView_button_title_at_index(ArrayObject *args)
{
	DBG_PL("called UIAlertView_button_title_at_index");
	UIAlertView *alert = VALUE_TO_OBJC_PTR(UIAlertView *, args->list[0]);
	int index = VALUE_PTR_TO_INT(args->list[1]);
	NSString *response = [alert buttonTitleAtIndex:index];
	RETURN_NSSTRING(response);
}

Value UIAlertView_dismiss_with_clicked_button_index(ArrayObject *args)
{
	DBG_PL("called UIAlertView_dismiss_with_clicked_button_index");
	UIAlertView *alert = VALUE_TO_OBJC_PTR(UIAlertView *, args->list[0]);
	int index = VALUE_PTR_TO_INT(args->list[1]);
	HashObject *options = DEREF_TO_HASH(VALUE_TO_HASHREF(args->list[2]));
	BOOL is_animated = VALUE_TO_INT(Hash_get_by_char(options, "animated"));
	[alert dismissWithClickedButtonIndex:index animated:is_animated];
	RETURN_VOID();
}

void UIAlertView_setup(void)
{
	store_method_by_pkg_name("UIAlertView", "new",  UIAlertView_new);
	store_method_by_pkg_name("UIAlertView", "init_with_title",  UIAlertView_init_with_title);
	store_method_by_pkg_name("UIAlertView", "show", UIAlertView_show);
	store_method_by_pkg_name("UIAlertView", "add_button_with_title", UIAlertView_add_button_with_title);
	store_method_by_pkg_name("UIAlertView", "button_title_at_index", UIAlertView_button_title_at_index);
	store_method_by_pkg_name("UIAlertView", "dismiss_with_clicked_button_index", UIAlertView_dismiss_with_clicked_button_index);
}
