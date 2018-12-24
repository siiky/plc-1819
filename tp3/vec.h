/* vec - v2018.11.04-0
 *
 * A vector type inspired by
 *  * Rust's `Vec` type
 *  * [stb](https://github.com/nothings/stb)
 *  * [sort](https://github.com/swenson/sort)
 *
 * The most up to date version of this file can be found at
 * `include/vec.h` on [siiky/c-utils](https://github.com/siiky/c-utils)
 * More usage examples can be found at `src/vec` on the link above
 *
 * # TODO
 *
 * - [X] Allow more than one implementation for different types
 * - [ ] More options
 *
 * # Usage
 *
 * A simple, single implementation, example follows below. A more
 * advanced example, with multiple implementations and use of
 * _Generic(), can be found on the repository.
 */

# if 0
#include <stddef.h>

size_t my_dtor_function (size_t elem)
{
    return elem;
}

#define VEC_CFG_DATA_TYPE size_t

// Optionally, define a comparison function similar to strcmp()
// (Not optional for compound types, like structs)
#define VEC_CFG_DATA_TYPE_CMP(L, R) \
    (((L) < (R)) ? \
     (-1) :        \
     ((L) > (R)) ? \
     (1) :         \
     (0))

// Optionally, define a destructor function of type
//     VEC_CFG_DATA_TYPE dtor (VEC_CFG_DATA_TYPE);
// If defined, it will be used when removing elements
#define VEC_CFG_DTOR my_dtor_function

// Optionally, define the struct identifier (defaults to `vec`)
#define VEC_CFG_VEC my_uber_vec

// Optionally, define a prefix for the generated functions (defaults
// to `VEC_CFG_VEC_`, in this case `my_uber_vec_`)
#define VEC_CFG_PREFIX my_

// Optionally, define NDEBUG to disable asserts inside vec.h
//#define NDEBUG

// Optionally, define VEC_CFG_STATIC to mark definitions as `static`
// Probably will raise `unused-function` warnings
//#define VEC_CFG_STATIC

// Create implementation, instead of working as a header
#define VEC_CFG_IMPLEMENTATION

#include <vec.h>

#include <assert.h>

int main (void)
{
    struct my_uber_vec _vec = {0};
    struct my_uber_vec * vec = &_vec;

    size_t used = 0;
    for (size_t i = 0; i < 100; i++)
        if (my_push(vec, i))
            used++;

    {
        size_t len = my_len(vec);
        size_t cap = my_capacity(vec);

        assert(used == len);
        assert(cap >= len);
    }

    // Iterate over a vector
    for (my_iter(vec); my_itering(vec); my_iter_next(vec)) {
        size_t r = my_get_nth(vec, my_iter_idx(vec));
        assert(r == my_iter_idx(vec));
    }

    // Automatically stop iterating
    assert(!my_itering(vec));

    // The last index of the iteration is still available
    assert(my_iter_idx(vec) == (used - 1));

    // If VEC_CFG_DTOR is defined, VEC_FREE() will automatically
    // call it on every element
    _vec = my_free(_vec);

    {
        bool empty = my_is_empty(vec);
        const size_t * ptr = my_as_slice(vec);
        size_t cap = my_capacity(vec);
        size_t len = my_len(vec);

        assert(cap == 0);
        assert(empty);
        assert(len == 0);
        assert(ptr == NULL);
    }

    return 0;
}
# endif

/*
 * <stdbool.h>
 *  bool
 *  false
 *  true
 *
 * <stddef.h>
 *  size_t
 */
#include <stdbool.h>
#include <stddef.h>

/*
 * Magic from `sort.h`
 */
# define VEC_CFG_CONCAT(A, B)    A ## B
# define VEC_CFG_MAKE_STR1(A, B) VEC_CFG_CONCAT(A, B)
# define VEC_CFG_MAKE_STR(A)     VEC_CFG_MAKE_STR1(VEC_CFG_PREFIX, A)

/*
 * Type of data for the vector to hold
 */
# ifndef VEC_CFG_DATA_TYPE
#  error "Must define VEC_CFG_DATA_TYPE"
# endif /* VEC_CFG_DATA_TYPE */

/*
 * The vector name defaults to `vec`
 */
# ifndef VEC_CFG_VEC
#  define VEC_CFG_VEC vec
# endif /* VEC_CFG_VEC */

/*
 * The prefix defaults to the vector name with an '_' appended
 */
# ifndef VEC_CFG_PREFIX
#  define VEC_CFG_PREFIX VEC_CFG_MAKE_STR1(VEC_CFG_VEC, _)
# endif /* VEC_CFG_PREFIX */

/**=========================================================
 * @brief The vector type
 */
struct VEC_CFG_VEC {
    /** Pointer to actual data */
    VEC_CFG_DATA_TYPE * ptr;

    /** Number of elements */
    size_t length;

    /** Number of elements the vector can hold currently */
    size_t capacity;

    /** Iterator index */
    size_t idx;

