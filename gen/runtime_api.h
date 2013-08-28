#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include <stdarg.h>

typedef enum {
	Double,
	Int,
	String,
	Array,
	ArrayRef,
	Hash,
	HashRef,
	ObjectType,
	BlessedObjectType,
	CodeRef,
	IOHandler,
	Package,
	FFI,
	Undefined
} Type;

#define __IOS_SIMULATOR__

#ifdef __IOS_SIMULATOR__

typedef union {
	double d;
	uint64_t o;
} UnionType;

#else

typedef union {
	double d;
	int i;
	char *s;
	void *a;
	void *o;
} UnionType;

#endif

typedef UnionType Value;

typedef struct _Object {
	int type;
	Value v;
	void *slot1;
	void *slot2;
	void *slot3;
	void *slot4;
	void *slot5;
	void *slot6;
} Object;

typedef struct _Undef {
	int header;
} UndefObject;

typedef struct _String {
	int header;
	char *s;
	size_t len;
	unsigned long hash;
} StringObject;

typedef struct _Array {
	int type;
	//Value *list;
	Value **list;
	size_t size;
} ArrayObject;

typedef struct _ArrayRef {
	int type;
	Value v;
} ArrayRefObject;

typedef struct _Hash {
	int header;
	Value *table;
	StringObject **keys;
	size_t size;
} HashObject;

typedef struct _Package {
	int header;
	Value *table;
	StringObject **keys;
	size_t size;
	ArrayObject *isa;
	const char *name;
} PackageObject;

typedef struct _HashRef {
	int type;
	Value v; /* boxed HashObject */
} HashRefObject;

typedef UnionType(*Code)(ArrayObject*);

typedef struct _CodeRef {
	int header;
	Code code;
} CodeRefObject;

typedef struct _BlessedObject {
	int header;
	Value members; /* boxed HashObject */
	PackageObject *mtds;
	const char *pkg_name;
} BlessedObject;

typedef struct _IOHandlerObject {
	int header;
	FILE *fp;
	const char *filename;
	const char *mode;
} IOHandlerObject;

typedef struct _FFIObject {
	int header;
	Value members; /* boxed HashObject */
	PackageObject *mtds;
	const char *pkg_name;
	void *ptr;
} FFIObject;

#define HASH_TABLE_SIZE 512

#ifdef __IOS_SIMULATOR__ //32bit NaNBoxing

#define NaN                (uint64_t)(0x7FF8000000000000)
#define INT_TAG            (uint64_t)(0xfffffff100000000)
#define STRING_TAG         (uint64_t)(0xfffffff200000000)
#define ARRAY_TAG          (uint64_t)(0xfffffff300000000)
#define ARRAY_REF_TAG      (uint64_t)(0xfffffff400000000)
#define HASH_TAG           (uint64_t)(0xfffffff500000000)
#define HASH_REF_TAG       (uint64_t)(0xfffffff600000000)
#define OBJECT_TAG         (uint64_t)(0xfffffff700000000)
#define BLESSED_OBJECT_TAG (uint64_t)(0xfffffff800000000)
#define CODE_REF_TAG       (uint64_t)(0xfffffff900000000)
#define IO_HANDLER_TAG     (uint64_t)(0xfffffffa00000000)
#define PACKAGE_TAG        (uint64_t)(0xfffffffb00000000)
#define FFI_TAG            (uint64_t)(0xfffffffc00000000)
#define UNDEF_TAG          (uint64_t)(0xfffffffd00000000)

unsigned long long TYPE(uint64_t data);

#define INT_init(data) ((uint32_t)data | INT_TAG)
#define STRING_init(data) ((uint64_t)data | STRING_TAG)
#define ARRAY_init(data) ((uint64_t)data | ARRAY_TAG)
#define ARRAY_REF_init(data) ((uint64_t)data | ARRAY_REF_TAG)
#define HASH_init(data) ((uint64_t)data | HASH_TAG)
#define HASH_REF_init(data) ((uint64_t)data | HASH_REF_TAG)
#define OBJECT_init(data) ((uint64_t)data | OBJECT_TAG)
#define CODE_REF_init(data) ((uint64_t)data | CODE_REF_TAG)
#define BLESSED_OBJECT_init(data) ((uint64_t)data | BLESSED_OBJECT_TAG)
#define IO_HANDLER_init(data) ((uint64_t)data | IO_HANDLER_TAG)
#define PACKAGE_init(data) ((uint64_t)data | PACKAGE_TAG)
#define FFI_init(data) ((uint64_t)data | FFI_TAG)
#define UNDEF_init(data) ((uint64_t)data | UNDEF_TAG)

