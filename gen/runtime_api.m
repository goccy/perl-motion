#include "runtime_api.h"
#include <math.h>

UnionType u;

UnionType _open(ArrayObject *args)
{
	UnionType ret;
	size_t size = args->size;
	if (size == 3) {
		UnionType *_handler = args->list[0];
		UnionType *_type = args->list[1];
		UnionType *_filename = args->list[2];
		//fprintf(stderr, "handler type = [%llu]\n", TYPE(_handler.o));
		TYPE_CHECK(_type->o, String);
		TYPE_CHECK(_filename->o, String);
		char *io_type = (to_String(_type->o))->s;
		char *filename = (to_String(_filename->o))->s;
		char *mode = "";
		if (!strncmp(io_type, ">", 1)) {
			mode = "w";
		} else if (!strncmp(io_type, "<", 1)) {
			mode = "r";
		}
		FILE *fp = NULL;
		if ((fp = fopen(filename, mode)) == NULL) {
			fprintf(stderr, "ERROR: file open error!!\n");
			exit(EXIT_FAILURE);
		}
		*args->list[0] = new_IOHandler(filename, mode, fp);
	} else {
		fprintf(stderr, "argument size = [%zu]\n", size);
		assert(0 && "Sorry, still not supported");
	}
	ret.o = INT_init(0);
	return ret;
}

UnionType _binmode(ArrayObject *args)
{
	UnionType ret;
	UnionType arg = *args->list[0];
	arg = (TYPE(arg.o) == ObjectType) ? (to_Object(arg.o))->v : arg;
	TYPE_CHECK(arg.o, IOHandler);
	IOHandlerObject *handler = to_IOHandler(arg.o);
	char *mode = NULL;
	if (!strncmp(handler->mode, "r", sizeof("r"))) {
		mode = "rb";
	} else if (!strncmp(handler->mode, "w", sizeof("w"))) {
		mode = "wb";
	}
	handler->fp = freopen(handler->filename, mode, handler->fp);
	if (!handler->fp) {
		fprintf(stderr, "ERROR: could not reopen [%s]\n", handler->filename);
		exit(EXIT_FAILURE);
	}
	ret.o = INT_init(0);
	return ret;
}

UnionType _chr(ArrayObject *args)
{
	UnionType arg = *args->list[0];
	arg = (TYPE(arg.o) == ObjectType) ? (to_Object(arg.o))->v : arg;
	TYPE_CHECK(arg.o, Int);
	int ch = (int)to_Int(arg.o);
	char buf[8] = {0};
	sprintf(buf, "%c", ch);
	UnionType ret = new_String(buf);
	return ret;
}

UnionType _close(ArrayObject *args)
{
	UnionType ret;
	UnionType arg = *args->list[0];
	arg = (TYPE(arg.o) == ObjectType) ? (to_Object(arg.o))->v : arg;
	TYPE_CHECK(arg.o, IOHandler);
	IOHandlerObject *handler = to_IOHandler(arg.o);
	ret.o = INT_init(fclose(handler->fp));
	return ret;
}

UnionType _sqrt(ArrayObject *args)
{
	UnionType ret;
	UnionType arg = *args->list[0];
	arg = (TYPE(arg.o) == ObjectType) ? (to_Object(arg.o))->v : arg;
	ret.d = sqrt(arg.d);
	return ret;
}

UnionType _abs(ArrayObject *args)
{
	UnionType ret;
	UnionType *arg = args->list[0];
	switch (TYPE(arg->o)) {
	case Int:
		ret.o = INT_init(abs((int)to_Int(arg->o)));
		break;
	case Double:
		ret.d = fabs(arg->d);
		break;
	default:
		assert(0 && "Type Error!!! abs's argument");
		break;
	}
	return ret;
}

UnionType _int(ArrayObject *args)
{
	UnionType ret;
	UnionType *arg = args->list[0];
	switch (TYPE(arg->o)) {
	case Int:
		ret.o = arg->o;
		break;
	case Double:
		ret.o = INT_init((int)arg->d);
		break;
	default:
		assert(0 && "Type Error!!! abs's argument");
		break;
	}
	return ret;
}

UnionType _rand(ArrayObject *args)
{
	UnionType ret;
	double random = (double)rand()/(RAND_MAX);
	ret.d = random;
	return ret;
}

UnionType _sin(ArrayObject *args)
{
	UnionType ret;
	UnionType *arg = args->list[0];
	switch (TYPE(arg->o)) {
	case Int:
		ret.d = sin(to_Int(arg->o));
		break;
	case Double:
		ret.d = sin(arg->d);
		break;
	default:
		assert(0 && "Type Error!!! abs's argument");
		break;
	}
	return ret;
}

UnionType _cos(ArrayObject *args)
{
	UnionType ret;
	UnionType *arg = args->list[0];
	switch (TYPE(arg->o)) {
	case Int:
		ret.d = cos(to_Int(arg->o));
		break;
	case Double:
		ret.d = cos(arg->d);
		break;
	default:
		assert(0 && "Type Error!!! abs's argument");
		break;
	}
	return ret;
}