    /** Should iterate from begginning or end */
    unsigned char reverse : 1;

    /** Is currently iterating */
    unsigned char iterating : 1;
};

/*==========================================================
 * Function names
 *=========================================================*/
#define VEC_APPEND         VEC_CFG_MAKE_STR(append)
#define VEC_AS_MUT_SLICE   VEC_CFG_MAKE_STR(as_mut_slice)
#define VEC_AS_SLICE       VEC_CFG_MAKE_STR(as_slice)
#define VEC_BSEARCH        VEC_CFG_MAKE_STR(bsearch)
#define VEC_CAP            VEC_CFG_MAKE_STR(cap)
#define VEC_ELEM           VEC_CFG_MAKE_STR(elem)
#define VEC_FILTER         VEC_CFG_MAKE_STR(filter)
#define VEC_FIND           VEC_CFG_MAKE_STR(find)
#define VEC_FOREACH        VEC_CFG_MAKE_STR(foreach)
#define VEC_FOREACH_RANGE  VEC_CFG_MAKE_STR(foreach_range)
#define VEC_FREE           VEC_CFG_MAKE_STR(free)
#define VEC_FREE_RANGE     VEC_CFG_MAKE_STR(free_range)
#define VEC_FROM_RAW_PARTS VEC_CFG_MAKE_STR(from_raw_parts)
#define VEC_GET_NTH        VEC_CFG_MAKE_STR(get_nth)
#define VEC_INSERT         VEC_CFG_MAKE_STR(insert)
#define VEC_IS_EMPTY       VEC_CFG_MAKE_STR(is_empty)
#define VEC_ITER           VEC_CFG_MAKE_STR(iter)
#define VEC_ITERING        VEC_CFG_MAKE_STR(itering)
#define VEC_ITER_END       VEC_CFG_MAKE_STR(iter_end)
#define VEC_ITER_IDX       VEC_CFG_MAKE_STR(iter_idx)
#define VEC_ITER_NEXT      VEC_CFG_MAKE_STR(iter_next)
#define VEC_ITER_REV       VEC_CFG_MAKE_STR(iter_rev)
#define VEC_LEN            VEC_CFG_MAKE_STR(len)
#define VEC_MAP            VEC_CFG_MAKE_STR(map)
#define VEC_MAP_RANGE      VEC_CFG_MAKE_STR(map_range)
#define VEC_POP            VEC_CFG_MAKE_STR(pop)
#define VEC_PUSH           VEC_CFG_MAKE_STR(push)
#define VEC_QSORT          VEC_CFG_MAKE_STR(qsort)
#define VEC_REMOVE         VEC_CFG_MAKE_STR(remove)
#define VEC_RESERVE        VEC_CFG_MAKE_STR(reserve)
#define VEC_SET_LEN        VEC_CFG_MAKE_STR(set_len)
#define VEC_SET_NTH        VEC_CFG_MAKE_STR(set_nth)
#define VEC_SHRINK_TO_FIT  VEC_CFG_MAKE_STR(shrink_to_fit)
#define VEC_SPLIT_OFF      VEC_CFG_MAKE_STR(split_off)
#define VEC_SWAP_REMOVE    VEC_CFG_MAKE_STR(swap_remove)
#define VEC_TRUNCATE       VEC_CFG_MAKE_STR(truncate)
#define VEC_WITH_CAP       VEC_CFG_MAKE_STR(with_cap)

/*==========================================================
 * Function prototypes
 *
 * RETURN TYPE            FUNCTION NAME      PARAMETER LIST
 *==========================================================*/
