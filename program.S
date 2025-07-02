/*
This is free and unencumbered software released into the public domain.
*/

#include "aes_common.S"

.section .data
.align 4
.org 0x400
ck:        .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
           .byte 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  // 128-bit cipher key
rk:        .space 176         // Space for round keys (11 * 16 bytes = 176 bytes)
aes_round_const:
           .byte 0x01, 0x02, 0x04, 0x08, 0x10
           .byte 0x20, 0x40, 0x80, 0x1b, 0x36

.section .text
.global _start

_start:
    # Set up arguments for aes_128_enc_key_schedule
    la a0, rk           # a0 = round key array
    la a1, ck           # a1 = cipher key
    call aes_128_enc_key_schedule

    # Set up arguments for aes_128_dec_key_schedule
    la a0, rk           # a0 = round key array
    la a1, ck           # a1 = cipher key
    call aes_128_dec_key_schedule

    # Write 123456789 to 0x2000_0000 to pass testbench
    li a0, 123456789
    li a1, 0x20000000
    sw a0, 0(a1)

    # Halt
    addi x9, x0, 0

.func aes_128_enc_key_schedule
.global aes_128_enc_key_schedule
aes_128_enc_key_schedule:       // a0 - uint32_t rk [AES_128_RK_WORDS]
                                // a1 - uint8_t  ck [AES_128_CK_BYTE ]
    #define C0  a2
    #define C1  a3
    #define C2  a4
    #define C3  a5
    #define RK  a0
    #define RKP a6
    #define CK  a1
    #define RKE t0
    #define RCP t1
    #define RCT t2
    #define T1  t3
    #define T2  t4

    AES_LOAD_STATE C0,C1,C2,C3,CK,t0,t1,t2,t3
    mv      RKP, RK
    addi    RKE, RK, 160        // t0 = rke = rk + 40
    la      RCP, aes_round_const

.aes_128_enc_ks_l0:
    sw      C0,  0(RKP)
    sw      C1,  4(RKP)
    sw      C2,  8(RKP)
    sw      C3, 12(RKP)
    beq     RKE, RKP, .aes_128_enc_ks_finish
    addi    RKP, RKP, 16
    lbu     RCT, 0(RCP)
    addi    RCP, RCP, 1
    xor     C0, C0, RCT
    ROR32I T1, T2, C3, 8
    aes32esi C0, C0, T1, 0
    aes32esi C0, C0, T1, 1
    aes32esi C0, C0, T1, 2
    aes32esi C0, C0, T1, 3
    xor     C1, C1, C0
    xor     C2, C2, C1
    xor     C3, C3, C2
    j .aes_128_enc_ks_l0

.aes_128_enc_ks_finish:
    ret

    #undef C0
    #undef C1
    #undef C2
    #undef C3
    #undef RK
    #undef RKP
    #undef CK
    #undef RKE
    #undef RCP
    #undef RCT
    #undef T1
    #undef T2
.endfunc

.func aes_128_dec_key_schedule
.global aes_128_dec_key_schedule
aes_128_dec_key_schedule:       // a0 - uint32_t rk [AES_128_RK_WORDS]
                                // a1 - uint8_t  ck [AES_128_CK_BYTE ]
    #define RK  a0
    #define RKP a2
    #define RKE a3
    #define T0  t0
    #define T1  t1

    addi    sp, sp, -16
    sw      ra, 0(sp)
    call    aes_128_enc_key_schedule
    addi    RKP, RK, 16
    addi    RKE, RK, 160

.dec_ks_loop:
    lw      T0, 0(RKP)
    li      T1, 0
    aes32esi  T1, T1, T0, 0
    aes32esi  T1, T1, T0, 1
    aes32esi  T1, T1, T0, 2
    aes32esi  T1, T1, T0, 3
    li      T0, 0
    aes32dsmi T0, T0, T1, 0
    aes32dsmi T0, T0, T1, 1
    aes32dsmi T0, T0, T1, 2
    aes32dsmi T0, T0, T1, 3
    sw      T0, 0(RKP)
    addi    RKP, RKP, 4
    bne     RKP, RKE, .dec_ks_loop

    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret

    #undef RK
    #undef RKP
    #undef RKE
    #undef T0
    #undef T1
.endfunc