UnionType _atan2(ArrayObject *args)
{
	UnionType ret;
	UnionType *arg1 = args->list[0];
	UnionType *arg2 = args->list[1];
	double d1 = (TYPE(arg1->o) == Int) ? (double)to_Int(arg1->o) : arg1->d;
	double d2 = (TYPE(arg2->o) == Int) ? (double)to_Int(arg2->o) : arg2->d;
	ret.d = atan2(d1, d2);
	return ret;
}

UnionType undef;
void new_Undef(void)
{
	UndefObject *o = (UndefObject *)calloc(sizeof(UndefObject), 1);
	undef.o = UNDEF_init(o);
}

UnionType get_undef_value(void)
{
	return undef;
}

void print_space(size_t indent)
{
	size_t i = 0;
	for (i = 0; i < indent; i++) {
		fprintf(stdout, " ");
	}
}

void print_message(const char *s, size_t indent)
{
	print_space(indent);
	fprintf(stdout, "%s", s);
}

void dump_hash_ref(HashRefObject *ref, size_t indent)
{
	HashObject *hash = to_Hash(ref->v.o);
	size_t key_n = hash->size;
	size_t i = 0;
	fprintf(stdout, "{\n");
	for (i = 0; i < key_n; i++) {
		StringObject *_key = hash->keys[i];
		char *key = _key->s;
		UnionType value = hash->table[_key->hash];
		print_space(indent);
		fprintf(stdout, "  '%s' => ", key);
		dumper(value, indent + _key->len + 7);
		if (i + 1 != key_n) {
			fprintf(stdout, ",\n");
		} else {
			fprintf(stdout, "\n");
		}
	}
	if (indent) {
		print_message("}", indent);
	} else {
		fprintf(stdout, "}");
	}
}

void dump_array_ref(ArrayRefObject *ref, size_t indent)
{
	ArrayObject *array = to_Array(ref->v.o);
	size_t size = array->size;
	size_t i = 0;
	fprintf(stdout, "[\n");
	for (i = 0; i < size; i++) {
		UnionType value = *array->list[i];
		print_space(indent + 2);
		dumper(value, indent + 2);
		if (i + 1 != size) {
			fprintf(stdout, ",\n");
		} else {
			fprintf(stdout, "\n");
		}
	}
	if (indent) {
		print_message("]", indent);
	} else {
		fprintf(stdout, "]");
	}
}

void dump_string(StringObject *o)
{
	fprintf(stdout, "'%s'", o->s);
}

void dumper(UnionType o, size_t indent)
{
	switch (TYPE(o.o)) {
	case Int: case Double:
		print_object(stdout, o);
		break;
	case String:
		dump_string(to_String(o.o));
		break;
	case HashRef:
		dump_hash_ref(to_HashRef(o.o), indent);
		break;
	case ArrayRef:
		dump_array_ref(to_ArrayRef(o.o), indent);
		break;
	case Undefined:
		fprintf(stdout, "undef");
		break;
	default:
		break;
	}
}

UnionType Object_dumper(ArrayObject *a)
{
	UnionType ret;
	if (a->size > 0) {
		dumper(*a->list[0], 0);
	}
	ret.o = INT_init(0);
	return ret;
}

void print_object(FILE *fp, UnionType o)
{
	if (!fp) fp = stdout;
	//fprintf(stderr, "type = [%d]\n", TYPE(o));
	switch (TYPE(o.o)) {
	case Int:
		fprintf(fp, "%d", to_Int(o.o));
		break;
	case Double:
		fprintf(fp, "%f", o.d);
		break;
	case String:
		fprintf(fp, "%s", (to_String(o.o))->s);
		break;
	case Array:
		if (fp != stdout) {
			_print_with_handler(fp, to_Array(o.o));
		} else {
			print(to_Array(o.o));
		}
		break;
	case ArrayRef:
#ifdef __IOS_SIMULATOR__
		fprintf(fp, "ARRAY(%p)", to_Ptr(o.o));
#else
		fprintf(fp, "ARRAY(%p)", o.o);
#endif
		break;
	case Hash:
		print_hash(fp, to_Hash(o.o));
		break;
	case HashRef:
#ifdef __IOS_SIMULATOR__
		fprintf(fp, "HASH(%p)", to_Ptr(o.o));
#else
		fprintf(fp, "HASH(%p)", o.o);
#endif
		break;
	case CodeRef:
#ifdef __IOS_SIMULATOR__
		fprintf(fp, "CODE(%p)", to_Ptr(o.o));
#else
		fprintf(fp, "CODE(%p)", o.o);
#endif
		break;
	case ObjectType: {
		Object *object = to_Object(o.o);
		print_object(fp, object->v);
		break;
	}
	case BlessedObjectType:
#ifdef __IOS_SIMULATOR__
		fprintf(fp, "%s=HASH(%p)", (to_BlessedObject(o.o))->pkg_name, to_Ptr(o.o));
#else
		fprintf(fp, "%s=HASH(%p)", (to_BlessedObject(o.o))->pkg_name, o.o);
#endif
		break;
	default:
		break;
	}
}

