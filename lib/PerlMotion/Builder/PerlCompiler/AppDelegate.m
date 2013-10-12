@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//fprintf(stderr, "called AppDelegate::application\n");
  //pthread_mutex_lock(&mutex);
	size_t key_size = pkg_map->size;
	StringObject **keys = pkg_map->keys;
	PackageObject *app_delegate_pkg = NULL;
	for (size_t i = 0; i < key_size; i++) {
		if (!keys[i]) continue;
		PackageObject *pkg = to_Package(pkg_map->table[keys[i]->hash].o);
		for (size_t j = 0; j < pkg->isa->size; j++) {
			PackageObject *base = to_Package(pkg->isa->list[j]->o);
			if (!strncmp(base->name, "UIApplicationDelegate", sizeof("UIApplicationDelegate"))) {
				app_delegate_pkg = pkg;
				break;
			}
		}
	}
	//pthread_mutex_unlock(&mutex);
	StringObject *application_method = to_String((new_String("application")).o);
	CodeRefObject *app = to_CodeRef(app_delegate_pkg->table[application_method->hash].o);
	fprintf(stderr, "application = [%p]\n", application);
	fprintf(stderr, "app = [%p]\n", app);
	fprintf(stderr, "app->code = [%p]\n", app->code);
	Value **list = (Value **)malloc(sizeof(Value *));
	Value *o = (Value *)fetch_object();
	*o = new_FFI("UIApplication", (__bridge_retained void *)application);
	list[0] = o;
	ArrayObject *args = to_Array((new_Array(list, 1)).o);
	fprintf(stderr, "app? [%p]\n", (to_FFI(args->list[0]->o))->ptr);
	app->code(args);
	return YES;
}

@end
