#ifdef DEBUG
#define DBG_PL(fmt, ...) {\
	fprintf(stderr, fmt, ## __VA_ARGS__);	\
	fprintf(stderr, "\n");						\
	}
#else 
#define DBG_PL(fmt, ...)
#endif

#define PTR_TO_VALUE(name, ptr) new_FFI(#name, (void *)ptr)
#define OBJC_PTR_TO_VALUE(name, ptr) new_FFI(#name, (__bridge_retained void *)ptr)
#define VALUE_TO_OBJC_PTR(T, v) (__bridge T)((to_FFI(v->o))->ptr)
#define VALUE_TO_PTR(T, v) (T)((to_FFI(v.o))->ptr)
#define VALUE_PTR_TO_PTR(T, v) (T)((to_FFI(v->o))->ptr)
#define VALUE_TO_CHAR(v) (to_String(v->o))->s
#define VALUE_TO_INT(v) ((int)to_Int(v.o))
#define VALUE_PTR_TO_INT(v) ((int)to_Int(v->o))
#define VALUE_TO_NSSTRING(v) [NSString stringWithUTF8String: (to_String(v.o))->s]
#define VALUE_PTR_TO_NSSTRING(v) [NSString stringWithUTF8String: (to_String(v->o))->s]
#define VALUE_TO_HASHREF(v) to_HashRef(v->o)
#define VALUE_TO_HASH(v) to_Hash(v->o)
#define DEREF_TO_HASH(ref) to_Hash((ref)->v.o)

#define SELE(T) VALUE_TO_OBJC_PTR(T, args->list[0])

#define RETURN_VOID() do {							\
		Value __ret__;									\
		__ret__.o = INT_init(0);						\
		return __ret__;									\
	} while (0)

#define RETURN_INT(v) do {						\
		Value __ret__;							\
		__ret__.o = INT_init(v);				\
		return __ret__;							\
	} while (0)

#define RETURN_NSSTRING(v) do {						\
		Value __ret__;								\
		__ret__.o = STRING_init([v UTF8String]);	\
		return __ret__;								\
	} while (0)

#define RETURN(v) do {							\
		Value __ret__ = v;						\
		return __ret__;							\
	} while (0)

extern CodeRefObject *get_overrided_method(PackageObject *pkg, const char *mtd_name);
extern Value Hash_get_by_char(HashObject *hash, const char *key);
extern ArrayObject *make_array(size_t size);
