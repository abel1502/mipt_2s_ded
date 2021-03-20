#include "filebuf.h"

#include <cassert>
#include <cctype>


bool FileBuf::ctor() {
    size = 0;

    buf = nullptr;

    fname = nullptr;

    return false;
}

bool FileBuf::ctor(const char *name, const char *mode) {
    assert(name);
    assert(mode);
    assert(!buf);

    fname = (char *)calloc(strlen(name) + 1, sizeof(char));
    strcpy(fname, name);

    FILE *file = fopen(name, mode);

    struct stat fbuf = {};
    size_t bytesRead = 0;
    size_t lineCnt = 0;

    if (!file)
        goto error;

    if (fstat(fileno(file), &fbuf) != 0)
        goto error;

    size = fbuf.st_size + 1;

    buf = (char *)calloc(size, 1);

    if (!buf)
        goto error;

    bytesRead = fread(buf, 1, size - 1, file);

    fclose(file);
    file = nullptr;

    for (char *cur = buf; *cur; ++cur) {
        if (*cur == '\n') {
            lineCnt++;
        }
    }

    if (bytesRead != size - 1 && bytesRead + lineCnt != size - 1)
        goto error;

    return false;

error:
    free(buf);
    buf = nullptr;

    if (file) {
        fclose(file);
        file = nullptr;
    }

    return true;
}

bool FileBuf::ctor(const char *src, size_t amount) {
    assert(src);

    size = amount + 1;

    buf = (char *)calloc(amount + 1, 1);

    fname = nullptr;

    if (!buf)
        goto error;

    memcpy(buf, src, amount);

    return false;

error:
    free(buf);
    buf = nullptr;

    return true;
}

bool FileBuf::ctor(const char *src) {
    return ctor(src, strlen(src));
}

void FileBuf::dtor() {
    free(buf);
    free(fname);

    size = 0;
    buf = nullptr;
}

unsigned FileBuf::getSize() const {
    return size;
}

const char *FileBuf::getData() const {
    return buf;
}

bool FileBuf::write(const char *src, size_t from, size_t len) {
    if (from + len > size)
        return true;

    memcpy(buf + from, src, len);

    return false;
}

bool FileBuf::isInited() const {
    return buf != nullptr;
}

bool FileBuf::save() const {
    FILE *file = fopen(fname, "wb");

    size_t bytesWritten = 0;

    if (!file)
        goto error;

    bytesWritten = fwrite(buf, sizeof(char), size, file);

    if (bytesWritten != size)
        goto error;

    fclose(file);
    file = nullptr;

    return false;

error:
    if (file) {
        fclose(file);
        file = nullptr;
    }

    return true;
}

