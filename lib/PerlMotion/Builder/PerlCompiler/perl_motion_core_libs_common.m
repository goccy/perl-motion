#include "perl_motion_core_libs.h"
#include "AppDelegate.m"
#include "UITableView.m"
#include "UIView.m"
#include "UIResponder.m"
#include "UIViewController.m"
#include "UIApplication.m"
#include "UIAlertView.m"
#include "UIWindow.m"
#include "UIScreen.m"
#include "UIImage.m"
#include "UIColor.m"

UnionType ios_init(ArrayObject *args)
{
	//fprintf(stderr, "called ios_init\n");
	UnionType ret;
	ret.o = INT_init(UIApplicationMain(0, NULL, nil, NSStringFromClass([AppDelegate class])));
	return ret;
}

CodeRefObject *get_overrided_method(PackageObject *pkg, const char *mtd_name)
{
  //pthread_mutex_lock(&mutex);
	StringObject *s = to_String(new_String((char *)mtd_name).o);
	UnionType mtd = pkg->table[s->hash];
	CodeRefObject *code_ref = NULL;
	if (TYPE(mtd.o) == CodeRef) {
		code_ref = to_CodeRef(mtd.o);
	} else {
		for (size_t i = 0; i < pkg->isa->size; i++) {
			PackageObject *base = to_Package(pkg->isa->list[i]->o);
			UnionType mtd = base->table[s->hash];
			if (TYPE(mtd.o) == CodeRef) {
				code_ref = to_CodeRef(mtd.o);
				break;
			}
		}
	}
	//pthread_mutex_unlock(&mutex);
	return code_ref;
}

ArrayObject *make_array(size_t size)
{
	Value **list = (Value **)malloc(sizeof(Value *) * size);
	for (size_t i = 0; i < size; i++) {
		list[i] = (Value *)fetch_object();
	}
	return to_Array((new_Array(list, size)).o);
}

Value Hash_get_by_char(HashObject *hash, const char *name)
{
	StringObject *key = to_String((new_String((char *)name)).o);
	return Hash_get(hash, key);
}

Value store_ios_native_library(ArrayObject *args)
{
	UIApplication_setup();
	UIAlertView_setup();
	UIScreen_setup();
	UIWindow_setup();
	UIView_setup();
    UIResponder_setup();
	UIViewController_setup();
	UITableView_setup();
	UIImage_setup();
	UIColor_setup();
	Value ret;
	ret.o = INT_init(0);
	return ret;
}
