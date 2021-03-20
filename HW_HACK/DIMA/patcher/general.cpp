#include <cstdio>
#include <cstdarg>
#include <cerrno>
#include <windows.h>

#include "general.h"


int verbosity = 0;

void err_(const char *funcName, int lineNo, const char *msg, ...) {
    va_list args = {};
    va_start(args, msg);

    if (::verbosity >= 1) {
        slowPrintf("[ERROR in %s() on #%d] ", funcName, lineNo);
        slowVprintf(msg, args);
        slowPrintf("\n");

        if (errno != 0) {
            perror("System error:");
        }
    }

    va_end(args);
}

void slowType(const char *msg) {
    const unsigned DELAY = 15;

    while (*msg) {
        putc(*(msg++), stdout);
        fflush(stdout);

        Sleep(DELAY);
    }
}

void slowPrintf(const char *fmt, ...) {
    va_list args = {};
    va_start(args, fmt);

    slowVprintf(fmt, args);

    va_end(args);
}

void slowVprintf(const char *fmt, va_list args) {
    const unsigned BUF_LEN = 512;
    static char buf[BUF_LEN];

    vsnprintf(buf, BUF_LEN - 1, fmt, args);

    slowType(buf);
}