VEC_CFG_DATA_TYPE         VEC_GET_NTH        (const struct VEC_CFG_VEC * self, size_t nth);
VEC_CFG_DATA_TYPE         VEC_POP            (struct VEC_CFG_VEC * self);
VEC_CFG_DATA_TYPE         VEC_REMOVE         (struct VEC_CFG_VEC * self, size_t index);
VEC_CFG_DATA_TYPE         VEC_SWAP_REMOVE    (struct VEC_CFG_VEC * self, size_t index);
VEC_CFG_DATA_TYPE *       VEC_AS_MUT_SLICE   (struct VEC_CFG_VEC * self);
bool                      VEC_APPEND         (struct VEC_CFG_VEC * restrict self, struct VEC_CFG_VEC * restrict other);
bool                      VEC_ELEM           (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element);
bool                      VEC_FILTER         (struct VEC_CFG_VEC * self, bool pred (const VEC_CFG_DATA_TYPE *));
bool                      VEC_FOREACH        (const struct VEC_CFG_VEC * self, void f (const VEC_CFG_DATA_TYPE));
bool                      VEC_FOREACH_RANGE  (const struct VEC_CFG_VEC * self, void f (const VEC_CFG_DATA_TYPE), size_t from, size_t to);
bool                      VEC_FREE_RANGE     (struct VEC_CFG_VEC * self, size_t from, size_t to);
bool                      VEC_FROM_RAW_PARTS (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE * ptr, size_t length, size_t capacity);
bool                      VEC_INSERT         (struct VEC_CFG_VEC * self, size_t index, VEC_CFG_DATA_TYPE element);
bool                      VEC_IS_EMPTY       (const struct VEC_CFG_VEC * self);
bool                      VEC_ITER           (struct VEC_CFG_VEC * self);
bool                      VEC_ITERING        (const struct VEC_CFG_VEC * self);
bool                      VEC_ITER_END       (struct VEC_CFG_VEC * self);
bool                      VEC_ITER_NEXT      (struct VEC_CFG_VEC * self);
bool                      VEC_ITER_REV       (struct VEC_CFG_VEC * self, bool rev);
bool                      VEC_MAP            (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE f (VEC_CFG_DATA_TYPE));
bool                      VEC_MAP_RANGE      (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE f (VEC_CFG_DATA_TYPE), size_t from, size_t to);
bool                      VEC_PUSH           (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element);
bool                      VEC_QSORT          (struct VEC_CFG_VEC * self, int compar (const void *, const void *));
bool                      VEC_RESERVE        (struct VEC_CFG_VEC * self, size_t total);
bool                      VEC_SET_LEN        (struct VEC_CFG_VEC * self, size_t len);
bool                      VEC_SET_NTH        (struct VEC_CFG_VEC * self, size_t nth, VEC_CFG_DATA_TYPE element);
bool                      VEC_SHRINK_TO_FIT  (struct VEC_CFG_VEC * self);
bool                      VEC_SPLIT_OFF      (struct VEC_CFG_VEC * self, struct VEC_CFG_VEC * other, size_t at);
bool                      VEC_TRUNCATE       (struct VEC_CFG_VEC * self, size_t len);
bool                      VEC_WITH_CAP       (struct VEC_CFG_VEC * self, size_t capacity);
const VEC_CFG_DATA_TYPE * VEC_AS_SLICE       (const struct VEC_CFG_VEC * self);
size_t                    VEC_BSEARCH        (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE key, int compar (const void *, const void *));
size_t                    VEC_CAP            (const struct VEC_CFG_VEC * self);
size_t                    VEC_FIND           (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element);
size_t                    VEC_ITER_IDX       (const struct VEC_CFG_VEC * self);
size_t                    VEC_LEN            (const struct VEC_CFG_VEC * self);
struct VEC_CFG_VEC        VEC_FREE           (struct VEC_CFG_VEC self);

#ifdef VEC_CFG_IMPLEMENTATION

/*
 * <assert.h>
 *  assert()
 *
 * <stdlib.h>
 *  bsearch()
 *  calloc()
 *  free()
 *  malloc()
 *  qsort()
 *  realloc()
 *
 * <string.h>
 *  memcpy()
 *  memmove()
 */
#include <assert.h>
#include <stdlib.h>
#include <string.h>

# ifndef VEC_CFG_DATA_TYPE_CMP
#  define VEC_CFG_DATA_TYPE_CMP(L, R) \
    (((L) < (R)) ? \
     (-1) :        \
     ((L) > (R)) ? \
     (1) :         \
     (0))
# endif /* VEC_CFG_DATA_TYPE_CMP */

# ifdef VEC_CFG_STATIC
#  undef VEC_CFG_STATIC
#  define VEC_CFG_STATIC static
# else /* VEC_CFG_STATIC */
#  undef VEC_CFG_STATIC
#  define VEC_CFG_STATIC
# endif /* VEC_CFG_STATIC */

# ifndef VEC_CFG_MALLOC
#  define VEC_CFG_MALLOC malloc
# endif /* VEC_CFG_MALLOC */

# ifndef VEC_CFG_CALLOC
#  define VEC_CFG_CALLOC calloc
# endif /* VEC_CFG_CALLOC */

# ifndef VEC_CFG_REALLOC
#  define VEC_CFG_REALLOC realloc
# endif /* VEC_CFG_REALLOC */

# ifndef VEC_CFG_FREE
#  define VEC_CFG_FREE free
# endif /* VEC_CFG_FREE */

/*==========================================================
 * Static functions' names
 *=========================================================*/
#define _VEC_CHANGE_CAPACITY   VEC_CFG_MAKE_STR(_change_capacity)
#define _VEC_CLEAN             VEC_CFG_MAKE_STR(_clean)
#define _VEC_DECREASE_CAPACITY VEC_CFG_MAKE_STR(_decrease_capacity)
#define _VEC_INCREASE_CAPACITY VEC_CFG_MAKE_STR(_increase_capacity)

/*==========================================================
 * Function definitions
 *========================================================*/

/**=========================================================
 * @brief Try to change the capacity of @a self to @a cap
 * @param self The vector
 * @param cap The new capacity
 * @returns `true` if the operation was successful, `false` otherwise
 */
static inline bool _VEC_CHANGE_CAPACITY (struct VEC_CFG_VEC * self, size_t cap)
{
    VEC_CFG_DATA_TYPE * ptr = VEC_CFG_REALLOC(self->ptr, cap * sizeof(VEC_CFG_DATA_TYPE));

    bool ret = ptr != NULL;

    if (ret) {
        self->ptr = ptr;
        self->capacity = cap;
    }

    return ret;
}

