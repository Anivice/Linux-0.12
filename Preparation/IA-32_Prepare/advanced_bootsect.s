.code16
.global _start
.org 0x00
.equ BOOTSEG,   0x07c0

    ljmp    $BOOTSEG,   $_start

_start:
    jmp     .

.org 510
boot_flag:
    .word 0xAA55