void print_hash(FILE *fp, HashObject *hash)
{
	size_t key_n = hash->size;
	size_t i = 0;
	for (i = 0; i < key_n; i++) {
		StringObject *key = hash->keys[i];
		fprintf(fp, "%s", key->s);
		print_object(fp, hash->table[key->hash]);
	}
}

UnionType print(ArrayObject *array)
{
	UnionType ret;
	size_t size = array->size;
	size_t i = 0;
	for (i = 0; i < size; i++) {
		print_object(stdout, *array->list[i]);
	}
	ret.o = INT_init(0);
	return ret;
}

void _print_with_handler(FILE *fp, ArrayObject *array)
{
	size_t size = array->size;
	for (size_t i = 0; i < size; i++) {
		print_object(fp, *array->list[i]);
	}
}

UnionType print_with_handler(UnionType *_handler, ArrayObject *array)
{
	//fprintf(stderr, "called print_with_handler\n");
	//fprintf(stderr, "handler type = [%llu]\n", TYPE(_handler->o));
	UnionType ret;
	FILE *fp = (to_IOHandler(_handler->o))->fp;
	_print_with_handler(fp, array);
	ret.o = INT_init(0);
	return ret;
}

UnionType say(ArrayObject *array)
{
	UnionType ret;
	print(array);
	fprintf(stdout, "\n");
	ret.o = INT_init(0);
	return ret;
}

void debug_print(UnionType o)
{
	fprintf(stderr, "===== debug_print ======\n");
	print_object(stdout, o);
	fprintf(stderr, "=============\n");
}

UnionType shift(ArrayObject *args)
{
	UnionType ret;
	size_t size = args->size;
	if (size > 1) return ret;
	if (size == 1) {
		UnionType o = *args->list[0];
		TYPE_CHECK(o.o, Array);
		ArrayObject *array = to_Array(o.o);
		ret = *array->list[0];
		array->size--;
		memmove(array->list, array->list + 1, array->size * sizeof(Value));
	} else {
		fprintf(stderr, "fetch from function argument\n");
	}
	return ret;
}

void Array_grow(ArrayObject *array, size_t grow_size)
{
	void *tmp;
	size_t size = array->size;
	if (!(tmp = malloc(sizeof(Value *) * grow_size))) {
		fprintf(stderr, "ERROR!!: cannot allocated memory\n");
	} else {
		if (array->list) memcpy(tmp, array->list, sizeof(Value *) * size);
		array->list = (UnionType **)tmp;
		for (int i = size; i <= grow_size; i++) {
			//fprintf(stderr, "undef type = [%d]\n", TYPE(undef.o));
			UnionType *undef_ptr = (UnionType *)fetch_object();
			undef_ptr->o = undef.o;
			array->list[i] = undef_ptr;
			//array->list[i] = &undef;
		}
		array->size = grow_size;
	}
}

UnionType push(ArrayObject *args)
{
	size_t size = args->size;
	UnionType ret;
	if (size != 2) {
		fprintf(stderr, "Type Error!: near by push\n");
	} else {
		UnionType *array = args->list[0];
		UnionType *value = args->list[1];
		TYPE_CHECK(array->o, Array);
		ArrayObject *base = to_Array(array->o);
		Array_grow(base, base->size + 1);
		base->list[base->size] = value;
		base->size++;
		ret.o = INT_init(base->size);
	}
	return ret;
}

UnionType new_IOHandler(const char *filename, const char *mode, FILE *fp)
{
	UnionType ret;
	IOHandlerObject *o = (IOHandlerObject *)fetch_object();
	o->fp = fp;
	o->mode = mode;
	o->filename = filename;
	ret.o = IO_HANDLER_init(o);
	return ret;
}

UnionType new_HashRef(UnionType hash)
{
	UnionType ret;
	HashRefObject *o = (HashRefObject *)fetch_object();
	o->v = hash;
	ret.o = HASH_REF_init(o);
	return ret;
}

UnionType new_ArrayRef(UnionType array)
{
	UnionType ret;
	ArrayRefObject *o = (ArrayRefObject *)fetch_object();
	o->v = array;
	ret.o = ARRAY_REF_init(o);
	return ret;
}

UnionType *HashRef_get(UnionType *o, StringObject *key)
{
	UnionType *ret = &undef;
	switch (TYPE(o->o)) {
	case HashRef: {
		HashRefObject *ref = to_HashRef(o->o);
		HashObject *hash = to_Hash(ref->v.o);
		ret = &hash->table[key->hash];
		break;
	}
	case ObjectType: case BlessedObjectType: {
		HashRefObject *ref = dynamic_hash_ref_cast_code(o);
		HashObject *hash = to_Hash(ref->v.o);
		ret = &hash->table[key->hash];
		break;
	}
	case Int: case Double: case Undefined: {
		// auto vivification
		ArrayObject array;
		array.size = 0;
		array.list = NULL;
		UnionType hash_ref = new_HashRef(new_Hash(&array));
		o->o = hash_ref.o;
		HashRefObject *ref = to_HashRef(hash_ref.o);
		HashObject *hash = to_Hash(ref->v.o);
		hash->keys[0] = key;
		hash->size = 1;
		ret = &hash->table[key->hash];
		break;
	}
	default:
		fprintf(stderr, "type = [%llu]\n", TYPE(o->o));
		assert(0 && "Type Error!: Unknown Type");
		break;
	}
	return ret;
}