#define to_Ptr(o) (void *)(o & (uint64_t)0xfffffff)
#define to_Int(o) ((intptr_t)o)
#define to_String(o) (StringObject *)to_Ptr(o)
#define to_Object(o) (Object *)to_Ptr(o)
#define to_Array(o) (ArrayObject *)to_Ptr(o)
#define to_ArrayRef(o) (ArrayRefObject *)to_Ptr(o)
#define to_Hash(o) (HashObject *)to_Ptr(o)
#define to_Package(o) (PackageObject *)to_Ptr(o)
#define to_HashRef(o) (HashRefObject *)to_Ptr(o)
#define to_CodeRef(o) (CodeRefObject *)to_Ptr(o)
#define to_BlessedObject(o) (BlessedObject *)to_Ptr(o)
#define to_IOHandler(o) (IOHandlerObject *)to_Ptr(o)
#define to_FFI(o) (FFIObject *)to_Ptr(o)

#define TYPE_CHECK(o, T) do {								\
		if (TYPE(o) != T) {									\
			fprintf(stderr, "type = [%llu]\n", TYPE(o));	\
			assert(0 && "Type Error!\n");					\
		}													\
	} while (0)

#else

#define NaN                (0xFFF0000000000000)
#define MASK               (0x00000000FFFFFFFF)
#define _TYPE              (0x000F000000000000)
#define INT_TAG            (uint64_t)(0x0001000000000000)
#define STRING_TAG         (uint64_t)(0x0002000000000000)
#define ARRAY_TAG          (uint64_t)(0x0003000000000000)
#define ARRAY_REF_TAG      (uint64_t)(0x0004000000000000)
#define HASH_TAG           (uint64_t)(0x0005000000000000)
#define HASH_REF_TAG       (uint64_t)(0x0006000000000000)
#define OBJECT_TAG         (uint64_t)(0x0007000000000000)
#define BLESSED_OBJECT_TAG (uint64_t)(0x0008000000000000)
#define CODE_REF_TAG       (uint64_t)(0x0009000000000000)
#define IO_HANDLER_TAG     (uint64_t)(0x000a000000000000)
#define PACKAGE_TAG        (uint64_t)(0x000b000000000000)
#define FFI_TAG            (uint64_t)(0x000c000000000000)
#define UNDEF_TAG          (uint64_t)(0x000d000000000000)

#define TYPE(data) ((((uint64_t)data & NaN) == NaN) * (((uint64_t)data & _TYPE) >> 48))

#define INT_init(data) (void *)(uint64_t)((data & MASK) | NaN | INT_TAG)
#define DOUBLE_init(data) (void *)&data
#define STRING_init(data) (void *)((uint64_t)data | NaN | STRING_TAG)
#define ARRAY_init(data) (void *)((uint64_t)data | NaN | ARRAY_TAG)
#define ARRAY_REF_init(data) (void *)((uint64_t)data | NaN | ARRAY_REF_TAG)
#define HASH_init(data) (void *)((uint64_t)data | NaN | HASH_TAG)
#define HASH_REF_init(data) (void *)((uint64_t)data | NaN | HASH_REF_TAG)
#define OBJECT_init(data) (void *)((uint64_t)data | NaN | OBJECT_TAG)
#define CODE_REF_init(data) (void *)((uint64_t)data | NaN | CODE_REF_TAG)
#define BLESSED_OBJECT_init(data) (void *)((uint64_t)data | NaN | BLESSED_OBJECT_TAG)
#define IO_HANDLER_init(data) (void *)((uint64_t)data | NaN | IO_HANDLER_TAG)
#define PACKAGE_init(data) (void *)((uint64_t)data | NaN | PACKAGE_TAG)
#define FFI_init(data) (void *)((uint64_t)data | NaN | FFI_TAG)
#define UNDEF_init(data) (void *)((uint64_t)data | NaN | UNDEF_TAG)

#define to_Int(o) ((intptr_t)o)
#define to_Double(o) (*(double *)o)
#define to_String(o) (StringObject *)((uint64_t)o ^ (NaN | STRING_TAG))
#define to_Object(o) (Object *)((uint64_t)o ^ (NaN | OBJECT_TAG))
#define to_Array(o) (ArrayObject *)((uint64_t)o ^ (NaN | ARRAY_TAG))
#define to_ArrayRef(o) (ArrayRefObject *)((uint64_t)o ^ (NaN | ARRAY_REF_TAG))
#define to_Hash(o) (HashObject *)((uint64_t)o ^ (NaN | HASH_TAG))
#define to_Package(o) (PackageObject *)((uint64_t)o ^ (NaN | PACKAGE_TAG))
#define to_HashRef(o) (HashRefObject *)((uint64_t)o ^ (NaN | HASH_REF_TAG))
#define to_CodeRef(o) (CodeRefObject *)((uint64_t)o ^ (NaN | CODE_REF_TAG))
#define to_BlessedObject(o) (BlessedObject *)((uint64_t)o ^ (NaN | BLESSED_OBJECT_TAG))
#define to_IOHandler(o) (IOHandlerObject *)((uint64_t)o ^ (NaN | IO_HANDLER_TAG))
#define to_FFI(o) (FFIObject *)((uint64_t)o ^ (NaN | FFI_TAG))

