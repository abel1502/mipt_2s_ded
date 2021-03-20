#ifndef FILEBUF_H
#define FILEBUF_H

#include "general.h"

#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>


class FileBuf {
public:
    FACTORIES(FileBuf);

    bool ctor();

    /// File read constructor
    bool ctor(const char *name, const char *mode);

    /// Memory read constructor
    bool ctor(const char *src, size_t amount);

    /// Memory read constructor with implicit amount
    bool ctor(const char *src);

    void dtor();

    unsigned getSize() const;

    const char *getData() const;

    bool write(const char *src, size_t from, size_t len);

    bool isInited() const;

    bool save() const;

private:
    size_t size;
    char *buf;

    char *fname;

};



#endif // FILEBUF_H