/**=========================================================
 * @brief Clean a vector, i.e., zero it
 * @param self The vector
 * @returns `true`
 */
static inline bool _VEC_CLEAN (struct VEC_CFG_VEC * self)
{
    *self = (struct VEC_CFG_VEC) {0};
    return true;
}

/**=========================================================
 * @brief Check if @a self has capacity for another element, and try
 *        to increase it, if it doesn't
 * @param self The vector
 * @returns `true` if @a self has enough space for at least one more
 *          element (after the operation, i.e., if it already had
 *          before, or it was able to increase), `false` otherwise
 */
static inline bool _VEC_INCREASE_CAPACITY (struct VEC_CFG_VEC * self)
{
    return self->length < self->capacity
        ||  _VEC_CHANGE_CAPACITY(self,
                /* new_cap = (cap * 1.5) + 1 */
                self->capacity + (self->capacity >> 1) + 1);
}

/**=========================================================
 * @brief Check if @a self has too much unused memory and decrease it
 * @param self The vector
 * @returns `false` if @a self has too much unused memory but it
 *          couldn't decrease it, `true` otherwise
 */
static inline bool _VEC_DECREASE_CAPACITY (struct VEC_CFG_VEC * self)
{
    return self->capacity <= 1
        /* more than half of the capacity in use? */
        || self->length >= (self->capacity >> 1)
        || _VEC_CHANGE_CAPACITY(self,
                /*
                 * len * 2   ~ cap
                 * len * 1.5 ~ cap * 0.75
                 * len * 1.5 ~ new_cap
                 */
                self->length + (self->length >> 1) + 1);
}

/**=========================================================
 * @brief Free @a self
 * @param self The vector
 * @returns An empty vector (i.e. zeroed)
 */
VEC_CFG_STATIC struct VEC_CFG_VEC VEC_FREE (struct VEC_CFG_VEC self)
{
    VEC_FREE_RANGE(&self, 0, self.length);

    if (self.ptr != NULL)
        VEC_CFG_FREE(self.ptr);

    _VEC_CLEAN(&self);

    return self;
}

/**=========================================================
 * @brief Clean and initialize a vector with @a capacity free slots
 * @param capacity Number of elements to allocate
 * @returns The new vector
 */
VEC_CFG_STATIC inline bool VEC_WITH_CAP (struct VEC_CFG_VEC * self, size_t capacity)
{
    if (capacity == 0)
        return _VEC_CLEAN(self);

    VEC_CFG_DATA_TYPE * ptr = VEC_CFG_CALLOC(capacity, sizeof(VEC_CFG_DATA_TYPE));

    return (ptr != NULL)
        && VEC_FROM_RAW_PARTS(self, ptr, 0, capacity);
}

/**=========================================================
 * @brief Create a vector from separate components
 * @param ptr A pointer to malloc()'d memory
 * @param length Number of elements in @a ptr
 * @param capacity Total number of elements @a ptr can hold
 * @returns A new vector pointing to @a ptr, with @a length and @a capacity
 */
VEC_CFG_STATIC inline bool VEC_FROM_RAW_PARTS (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE * ptr, size_t length, size_t capacity)
{
    _VEC_CLEAN(self);

    self->ptr = ptr;
    self->length = length;
    self->capacity = capacity;

    return true;
}

/**=========================================================
 * @brief Calculate the capacity of @a self
 * @param self The vector
 * @returns The capacity of @a self
 */
VEC_CFG_STATIC inline size_t VEC_CAP (const struct VEC_CFG_VEC * self)
{
    return (self != NULL) ?
        self->capacity:
        0;
}

/**=========================================================
 * @brief Reserve memory for @a total elements
 * @param self The vector
 * @param total Number of total elements
 * @returns `true` if @a self has enough capacity (after the operation),
 *          `false` otherwise
 */
VEC_CFG_STATIC bool VEC_RESERVE (struct VEC_CFG_VEC * self, size_t total)
{
    return (self != NULL)
        && ((self->capacity >= total) || _VEC_CHANGE_CAPACITY(self, total));
}

/**=========================================================
 * @brief Shrink @a self to its length
 * @param self The vector
 * @returns `false` if it wasn't possible to shrink @a self,
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_SHRINK_TO_FIT (struct VEC_CFG_VEC * self)
{
    return (self != NULL)
        && (self->length == 0
        || self->length == self->capacity
        || _VEC_CHANGE_CAPACITY(self, self->length));
}

/**=========================================================
 * @brief Shorten @a self, keeping the first @a len elements
 * @param self The vector
 * @param len New length
 * @returns `false` if @a self is not a valid vector, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_TRUNCATE (struct VEC_CFG_VEC * self, size_t len)
{
    if (self == NULL)
        return false;

    if (self->length > len) {
        VEC_FREE_RANGE(self, len, self->length);
        self->length = len;
    }

    _VEC_DECREASE_CAPACITY(self);

    return true;
}

/**=========================================================
 * @brief Return a `const` qualified pointer to allocated memory
 * @param self The vector
 * @returns `const` qualified pointer to allocated memory
 */