void Array_add(ArrayObject *array, UnionType *elem)
{
	size_t size = array->size;
	Array_grow(array, size + 1);
	array->list[size] = elem;
}

UnionType *Array_get(ArrayObject *array, int idx)
{
	size_t size = array->size;
	if (size <= idx) {
		Array_grow(array, idx + 1);
	}
	return array->list[idx];
}

UnionType *ArrayRef_get(UnionType *o, int idx)
{
	UnionType *ret = &undef;
	switch (TYPE(o->o)) {
	case ArrayRef: {
		ArrayRefObject *ref = to_ArrayRef(o->o);
		ArrayObject *array = to_Array(ref->v.o);
		ret = Array_get(array, idx);
		break;
	}
	case ObjectType: {
		ArrayRefObject *ref = dynamic_array_ref_cast_code(o);
		ArrayObject *array = to_Array(ref->v.o);
		ret = Array_get(array, idx);
		break;
	}
	case Int: case Double: case Undefined: {
		// auto vivification
		//fprintf(stderr, "auto vivification\n");
		UnionType boxed_array = new_Array(NULL, 0);
		UnionType array_ref = new_ArrayRef(boxed_array);
		//o->o = array_ref.o;
		*o = array_ref;
		ArrayObject *array = to_Array(boxed_array.o);
		//fprintf(stderr, "idx = [%d]\n", idx);
		//fprintf(stderr, "size = [%d]\n", array->size);
		//fprintf(stderr, "list = [%p]\n", array->list);
		//say(array);
		ret = Array_get(array, idx);
		//fprintf(stderr, "array->size = [%d]\n", array->size);
		//say(array);
		break;
	}
	default:
		fprintf(stderr, "type = [%llu]\n", TYPE(o->o));
		assert(0 && "Type Error!: Unknown Type");
		break;
	}
	return ret;
}

void Array_set(ArrayObject *array, int idx, UnionType elem)
{
	size_t size = array->size;
	if (size <= idx) Array_grow(array, idx + 1);
	array->list[idx] = &elem;
}


//Object *map(ArrayObject *args)
//{
//	Object *block = args->list[0];
//	Object *array = args->list[1];
//	Object *ret;
//	for (i = 0; i < size; i++) {
//		Object *map_arg = array->list[0];
//		Function *map_func = (Function *)block->o.value;
//		ret->list[i] = map_func(map_arg);
//	}
//	ret->type = Array;
//	ret->v.ovalue = mapped_array;
//	return ret;
//}

UnionType *base_hash_table;
void init_table(void)
{
	UnionType *table = (UnionType *)calloc(sizeof(UnionType), HASH_TABLE_SIZE);
	size_t i;
	for (i = 0; i < HASH_TABLE_SIZE; i++) {
		table[i] = undef;
	}
	base_hash_table = table;
}

HashObject *pkg_map;

void init_package_map(void)
{
	HashObject *hash = (HashObject *)calloc(sizeof(HashObject), 1);
	hash->table = (UnionType *)calloc(sizeof(UnionType), HASH_TABLE_SIZE);
	memcpy(hash->table, base_hash_table, sizeof(UnionType) * HASH_TABLE_SIZE);
	hash->keys = (StringObject **)calloc(sizeof(void *), HASH_TABLE_SIZE);
	pkg_map = hash;
}

void global_init(void)
{
	new_Undef();
	init_table();
	init_package_map();
	make_object_pool();
}

unsigned long make_hash(char* _str, size_t len)
{
	char* str = _str;
	unsigned long hash = 5381;
	while (len--) {
		hash = ((hash << 5) + hash) + *str++;
	}
	return hash;
}

UnionType new_String(char *str)
{
	UnionType ret;
	//fprintf(stderr, "str = [%s]\n", str);
	StringObject *o = (StringObject *)calloc(sizeof(StringObject), 1);
	o->header = String;
	o->len = strlen(str) + 1;
	//o->s = str;
	o->s = (char *)malloc(o->len);
	memcpy(o->s, str, o->len);
	o->hash = make_hash(str, o->len) % HASH_TABLE_SIZE;
	ret.o = STRING_init(o);
	return ret;
}

void _unshift(ArrayObject *base, char *pkg_name)
{
	UnionType **tmp;
	if (!(tmp = malloc(sizeof(Value *) * (base->size + 1)))) {
		fprintf(stderr, "ERROR!!: cannot allocated memory\n");
	} else {
		memcpy(tmp + 1, base->list, base->size * sizeof(Value *));
		base->list = tmp;
		UnionType *class_o = (UnionType *)fetch_object();
		class_o->o = new_String(pkg_name).o;
		base->list[0] = class_o;
		base->size++;
	}
}

void _make_method_argument(ArrayObject *base, BlessedObject *self)
{
	//fprintf(stderr, "call _make_method_argument\n");
	UnionType **tmp;
	if (!(tmp = malloc(sizeof(Value *) * (base->size + 1)))) {
		fprintf(stderr, "ERROR!!: cannot allocated memory\n");
	} else {
		memcpy(tmp + 1, base->list, base->size * sizeof(Value *));
		base->list = tmp;
		UnionType *elem = (UnionType *)fetch_object();
		elem->o = BLESSED_OBJECT_init(self);
		base->list[0] = elem;
		base->size++;
	}
}

