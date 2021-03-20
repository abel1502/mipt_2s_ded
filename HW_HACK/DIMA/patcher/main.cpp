#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <getopt.h>
#include <windows.h>

#include "general.h"
#include "patcher.h"
#include "filebuf.h"


static bool initConsole() {
    HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);

    if (hStdout == INVALID_HANDLE_VALUE) {
        ERR("Couldn't retrieve console.");

        return true;
    }

    if (!SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN)) {
        return true;
    }

    return false;
}

static bool restoreConsole() {
    HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);

    if (hStdout == INVALID_HANDLE_VALUE) {
        ERR("Couldn't retrieve console.");

        return true;
    }

    if (!SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE)) {
        return true;
    }

    return false;
}

static void music() {
    Beep(523, 500);
    Beep(622, 500);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(698, 250);
    Beep(698, 250);
    Beep(932, 250);
    Beep(830, 250);
    Beep(783, 125);
    Beep(698, 250);
    Beep(783, 625);
    Beep(783, 500);
    Beep(932, 500);
    Beep(1046, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(932, 250);
    Beep(932, 250);
    Beep(783, 250);
    Beep(932, 250);
    Beep(932, 375);
    Beep(1046, 1500);
    Sleep(125);
    Beep(523, 500);
    Beep(622, 500);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(698, 250);
    Beep(698, 250);
    Beep(932, 250);
    Beep(830, 250);
    Beep(783, 125);
    Beep(698, 250);
    Beep(783, 625);
    Beep(783, 500);
    Beep(932, 500);
    Beep(1046, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(932, 250);
    Beep(932, 250);
    Beep(783, 250);
    Beep(932, 250);
    Beep(932, 375);
    Beep(1046, 625);
    Sleep(250);
    Beep(311, 250);
    Beep(622, 250);
    Beep(466, 125);
    Beep(466, 625);
    Beep(311, 250);
    Beep(622, 375);
    Beep(698, 375);
    Beep(466, 250);
    Beep(466, 500);
    Sleep(250);
    Beep(466, 250);
    Beep(783, 375);
    Beep(830, 375);
    Beep(783, 250);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(783, 375);
    Beep(830, 375);
    Beep(783, 250);
    Beep(523, 500);
    Sleep(250);
    Beep(523, 125);
    Beep(587, 125);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(587, 500);
    Sleep(250);
    Beep(622, 125);
    Beep(698, 125);
    Beep(830, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(622, 500);
    Sleep(250);
    Beep(783, 250);
    Beep(783, 375);
    Beep(698, 375);
    Beep(659, 250);
    Beep(698, 500);
    Beep(523, 500);
    Beep(523, 750);
    Beep(587, 250);
    Beep(587, 1000);
    Sleep(250);
    Beep(311, 250);
    Beep(622, 250);
    Beep(466, 125);
    Beep(466, 625);
    Beep(311, 250);
    Beep(622, 375);
    Beep(698, 375);
    Beep(466, 250);
    Beep(466, 500);
    Sleep(250);
    Beep(466, 250);
    Beep(783, 375);
    Beep(830, 375);
    Beep(783, 250);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(783, 375);
    Beep(830, 375);
    Beep(783, 250);
    Beep(523, 500);
    Sleep(250);
    Beep(523, 125);
    Beep(587, 125);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(587, 500);
    Sleep(250);
    Beep(622, 125);
    Beep(698, 125);
    Beep(830, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(622, 500);
    Sleep(250);
    Beep(783, 250);
    Beep(783, 375);
    Beep(698, 375);
    Beep(659, 250);
    Beep(698, 375);
    Beep(783, 375);
    Beep(830, 250);
    Beep(783, 1375);
    Sleep(125);
    Beep(587, 500);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(698, 375);
    Beep(698, 375);
    Beep(622, 250);
    Beep(587, 375);
    Beep(523, 375);
    Beep(587, 250);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(698, 375);
    Beep(587, 375);
    Beep(523, 375);
    Beep(554, 500);
    Beep(783, 500);
    Beep(830, 500);
    Beep(932, 500);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(622, 375);
    Beep(622, 375);
    Beep(587, 250);
    Beep(698, 375);
    Beep(698, 375);
    Beep(622, 250);
    Beep(587, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(783, 375);
    Beep(830, 375);
    Beep(783, 250);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(783, 1000);
    Beep(783, 375);
    Beep(879, 375);
    Beep(987, 375);
    Beep(523, 500);
    Beep(622, 500);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(698, 250);
    Beep(698, 250);
    Beep(932, 250);
    Beep(830, 250);
    Beep(783, 125);
    Beep(698, 250);
    Beep(783, 625);
    Beep(783, 500);
    Beep(932, 500);
    Beep(1046, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(587, 250);
    Beep(587, 250);
    Beep(587, 250);
    Beep(622, 250);
    Beep(698, 125);
    Beep(622, 250);
    Beep(622, 625);
    Beep(523, 500);
    Beep(622, 500);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(698, 250);
    Beep(698, 250);
    Beep(932, 250);
    Beep(830, 250);
    Beep(783, 125);
    Beep(698, 250);
    Beep(783, 625);
    Beep(783, 500);
    Beep(932, 500);
    Beep(1046, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(932, 250);
    Beep(932, 250);
    Beep(783, 250);
    Beep(932, 250);
    Beep(932, 375);
    Beep(1046, 625);
    Beep(523, 500);
    Beep(622, 500);
    Beep(698, 375);
    Beep(622, 375);
    Beep(698, 250);
    Beep(698, 250);
    Beep(698, 250);
    Beep(932, 250);
    Beep(830, 250);
    Beep(783, 125);
    Beep(698, 250);
    Beep(783, 625);
    Beep(783, 500);
    Beep(932, 500);
    Beep(1046, 375);
    Beep(783, 375);
    Beep(698, 250);
    Beep(932, 250);
    Beep(932, 250);
    Beep(783, 250);
    Beep(932, 250);
    Beep(932, 375);
    Beep(1046, 625);
}

static void showBanner() {
    slowPrintf("#####################################\n"
               "#                                   #\n"
               "#       Abel Ultimate Patcher       #\n"
               "#          (c) Abel, 2021           #\n"
               "#                                   #\n"
               "#####################################\n"
               "\n"
               "This program patches anything (currently just Dima's crackme).\n\n");
}

static void showHelp(const char *binName) {
    slowPrintf("Usage:  %s [-h] [-v] target\n"
               "  -h        - show this and exit\n"
               "  -v        - increase verbosity\n"
               "  target    - name of the target file\n"
               "\n", binName);
}


int main(int argc, char **argv) {
    FileBuf target{};

    #define CLEANUP_       \
        target.dtor();     \
        restoreConsole();

    if (initConsole()) {
        return 3;
    }

    showBanner();

    int c = 0;

    while ((c = getopt(argc, argv, "+i:o:vhr")) != -1) {
        switch (c) {
        case 'h':
            showHelp(argv[0]);

            CLEANUP_

            return 0;
        case 'v':
            verbosity++;
            break;
        case '?':
            ERR("Unknown option: -%c.", optopt);
            showHelp(argv[0]);

            CLEANUP_

            return 1;
        default:
            ERR("Shouldn't be reachable");

            CLEANUP_

            abort();
        }
    }

    if (optind + 1 != argc) {
        ERR("Unexpected number of positional arguments.");
        showHelp(argv[0]);

        CLEANUP_

        return 1;
    }

    if (target.ctor(argv[optind], "rb")) {
        ERR("Couldn't open %s to read + write", argv[optind]);

        CLEANUP_

        return 2;
    }

    slowPrintf("ERROR: Visual effects unavailable, time to sleep!\n"
               "Recovering...\n"
               "SUCCESS! Patch resumed...\n");

    //music();

    if (patch(&target)) {
        ERR("Patch wasn't applied");

        CLEANUP_

        return 4;
    }

    slowPrintf("Done.\n\n");

    CLEANUP_

    return 0;

    #undef CLEANUP_
}
