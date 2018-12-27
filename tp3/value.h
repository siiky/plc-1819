#ifndef _VALUE_H
#define _VALUE_H

union value {
    bool   Bool;
    char * String;
    float  Float;
    int    Int;
};

#endif /* _VALUE_H */