void Hash_add(HashObject *hash, StringObject *key, UnionType elem)
{
	size_t size = hash->size;
	hash->table[key->hash] = elem;
	hash->keys[size + 1] = key;
	hash->size++;
}

UnionType Hash_get(HashObject *hash, StringObject *key)
{
	return hash->table[key->hash];
}

UnionType bless(ArrayObject *args)
{
	UnionType ret;
	if (args->size != 2) {
		fprintf(stderr, "ERROR!: bless function must be required two argument\n");
	}
	UnionType self = *args->list[0];
	UnionType class = *args->list[1];
	BlessedObject *blessed = (BlessedObject *)calloc(sizeof(BlessedObject), 1);
	TYPE_CHECK(self.o, HashRef);
	class = (TYPE(class.o) == ObjectType) ? (to_Object(class.o))->v : class;
	TYPE_CHECK(class.o, String);
	const char *pkg_name = (const char *)(to_String(class.o))->s;
	HashRefObject *hash_ref = to_HashRef(self.o);
	HashObject *hash = to_Hash(hash_ref->v.o);
	//fprintf(stderr, "table = [%p]\n", hash->table);
	//fprintf(stderr, "hash_ref = [%p]\n", hash_ref);
	blessed->members = self;
	blessed->pkg_name = pkg_name;
	PackageObject *pkg = get_pkg((char *)pkg_name);
	//UnionType s = new_String((char *)pkg_name);
	//UnionType mtds = Hash_get(pkg_map, to_String(s.o));
	assert (pkg && "unknown package name");
	blessed->mtds = pkg;
	ret.o = BLESSED_OBJECT_init(blessed);
	return ret;
}

int count = 0;
Object **object_pool;
void make_object_pool(void)
{
	size_t size = 4096 * 128;
	object_pool = (Object **)calloc(sizeof(Object *), size);
	for (size_t i = 0; i < size; i++) {
		object_pool[i] = (Object *)calloc(sizeof(Object), 1);
	}
}

Object *fetch_object(void)
{
	count++;
	return (Object *)object_pool[count];
}

PackageObject *get_pkg(char *pkg_name)
{
	PackageObject *ret = NULL;
	UnionType _key = new_String(pkg_name);
	StringObject *key = to_String(_key.o);
	UnionType _pkg = Hash_get(pkg_map, key);
	if (TYPE(_pkg.o) == Package) return to_Package(_pkg.o);
	PackageObject *pkg = (PackageObject *)calloc(sizeof(PackageObject), 1);
	pkg->table = (UnionType *)calloc(sizeof(UnionType), HASH_TABLE_SIZE);
	memcpy(pkg->table, base_hash_table, sizeof(UnionType) * HASH_TABLE_SIZE);
	pkg->keys = (StringObject **)calloc(sizeof(void *), HASH_TABLE_SIZE);
	pkg->isa = to_Array((new_Array(NULL, 0)).o);
	pkg->name = pkg_name;
	UnionType value;
	value.o = PACKAGE_init(pkg);
	Hash_add(pkg_map, key, value);
	return pkg;
}

void store_method_by_pkg_name(char *pkg_name, char *mtd_name, Code code)
{
	PackageObject *pkg = get_pkg(pkg_name);
	UnionType _mtd_name = new_String(mtd_name);
	CodeRefObject *o = (CodeRefObject *)calloc(sizeof(CodeRefObject), 1);
	o->code = code;
	UnionType code_ref;
	code_ref.o = CODE_REF_init(o);
	Hash_add((HashObject *)pkg, to_String(_mtd_name.o), code_ref);
}

Code get_method_by_name(BlessedObject *self, char *mtd_name)
{
	//fprintf(stderr, "call get_method_by_name\n");
	PackageObject *mtds = self->mtds;
	UnionType str = new_String(mtd_name);
	StringObject *s = to_String(str.o);
	UnionType mtd = mtds->table[s->hash];
	CodeRefObject *code_ref = NULL;
	if (TYPE(mtd.o) == CodeRef) {
		code_ref = to_CodeRef(mtd.o);
	} else {
		ArrayObject *isa = mtds->isa;
		size_t size = isa->size;
		for (size_t i = 0; i < size; i++) {
			PackageObject *base = to_Package(isa->list[i]->o);
			UnionType mtd = base->table[s->hash];
			if (TYPE(mtd.o) == CodeRef) {
				code_ref = to_CodeRef(mtd.o);
				break;
			}
		}
	}
	assert(code_ref && "cannot find method");
	return code_ref->code;
}

Code get_class_method_by_name(char *pkg_name, char *mtd_name)
{
	PackageObject *pkg = get_pkg(pkg_name);
	UnionType str = new_String(mtd_name);
	StringObject *s = to_String(str.o);
	UnionType mtd = pkg->table[s->hash];
	CodeRefObject *code_ref = to_CodeRef(mtd.o);
	assert(code_ref && "cannot find method");
	return code_ref->code;
}

