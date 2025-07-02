/*
This is free and unencumbered software released into the public domain.
*/

#ifndef _AES_COMMON_S_
#define _AES_COMMON_S_

.macro AES_LOAD_STATE reg0, reg1, reg2, reg3, src, tmp0, tmp1, tmp2, tmp3
    lw \reg0, 0(\src)      // Load word 0
    lw \reg1, 4(\src)      // Load word 1
    lw \reg2, 8(\src)      // Load word 2
    lw \reg3, 12(\src)     // Load word 3
.endm

.macro ROR32I dst, tmp, src, imm
    srli \tmp, \src, \imm
    slli \dst, \src, 32-\imm
    or \dst, \dst, \tmp
.endm

#endif
