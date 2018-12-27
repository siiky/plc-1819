#ifndef _TYPE_H
#define _TYPE_H

enum type {
    TYPE_ERROR   = 0,
    TYPE_BOOL    = 1,
    TYPE_FLOAT   = 2,
    TYPE_INT     = 3,
    TYPE_STRING  = 4,
    TYPE_DEFAULT = 5,
};

const char * type2str (enum type type);

#endif /* _TYPE_H */