void add_base_name(char *pkg_name, char *base_name)
{
	PackageObject *pkg = get_pkg(pkg_name);
	PackageObject *base = get_pkg(base_name);
	UnionType *boxed_base = (UnionType *)fetch_object();
	boxed_base->o = PACKAGE_init(base);
	Array_add(pkg->isa, boxed_base);
}

UnionType new_Array(UnionType **list, size_t size)
{
	UnionType ret;
	ArrayObject *array = (ArrayObject *)fetch_object();
	array->list = list;
	array->size = size;
	ret.o = ARRAY_init(array);
	return ret;
}

UnionType new_Hash(ArrayObject *array)
{
	UnionType ret;
	HashObject *hash = (HashObject *)calloc(sizeof(HashObject), 1);
	hash->table = (UnionType *)calloc(sizeof(UnionType), HASH_TABLE_SIZE);
	memcpy(hash->table, base_hash_table, sizeof(UnionType) * HASH_TABLE_SIZE);
	hash->keys = (StringObject **)calloc(sizeof(void *), HASH_TABLE_SIZE);
	size_t size = array->size;
	int key_n = 0;
	size_t i = 0;
	UnionType **list = array->list;
	for (i = 0; i < size; i += 2, key_n++) {
		StringObject *key = to_String(list[i]->o);
		hash->keys[key_n] = key;
		UnionType *value = (i + 1 < size) ? list[i + 1] : NULL;
		if (!value) continue;
		if (TYPE(value->o) == ObjectType) {
			//Object is allocated stack.
			//must be cast
			Object *o = to_Object(value->o);
			value = &(o->v);
		}
		if (TYPE(value->o) == Double) {
			hash->table[key->hash].d = value->d;
		} else {
			hash->table[key->hash].o = value->o;
		}
	}
	hash->size = key_n;
	ret.o = HASH_init(hash);
	return ret;
}

UnionType Hash_to_array(HashObject *hash)
{
	UnionType ret;
	ArrayObject *array = (ArrayObject *)calloc(sizeof(ArrayObject), 1);
	size_t key_n = hash->size;
	size_t array_size = key_n * 2;
	array->list = (UnionType **)calloc(sizeof(UnionType), array_size);
	array->size = array_size;
	size_t i = 0;
	for (i = 0; i < key_n; i++) {
		StringObject *key = hash->keys[i];
		UnionType *boxed_key = (UnionType *)fetch_object();
		boxed_key->o = STRING_init(key);
		array->list[i * 2] = boxed_key;
		array->list[i * 2 + 1] = &hash->table[key->hash];
	}
	ret.o = ARRAY_init(array);
	return ret;
}

HashRefObject *dynamic_hash_ref_cast_code(UnionType *o)
{
	HashRefObject *ret = NULL;
	//fprintf(stderr, "type = [%d]\n", TYPE(o->o));
	switch (TYPE(o->o)) {
	case HashRef:
		ret = to_HashRef(o->o);
		break;
	case ObjectType: {
		Object *object = to_Object(o->o);
		ret = dynamic_hash_ref_cast_code(&object->v);
		break;
	}
	case BlessedObjectType: {
		BlessedObject *blessed = to_BlessedObject(o->o);
		ret = to_HashRef(blessed->members.o);
		//HashObject *hash = to_Hash(ret->v.o);
		//print_hash(hash);
		//fprintf(stdout, "\n");
		break;
	}
	default:
		fprintf(stderr, "type = [%llu]\n", TYPE(o->o));
		break;
	}
	return ret;
}

ArrayRefObject *dynamic_array_ref_cast_code(UnionType *o)
{
	ArrayRefObject *ret = NULL;
	//fprintf(stderr, "type = [%d]\n", TYPE(o->o));
	switch (TYPE(o->o)) {
	case ArrayRef:
		ret = to_ArrayRef(o->o);
		break;
	case ObjectType: {
		Object *object = to_Object(o->o);
		ret = dynamic_array_ref_cast_code(&object->v);
		break;
	}
	default:
		fprintf(stderr, "type = [%llu]\n", TYPE(o->o));
		break;
	}
	return ret;
}

BlessedObject *dynamic_blessed_object_cast_code(UnionType *o)
{
	BlessedObject *ret = NULL;
	//fprintf(stderr, "type = [%d]\n", TYPE(o->o));
	switch (TYPE(o->o)) {
	case ObjectType: {
		Object *object = to_Object(o->o);
		TYPE_CHECK(object->v.o, BlessedObjectType);
		ret = to_BlessedObject(object->v.o);
		break;
	}
	case BlessedObjectType: {
		ret = to_BlessedObject(o->o);
		break;
	}
	default:
		fprintf(stderr, "type = [%llu]\n", TYPE(o->o));
		break;
	}
	return ret;
}

Object *new_Object(void)
{
	return (Object *)malloc(sizeof(Object));
}

UnionType Object_addObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setResultByObjectObject(ret, a, b, +);
	return ret;
}

UnionType Object_subObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setResultByObjectObject(ret, a, b, -);
	return ret;
}

