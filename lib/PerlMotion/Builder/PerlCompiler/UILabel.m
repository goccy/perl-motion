Value UILabel_text(ArrayObject *args)
{
	DBG_PL("called UILabel_text");
	UILabel *textLabel = VALUE_TO_OBJC_PTR(UILabel *, args->list[0]);
	if (args->size == 2) {
		NSString *title = VALUE_PTR_TO_NSSTRING(args->list[1]);
		textLabel.text = title;
		RETURN_VOID();
	} else {
		RETURN_NSSTRING(textLabel.text);
	}
}

void UILabel_setup(void)
{
	store_method_by_pkg_name("UILabel", "text", UILabel_text);
}