#define TYPE_CHECK(o, T) do {					\
		if (TYPE(o) != T) {						\
			fprintf(stderr, "type = [%llu]\n", TYPE(o));	\
			assert(0 && "Type Error!\n");		\
		}										\
	} while (0)

#endif


UnionType print(ArrayObject *array);
void print_hash(FILE *fp, HashObject *hash);
void print_object(FILE *fp, UnionType o);
void _print_with_handler(FILE *fp, ArrayObject *array);
void dumper(UnionType o, size_t indent);
Object *fetch_object(void);
UnionType new_Hash(ArrayObject *array);
HashRefObject *dynamic_hash_ref_cast_code(UnionType *o);
ArrayRefObject *dynamic_array_ref_cast_code(UnionType *o);
UnionType new_Array(UnionType **list, size_t size);
UnionType new_ArrayRef(UnionType array);
UnionType new_IOHandler(const char *filename, const char *mode, FILE *fp);
UnionType new_String(char *str);
void make_object_pool(void);
PackageObject *get_pkg(char *pkg_name);
void Array_add(ArrayObject *array, UnionType *elem);
UnionType Hash_get(HashObject *hash, StringObject *key);

#define SET(ret, a, b, op) do {					\
		switch (TYPE(b->o)) {					\
		case Int: {								\
			int j = to_Int(b->o);				\
			int k = a op j;						\
			ret.o = INT_init(k);				\
			break;								\
		}										\
		case Double: {							\
			double d = a op b->d;				\
			ret.d = d;							\
			break;								\
		}										\
		default:								\
			break;								\
		}										\
	} while (0)

#define CMP_SET(ret, a, b, op) do {				\
		switch (TYPE(b->o)) {					\
		case Int: {								\
			int i = a op to_Int(b->o);			\
			ret.o = INT_init(i);				\
			break;								\
		}										\
		case Double: {							\
			double d = a op b->d;				\
			ret.o = INT_init((int)d);			\
			break;								\
		}										\
		default:								\
			break;								\
		}										\
	} while (0)

#define setResultByObjectObject(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {						\
		case Int: {									\
			int i = to_Int(a->o);					\
			SET(ret, i, b, op);						\
			break;									\
		}											\
		case Double:								\
			SET(ret, a->d, b, op);					\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setCmpResultByObjectObject(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {						\
		case Int:									\
			CMP_SET(ret, to_Int(a->o), b, op);		\
			break;									\
		case Double:								\
			CMP_SET(ret, a->d, b, op);				\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setResultByObjectInt(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {						\
		case Int: {									\
			int i = (int)to_Int(a->o) op b;			\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		case Double:								\
			ret.d = a->d op b;						\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setCmpResultByObjectInt(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {						\
		case Int: {									\
			int i = (int)to_Int(a->o) op b;			\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		case Double: {								\
			int i = a->d op b;						\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		default:									\
			break;									\
		}											\
	} while (0)

#define setResultByIntObject(ret, a, b, op) do {	\
		switch (TYPE(b->o)) {						\
		case Int: {									\
			int i = a op (int)to_Int(b->o);			\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		case Double:								\
			ret.d = (double)(int)a op b->d;			\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setCmpResultByIntObject(ret, a, b, op) do {	\
		switch (TYPE(b->o)) {						\
		case Int: {									\
			int i = a op (int)to_Int(b->o);			\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		case Double: {								\
			int i = a op b->d;						\
			ret.o = INT_init(i);					\
			break;									\
		}											\
		default:									\
			break;									\
		}											\
	} while (0)

#define setResultByObjectDouble(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {						\
		case Int:									\
			ret.d = (double)(int)to_Int(a->o) op b;	\
			break;									\
		case Double:								\
			ret.d = a->d op b;						\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setCmpResultByObjectDouble(ret, a, b, op) do {	\
		switch (TYPE(a->o)) {							\
		case Int: {										\
			int i = (double)(int)to_Int(a->o) op b;		\
			ret.o = INT_init(i);						\
			break;										\
		}												\
		case Double: {									\
			int i = a->d op b;							\
			ret.o = INT_init(i);						\
			break;										\
		}												\
		default:										\
			break;										\
		}												\
	} while (0)

#define setResultByDoubleObject(ret, a, b, op) do {	\
		switch (TYPE(b->o)) {						\
		case Int:									\
			ret.d = a op to_Int(b->o);				\
			break;									\
		case Double:								\
			ret.d = a op b->d;						\
			break;									\
		default:									\
			break;									\
		}											\
	} while (0)

#define setCmpResultByDoubleObject(ret, a, b, op) do {	\
		switch (TYPE(b->o)) {							\
		case Int: {										\
			int i = a op to_Int(b->o);					\
			ret.o = INT_init(i);						\
			break;										\
		}												\
		case Double: {									\
			int i = a op b->d;							\
			ret.o = INT_init(i);						\
			break;										\
		}												\
		default:										\
			break;										\
		}												\
	} while (0)