UnionType Object_mulObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setResultByObjectObject(ret, a, b, *);
	return ret;
}

UnionType Object_divObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setResultByObjectObject(ret, a, b, /);
	return ret;
}

UnionType Object_eqObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setCmpResultByObjectObject(ret, a, b, ==);
	return ret;
}

UnionType Object_neObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setCmpResultByObjectObject(ret, a, b, !=);
	return ret;
}

UnionType Object_gtObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setCmpResultByObjectObject(ret, a, b, >);
	return ret;
}

UnionType Object_ltObject(UnionType *a, UnionType *b)
{
	UnionType ret;
	setCmpResultByObjectObject(ret, a, b, <);
	return ret;
}

UnionType Object_addInt(UnionType *a, int b)
{
	UnionType ret;
	setResultByObjectInt(ret, a, b, +);
	return ret;
}

UnionType Object_subInt(UnionType *a, int b)
{
	UnionType ret;
	setResultByObjectInt(ret, a, b, -);
	return ret;
}

UnionType Object_mulInt(UnionType *a, int b)
{
	UnionType ret;
	setResultByObjectInt(ret, a, b, *);
	return ret;
}

UnionType Object_divInt(UnionType *a, int b)
{
	UnionType ret;
	setResultByObjectInt(ret, a, b, /);
	return ret;
}

UnionType Object_eqInt(UnionType *a, int b)
{
	UnionType ret;
	setCmpResultByObjectInt(ret, a, b, ==);
	return ret;
}

UnionType Object_neInt(UnionType *a, int b)
{
	UnionType ret;
	setCmpResultByObjectInt(ret, a, b, !=);
	return ret;
}

UnionType Object_gtInt(UnionType *a, int b)
{
	UnionType ret;
	setCmpResultByObjectInt(ret, a, b, >);
	return ret;
}

UnionType Object_ltInt(UnionType *a, int b)
{
	UnionType ret;
	setCmpResultByObjectInt(ret, a, b, <);
	return ret;
}

UnionType Object_addInt2(int a, UnionType *b)
{
	UnionType ret;
	setResultByIntObject(ret, a, b, +);
	return ret;
}

UnionType Object_subInt2(int a, UnionType *b)
{
	UnionType ret;
	setResultByIntObject(ret, a, b, -);
	return ret;
}

UnionType Object_mulInt2(int a, UnionType *b)
{
	UnionType ret;
	setResultByIntObject(ret, a, b, *);
	return ret;
}

UnionType Object_divInt2(int a, UnionType *b)
{
	UnionType ret;
	setResultByIntObject(ret, a, b, /);
	return ret;
}

UnionType Object_eqInt2(int a, UnionType *b)
{
	UnionType ret;
	setCmpResultByIntObject(ret, a, b, ==);
	return ret;
}

UnionType Object_neInt2(int a, UnionType *b)
{
	UnionType ret;
	setCmpResultByIntObject(ret, a, b, !=);
	return ret;
}

UnionType Object_gtInt2(int a, UnionType *b)
{
	UnionType ret;
	setCmpResultByIntObject(ret, a, b, >);
	return ret;
}

UnionType Object_ltInt2(int a, UnionType *b)
{
	UnionType ret;
	setCmpResultByIntObject(ret, a, b, <);
	return ret;
}

UnionType Object_addDouble(UnionType *a, double b)
{
	UnionType ret;
	setResultByObjectDouble(ret, a, b, +);
	return ret;
}

UnionType Object_subDouble(UnionType *a, double b)
{
	UnionType ret;
	setResultByObjectDouble(ret, a, b, -);
	return ret;
}

UnionType Object_mulDouble(UnionType *a, double b)
{
	UnionType ret;
	setResultByObjectDouble(ret, a, b, *);
	return ret;
}

UnionType Object_divDouble(UnionType *a, double b)
{
	UnionType ret;
	setResultByObjectDouble(ret, a, b, /);
	return ret;
}

UnionType Object_eqDouble(UnionType *a, double b)
{
	UnionType ret;
	setCmpResultByObjectDouble(ret, a, b, ==);
	return ret;
}

UnionType Object_neDouble(UnionType *a, double b)
{
	UnionType ret;
	setCmpResultByObjectDouble(ret, a, b, !=);
	return ret;
}

UnionType Object_gtDouble(UnionType *a, double b)
{
	UnionType ret;
	setCmpResultByObjectDouble(ret, a, b, >);
	return ret;
}

UnionType Object_ltDouble(UnionType *a, double b)
{
	UnionType ret;
	setCmpResultByObjectDouble(ret, a, b, <);
	return ret;
}

UnionType Object_addDouble2(double a, UnionType *b)
{
	UnionType ret;
	setResultByDoubleObject(ret, a, b, +);
	return ret;
}

UnionType Object_subDouble2(double a, UnionType *b)
{
	UnionType ret;
	setResultByDoubleObject(ret, a, b, +);
	return ret;
}

UnionType Object_mulDouble2(double a, UnionType *b)
{
	UnionType ret;
	setResultByDoubleObject(ret, a, b, *);
	return ret;
}