VEC_CFG_STATIC inline const VEC_CFG_DATA_TYPE * VEC_AS_SLICE (const struct VEC_CFG_VEC * self)
{
    return (self != NULL) ?
        self->ptr:
        NULL;
}

/**=========================================================
 * @brief Like vec_as_slice, but not `const` qualified
 * @param self The vector
 * @returns Pointer to allocated memory
 */
VEC_CFG_STATIC inline VEC_CFG_DATA_TYPE * VEC_AS_MUT_SLICE (struct VEC_CFG_VEC * self)
{
    return (self != NULL) ?
        self->ptr:
        NULL;
}

/**=========================================================
 * @brief Set the length of @a self to @a len, without checks
 * @param self The vector
 * @param len The new length
 * @returns `false` if @a self not a valid vector, `true` otherwise
 */
VEC_CFG_STATIC inline bool VEC_SET_LEN (struct VEC_CFG_VEC * self, size_t len)
{
    if (self == NULL)
        return false;
    self->length = len;
    return true;
}

/**=========================================================
 * @brief Remove the element at @a index, replacing it with the last
 *        element
 * @param self The vector
 * @param index Index of the element to be removed
 * @returns The removed element
 */
VEC_CFG_STATIC VEC_CFG_DATA_TYPE VEC_SWAP_REMOVE (struct VEC_CFG_VEC * self, size_t index)
{
    assert(!VEC_IS_EMPTY(self));
    assert(index < self->length);

    /* Swap last with index */
    VEC_CFG_DATA_TYPE tmp = self->ptr[index];
    self->ptr[index] = self->ptr[self->length - 1];
    self->ptr[self->length - 1] = tmp;

    /* return last (ex-index) */
    return VEC_POP(self);
}

/**=========================================================
 * @brief Insert an @a element at @a index, shifting every element
 *        after it to the right
 * @param self The vector
 * @param index Where the element will be inserted
 * @param element Element to be inserted
 * @returns `false` if @a index is out of bounds or @a self didn't have
 *          enough capacity and it wasn't possible to increase it,
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_INSERT (struct VEC_CFG_VEC * self, size_t index, VEC_CFG_DATA_TYPE element)
{
    if (self == NULL
    || index > self->length)
        return false;

    if (index == self->length)
        return VEC_PUSH(self, element);

    if (!_VEC_INCREASE_CAPACITY(self))
        return false;

    void * dst = self->ptr + index + 1;
    void * src = self->ptr + index;
    size_t nbytes = (self->length - index) * sizeof(VEC_CFG_DATA_TYPE);
    memmove(dst, src, nbytes);

    self->length++;
    self->ptr[index] = element;

    return true;
}

/**=========================================================
 * @brief Remove an element at @a index, shifting every element after
 *        it to the left
 * @param self The vector
 * @param index Index of the element to be removed
 * @returns The removed element
 */
VEC_CFG_STATIC VEC_CFG_DATA_TYPE VEC_REMOVE (struct VEC_CFG_VEC * self, size_t index)
{
    assert(!VEC_IS_EMPTY(self));
    assert(index < self->length);

    VEC_CFG_DATA_TYPE ret = self->ptr[index];
    self->length--;

    if (self->length > 0) {
        VEC_CFG_DATA_TYPE * dst = self->ptr + index;
        VEC_CFG_DATA_TYPE * src = self->ptr + index + 1;
        size_t size = sizeof(VEC_CFG_DATA_TYPE);
        size_t nmemb = self->length - index;
        memmove(dst, src, size * nmemb);
    }

    _VEC_DECREASE_CAPACITY(self);

    return ret;
}

/**=========================================================
 * @brief Free the elements of @a self in the range [@a from, @a to[
 * @param self The vector
 * @param from The start index
 * @param to The end index (not including the element at this index)
 * @returns Same as VEC_MAP_RANGE()
 */
bool VEC_FREE_RANGE (struct VEC_CFG_VEC * self, size_t from, size_t to)
{
# ifdef VEC_CFG_DTOR
    return VEC_MAP_RANGE(self, VEC_CFG_DTOR, from, to);
# else
    /* Suppress unused warnings */
    (void) self;
    (void) from;
    (void) to;
    return true;
# endif /* VEC_CFG_DTOR */
}

