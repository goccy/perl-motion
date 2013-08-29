@interface AppDelegate : UIResponder <UIApplicationDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//fprintf(stderr, "called AppDelegate::application\n");
	size_t key_size = pkg_map->size;
	StringObject **keys = pkg_map->keys;
	PackageObject *app_delegate_pkg = NULL;
	for (size_t i = 0; i < key_size; i++) {
		if (!keys[i]) continue;
		PackageObject *pkg = to_Package(pkg_map->table[keys[i]->hash].o);
		ArrayObject *isa = pkg->isa;
		size_t base_size = isa->size;
		for (size_t j = 0; j < base_size; j++) {
			PackageObject *base = to_Package(isa->list[j]->o);
			if (!strncmp(base->name, "AppDelegate", sizeof("AppDelegate"))) {
				app_delegate_pkg = pkg;
				break;
			}
		}
	}
	StringObject *application_method = to_String((new_String("application")).o);
	CodeRefObject *app = to_CodeRef(app_delegate_pkg->table[application_method->hash].o);
	app->code(NULL);
	return YES;
}

@end

UnionType ios_init(ArrayObject *args)
{
	//fprintf(stderr, "called ios_init\n");
	UnionType ret;
	ret.o = INT_init(UIApplicationMain(0, NULL, nil, NSStringFromClass([AppDelegate class])));
	return ret;
}

UnionType UIAlertView_new(ArrayObject *args)
{
	//fprintf(stderr, "called UIAlertView_new\n");
	TYPE_CHECK(args->list[1]->o, HashRef);
	HashRefObject *hash_ref = to_HashRef(args->list[1]->o);
	HashObject *options = to_Hash(hash_ref->v.o);
	StringObject *_title = to_String((new_String("init_with_title")).o);
	UnionType title = Hash_get(options, _title);
	NSString *ns_title = [NSString stringWithUTF8String: (to_String(title.o))->s];
	StringObject *_message = to_String((new_String("message")).o);
	UnionType message = Hash_get(options, _message);
	//fprintf(stderr, "title = [%s]\n", (to_String(title.o))->s);
	//fprintf(stderr, "message = [%s]\n", (to_String(message.o))->s);
	NSString *ns_message = [NSString stringWithUTF8String: (to_String(message.o))->s];
	UIAlertView *alert = [
		[UIAlertView alloc]
		initWithTitle:ns_title
		message:ns_message
		delegate:nil
		cancelButtonTitle:nil
		otherButtonTitles:@"OK", nil
	];
	UnionType ret = new_FFI("UIAlertView", (__bridge_retained void *)alert);
	return ret;
}

UnionType UIAlertView_show(ArrayObject *args)
{
	FFIObject *ffi = to_FFI(args->list[0]->o);
	UIAlertView *alert = (__bridge UIAlertView *)ffi->ptr;
	[alert show];
	UnionType ret;
	ret.o = INT_init(0);
	return ret;
}

UnionType store_ios_native_library(ArrayObject *args)
{
	store_method_by_pkg_name("UIAlertView", "new",  UIAlertView_new);
	store_method_by_pkg_name("UIAlertView", "show", UIAlertView_show);
}