UnionType Object_divDouble2(double a, UnionType *b)
{
	UnionType ret;
	setResultByDoubleObject(ret, a, b, /);
	return ret;
}

UnionType Object_eqDouble2(double a, UnionType *b)
{
	UnionType ret;
	setCmpResultByDoubleObject(ret, a, b, ==);
	return ret;
}

UnionType Object_neDouble2(double a, UnionType *b)
{
	UnionType ret;
	setCmpResultByDoubleObject(ret, a, b, !=);
	return ret;
}

UnionType Object_gtDouble2(double a, UnionType *b)
{
	UnionType ret;
	setCmpResultByDoubleObject(ret, a, b, >);
	return ret;
}

UnionType Object_ltDouble2(double a, UnionType *b)
{
	UnionType ret;
	setCmpResultByDoubleObject(ret, a, b, <);
	return ret;
}

int Object_isTrue(UnionType a)
{
	int ret = 0;
	void *o = a.o;
	switch (TYPE(o)) {
	case Int:
		ret = ((int)to_Int(o) != 0);
		break;
	case Double:
		ret = (a.d != 0);
		break;
	default:
		break;
	}
	return ret;
}

int Value_isTrue(UnionType *a)
{
	int ret = 0;
	switch (TYPE(a->o)) {
	case Int:
		ret = ((int)to_Int(a->o) != 0);
		break;
	case Double:
		ret = (a->d != 0);
		break;
	default:
		break;
	}
	return ret;
}

char *int_to_string(int v)
{
	char buf[256] = {0};
	snprintf(buf, 256, "%d", v);
	size_t len = strlen(buf) + 1;
	char *ret = (char *)malloc(len);
	memcpy(ret, buf, len);
	return ret;
}

char *double_to_string(double v)
{
	char buf[256] = {0};
	snprintf(buf, 256, "%f", v);
	size_t len = strlen(buf) + 1;
	char *ret = (char *)malloc(len);
	memcpy(ret, buf, len);
	return ret;
}

UnionType expandVariable(const char *fmt, ...)
{
	fprintf(stderr, "called expandVariable\n");
	const char* p;
	va_list args;
	va_start(args, fmt);
	size_t fmt_len = strlen(fmt);
	size_t arg_num = 0;
	for (p = fmt; *p != '\0'; p++) {
		if (*p == '%' && *(p+1) == 's') arg_num++;
	}
	char *vars[arg_num];
	size_t i = 0;
	size_t all_length = 0;
	for (p = fmt; *p != '\0'; p++) {
		if (*p == '%' && *(p+1) == 's') {
			UnionType *arg = va_arg(args, UnionType *);
			char *str = NULL;
			switch (TYPE(arg->o)) {
			case Int:
				str = int_to_string(to_Int(arg->o));
				break;
			case Double:
				str = double_to_string(arg->d);
				break;
			case String:
				str = (to_String(arg->o))->s;
				break;
			case Array:
				break;
			default:
				break;
			}
			vars[i] = str;
			all_length += strlen(str);
			p++;
		} else {
			all_length++;
		}
	}
	char buf[all_length];
	i = 0;
	size_t k = 0;
	for (p = fmt; *p != '\0'; p++) {
		if (*p == '%' && *(p+1) == 's') {
			char *s = vars[i];
			size_t len = strlen(s);
			for (size_t j = 0; j < len; j++) {
				buf[i] = s[j];
				i++;
			}
			p++;
		} else {
			buf[i] = fmt[k];
		}
		i++;
		k++;
	}
	fprintf(stderr, "buf = [%s]\n", buf);
	return new_String(buf);
}

#include <UIKit/UIKit.h>

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

UnionType new_FFI(const char *name, void *ptr)
{
	UnionType ret;
	FFIObject *ffi = (FFIObject*)fetch_object();
	ArrayObject array;
	array.size = 0;
	array.list = NULL;
	UnionType hash_ref = new_HashRef(new_Hash(&array));
	PackageObject *pkg = get_pkg((char *)name);
	ffi->header = FFI;
	ffi->members = hash_ref;
	ffi->mtds = pkg;
	ffi->pkg_name = name;
	ffi->ptr = ptr;
	ret.o = FFI_init(ffi);
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

unsigned long long TYPE(uint64_t data)
{
	if (data >= UNDEF_TAG) {
		return Undefined;
	} else if (data >= FFI_TAG) {
		return FFI;
	} else if (data >= PACKAGE_TAG) {
		return Package;
	} else if (data >= IO_HANDLER_TAG) {
		return IOHandler;
	} else if (data >= CODE_REF_TAG) {
		return CodeRef;
	} else if (data >= BLESSED_OBJECT_TAG) {
		return BlessedObjectType;
	} else if (data >= OBJECT_TAG) {
		return ObjectType;
	} else if (data >= HASH_REF_TAG) {
		return HashRef;
	} else if (data >= HASH_TAG) {
		return Hash;
	} else if (data >= ARRAY_REF_TAG) {
		return ArrayRef;
	} else if (data >= ARRAY_TAG) {
		return Array;
	} else if (data >= STRING_TAG) {
		return String;
	} else if (data >= INT_TAG) {
		return Int;
	} else {
		return Double;
	}
}