/**=========================================================
 * @brief Keep every element of @a self that satisfies a predicate
 *        @a pred. If VEC_CFG_DTOR is defined, it is called on
 *        each element of @a self that does not satisfy @a pred
 * @param self The vector
 * @param pred The predicate
 * @returns `false` if @a self is not a valid vector or @a pred is
 *          NULL, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_FILTER (struct VEC_CFG_VEC * self, bool pred (const VEC_CFG_DATA_TYPE *))
{
    if (self == NULL
    || self->ptr == NULL
    || pred == NULL)
        return false;

    size_t len = 0;

    for (size_t r = 0; r < self->length; r++)
        if (pred(self->ptr + r))
            self->ptr[len++] = self->ptr[r];
# ifdef VEC_CFG_DTOR
        else
            VEC_CFG_DTOR(self->ptr[r]);
# endif /* VEC_CFG_DTOR */

    self->length = len;

    _VEC_DECREASE_CAPACITY(self);

    return true;
}

/**=========================================================
 * @brief Insert an @a element at the end of @a self
 * @param self The vector
 * @param element Element to be pushed
 * @returns `false` if @a self is not a valid vector, or it didn't
 *          have enough capacity and it wasn't possible to increase
 *          it, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_PUSH (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element)
{
    if (self == NULL || !_VEC_INCREASE_CAPACITY(self))
        return false;

    self->ptr[self->length] = element;
    self->length++;

    return true;
}

/**=========================================================
 * @brief Remove the last element of @a self
 * @param self The vector
 * @returns The removed element
 */
VEC_CFG_STATIC VEC_CFG_DATA_TYPE VEC_POP (struct VEC_CFG_VEC * self)
{
    assert(!VEC_IS_EMPTY(self));

    self->length--;

    _VEC_DECREASE_CAPACITY(self);

    return self->ptr[self->length];
}

/**=========================================================
 * @brief Append @a other to @a self and set the length of @a other
 *        to 0
 * @param self The vector
 * @param other The other vector
 * @returns `false` if either @a self or @a other aren't valid vectors,
 *          @a self didn't have enough capacity and it wasn't possible
 *          to increase it, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_APPEND (struct VEC_CFG_VEC * restrict self, struct VEC_CFG_VEC * restrict other)
{
    if (self == NULL
    || other == NULL
    || self->ptr == NULL
    || other->ptr == NULL
    || self->ptr == other->ptr
    || !VEC_RESERVE(self, self->length + other->length))
        return false;

    VEC_CFG_DATA_TYPE * dest = self->ptr + self->length;
    VEC_CFG_DATA_TYPE * src = other->ptr;
    size_t n = other->length * sizeof(VEC_CFG_DATA_TYPE);
    memcpy(dest, src, n);
    self->length += other->length;

    other->length = 0;

    return true;
}

/**=========================================================
 * @brief Calculate the length of @a self
 * @param self The vector
 * @returns The length of @a self
 */
VEC_CFG_STATIC inline size_t VEC_LEN (const struct VEC_CFG_VEC * self)
{
    return (self != NULL) ?
        self->length:
        0;
}

/**=========================================================
 * @brief Check if @a self is empty
 * @param self The vector
 * @returns `true` if @a self is empty, `false` otherwise
 */
VEC_CFG_STATIC inline bool VEC_IS_EMPTY (const struct VEC_CFG_VEC * self)
{
    return self == NULL
        || self->ptr == NULL
        || self->length == 0;
}

/**=========================================================
 * @brief Split @a self in two, keeping the first `at - 1` elements
 *        in @a self, and the rest in the returned vector
 * @param self The vector
 * @param other Where to put the elements to the right of @a at
 * @param at Where to split
 * @returns `true` if the operation was successful, `false` otherwise
 */
VEC_CFG_STATIC bool VEC_SPLIT_OFF (struct VEC_CFG_VEC * restrict self, struct VEC_CFG_VEC * restrict other, size_t at)
{
    if (self == NULL
    || other == NULL
    || at >= self->length
    || at == 0)
        return false;

    *other = VEC_FREE(*other);

    bool ret = VEC_WITH_CAP(other, self->length - at + 1);

    if (ret) {
        void * dest = other->ptr;
        const void * src = self->ptr + at - 1;
        size_t n = sizeof(VEC_CFG_DATA_TYPE) * other->capacity;
        memcpy(dest, src, n);

        other->length = other->capacity;
        self->length -= other->capacity;
    }

    return ret;
}

/**=========================================================
 * @brief Get the element at the @a nth index
 * @param self The vector
 * @param nth The index
 * @returns The element at index @a nth
 */
VEC_CFG_STATIC inline VEC_CFG_DATA_TYPE VEC_GET_NTH (const struct VEC_CFG_VEC * self, size_t nth)
{
    assert(self != NULL);
    assert(self->ptr != NULL);
    assert(nth < self->length);
    return self->ptr[nth];
}

/**=========================================================
 * @brief Set the element at index @a nth to @a element
 * @param self The vector
 * @param nth The index
 * @param element The new element
 * @returns `false` if @a self is not a valid vector or @a nth is out
 *          of bounds, `true` otherwise
 */
VEC_CFG_STATIC inline bool VEC_SET_NTH (struct VEC_CFG_VEC * self, size_t nth, VEC_CFG_DATA_TYPE element)
{
    if (VEC_IS_EMPTY(self)
    || nth >= self->length)
        return false;
    self->ptr[nth] = element;
    return true;
}

