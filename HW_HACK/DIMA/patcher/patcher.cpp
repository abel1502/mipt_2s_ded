#include "patcher.h"
#include "general.h"
#include "checksum.h"


const crc32_t EXPECTED_HASH = 0xE53FBDC8;


const char PATCH_BYTES[1] = {(char)(0xEB ^ 0x7B)};
const size_t PATCH_POS = 0x0173 - 0x100;


bool patch(FileBuf *target) {
    assert(target);

    crc32_t hash = crc32_compute(target->getData(), target->getSize());

    if (hash != EXPECTED_HASH) {
        ERR("Hash mismatch");

        return true;
    }

    TRY_BC(target->write(PATCH_BYTES, PATCH_POS, sizeof(PATCH_BYTES)), ERR("Failed to patch the file in memory"));

    TRY_BC(target->save(), ERR("Failed to save the patched file"));

    return false;
}