/**=========================================================
 * @brief Get the index of the first occurrence (if any) of @a element
 * @param self The vector
 * @param element The element to look for
 * @returns The index of the first occurrence of @a element, or, if
 *          @a element does not exist, the length of @a self
 */
VEC_CFG_STATIC size_t VEC_FIND (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element)
{
    assert(self != NULL);

    size_t ret = 0;
    for (ret = 0;
            ret < self->length
            && (VEC_CFG_DATA_TYPE_CMP(self->ptr[ret], element) != 0);
            ret++);

    return ret;
}

/**=========================================================
 * @brief Check if @a self contains an @a element
 * @param self The vector
 * @param element The element to look for
 * @returns `true` if @a element exists in @a self, `false` otherwise
 */
VEC_CFG_STATIC inline bool VEC_ELEM (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE element)
{
    return self != NULL
        && self->ptr != NULL
        && (VEC_FIND(self, element) < self->length);
}

/**=========================================================
 * @brief Wraper for `stdlib.h`'s `bsearch()` function
 * @param self The vector
 * @param elem The elem to look for
 * @param compar A function suitable to be passed to `bsearch()`
 * @returns The index of an occurrence of @a element, or, if @a element
 *          does not exist, the length of @a self
 */
VEC_CFG_STATIC size_t VEC_BSEARCH (const struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE key, int compar (const void *, const void *))
{
    assert(self != NULL);
    assert(compar != NULL);

    if (self->ptr == NULL || self->length == 0)
        return self->length;

    const void * base = self->ptr;
    size_t nmemb = self->length;
    size_t size = sizeof(VEC_CFG_DATA_TYPE);

    VEC_CFG_DATA_TYPE * found = bsearch(&key, base, nmemb, size, compar);
    return (found != NULL) ?
        (size_t) (found - self->ptr):
        self->length;
}

/**=========================================================
 * @brief Wraper for `stdlib.h`'s `qsort()` function
 * @param self The vector
 * @param compar A function suitable to be passed to `qsort()`
 * @returns `false` if @a self is not a valid vector, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_QSORT (struct VEC_CFG_VEC * self, int compar (const void *, const void *))
{
    if (self == NULL || self->ptr == NULL || compar == NULL)
        return false;
    qsort(self->ptr, self->length, sizeof(VEC_CFG_DATA_TYPE), compar);
    return true;
}

/**=========================================================
 * @brief Apply @a f on every element of @a self in the range
 *        [@a from, @a to[
 * @param self The vector
 * @param f The function to apply on every element
 * @param from The start index
 * @param to The end index (not including element at this index)
 * @returns `false` if @a self is not a valid vector, @a f is NULL,
 *          @a from is larger than or equal to @a to, or @a to is out of bounds,
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_MAP_RANGE (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE f (VEC_CFG_DATA_TYPE), size_t from, size_t to)
{
    if (self == NULL
    || self->ptr == NULL
    || f == NULL
    || from >= to
    || to > self->length)
        return false;

    for (size_t i = from; i < to; i++)
        self->ptr[i] = f(self->ptr[i]);

    return true;
}

/**=========================================================
 * @brief Apply @a f to every element of @a self
 * @param self The vector
 * @param f The function to apply on every element
 * @returns Same as VEC_MAP_RANGE()
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_MAP (struct VEC_CFG_VEC * self, VEC_CFG_DATA_TYPE f (VEC_CFG_DATA_TYPE))
{
    return (self != NULL) &&
        VEC_MAP_RANGE(self, f, 0, self->length);
}

/**=========================================================
 * @brief For every element in @a self in the range [@a from, @a to[,
 *        call @a f with it. This function is similar to VEC_MAP_RANGE
 *        except @a self or its elements are not altered
 * @param self The vector
 * @param f The function to call for every element
 * @param from The start index
 * @param to The end index (not including element at this index)
 * @returns `false` if @a self is not a valid vector or @a f is NULL,
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_FOREACH_RANGE (const struct VEC_CFG_VEC * self, void f (const VEC_CFG_DATA_TYPE), size_t from, size_t to)
{
    if (self == NULL
    || self->ptr == NULL
    || f == NULL
    || from >= to
    || to > self->length)
        return false;

    for (size_t i = from; i < to; i++)
        f(self->ptr[i]);

    return true;
}

/**=========================================================
 * @brief For every element in @a self call @a f with it. This function
 *        is similar to VEC_MAP except @a self or its elements are not
 *        altered
 * @param self The vector
 * @param f The function to apply on every element
 * @returns Same as VEC_FOREACH_RANGE()
 */
VEC_CFG_STATIC bool VEC_FOREACH (const struct VEC_CFG_VEC * self, void f (const VEC_CFG_DATA_TYPE))
{
    return (self != NULL)
        && VEC_FOREACH_RANGE(self, f, 0, self->length);
}

/**=========================================================
 * @brief Start iterating over @a self. If @a self is already iterating,
 *        do nothing
 * @param self The vector
 * @returns `false` if @a self is not a valid vector or it is already
 *          iterating, `true` otherwise
 */
VEC_CFG_STATIC bool VEC_ITER (struct VEC_CFG_VEC * self)
{
    if (VEC_IS_EMPTY(self)
    || self->iterating)
        return false;

    self->idx = (self->reverse) ?
        self->length - 1:
        0;

    self->iterating = true;

    return true;
}

/**=========================================================
 * @brief Stop the iterator over @a self
 * @param self The vector
 * @returns `false` if @a self is not a valid vector, `true` otherwise
 */
VEC_CFG_STATIC inline bool VEC_ITER_END (struct VEC_CFG_VEC * self)
{
    return (self != NULL)
        && !(self->iterating = false);
}

/**=========================================================
 * @brief Check if @a self is iterating
 * @param self The vector
 * @returns `true` if @a self is iterating, `false` otherwise
 */
VEC_CFG_STATIC inline bool VEC_ITERING (const struct VEC_CFG_VEC * self)
{
    return (self != NULL)
        && self->iterating;
}

/**=========================================================
 * @brief Get the index of the iterator
 * @param self The vector
 * @returns The current index of the iterator
 */
VEC_CFG_STATIC inline size_t VEC_ITER_IDX (const struct VEC_CFG_VEC * self)
{
    assert(self != NULL);
    assert(self->idx < self->length);
    return self->idx;
}

/**=========================================================
 * @brief Move the iterator to the next index
 * @param self The vector
 * @returns `true` if still iterating, `false` otherwise
 */
VEC_CFG_STATIC bool VEC_ITER_NEXT (struct VEC_CFG_VEC * self)
{
    if (self == NULL || !self->iterating)
        return false;

    /*
     * if the vec is being iterated but, for example, elements are
     * removed
     */
    if (self->idx >= self->length) {
        VEC_ITER_END(self);
        return false;
    }

    bool over = self->idx == ((!self->reverse) ?
            self->length - 1:
            0);

    if (over)
        VEC_ITER_END(self);
    else
        if (self->reverse)
            self->idx--;
        else
            self->idx++;

    return self->iterating;
}

/**=========================================================
 * @brief Set the `reverse` flag, i.e., if the iterator should
 *        move from beggining to end or end to begginning
 * @param self The vector
 * @returns `false` if @a self is iterating or it is not a valid vector,
 *          `true` otherwise
 */
VEC_CFG_STATIC bool VEC_ITER_REV (struct VEC_CFG_VEC * self, bool rev)
{
    if (self == NULL || self->iterating)
        return false;
    self->reverse = rev;
    return true;
}

/*==========================================================
 * Implementation clean up
 *=========================================================*/

/*
 * Functions
 */
#undef _VEC_CHANGE_CAPACITY
#undef _VEC_CLEAN
#undef _VEC_DECREASE_CAPACITY
#undef _VEC_INCREASE_CAPACITY

/*
 * Other
 */
#undef VEC_CFG_DATA_TYPE_CMP
#undef VEC_CFG_DTOR
#undef VEC_CFG_STATIC

#endif /* VEC_CFG_IMPLEMENTATION */

/*==========================================================
 * Clean up
 *=========================================================*/

/*
 * Functions
 */
#undef VEC_APPEND
#undef VEC_AS_MUT_SLICE
#undef VEC_AS_SLICE
#undef VEC_BSEARCH
#undef VEC_CAP
#undef VEC_ELEM
#undef VEC_FILTER
#undef VEC_FIND
#undef VEC_FOREACH
#undef VEC_FOREACH_RANGE
#undef VEC_FREE
#undef VEC_FREE_RANGE
#undef VEC_FROM_RAW_PARTS
#undef VEC_GET_NTH
#undef VEC_INSERT
#undef VEC_IS_EMPTY
#undef VEC_ITER
#undef VEC_ITERING
#undef VEC_ITER_END
#undef VEC_ITER_IDX
#undef VEC_ITER_NEXT
#undef VEC_ITER_REV
#undef VEC_LEN
#undef VEC_MAP
#undef VEC_MAP_RANGE
#undef VEC_POP
#undef VEC_PUSH
#undef VEC_QSORT
#undef VEC_REMOVE
#undef VEC_RESERVE
#undef VEC_SET_LEN
#undef VEC_SET_NTH
#undef VEC_SHRINK_TO_FIT
#undef VEC_SPLIT_OFF
#undef VEC_SWAP_REMOVE
#undef VEC_TRUNCATE
#undef VEC_WITH_CAP

/*
 * Other
 */
#undef VEC_CFG_CONCAT
#undef VEC_CFG_DATA_TYPE
#undef VEC_CFG_MAKE_STR
#undef VEC_CFG_MAKE_STR1
#undef VEC_CFG_PREFIX
#undef VEC_CFG_VEC

/*==========================================================
 * License
 *==========================================================
 *
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <http://unlicense.org/>
 */
