.code16
.global _start
.org 0x00
.equ BOOTSEG,           0x07c0
    ljmp    $BOOTSEG,   $_start

my_text:
.byte 'L', 0x70, 'a', 0x70, 'b', 0x70, 'e', 0x70, 'l', 0x70, ':', 0x70, ' ', 0x70
.equ my_text_len, . - my_text

_start:
    # movsb/movsw:
    # src = DS:SI
    # dest = ES:DI
    # count = CX
    # FLAGS.DF can change the direction of reading in movsb/movsw
    mov     $0x7c0,     %ax
    mov     %ax,        %ds
    mov     $0xB800,    %ax
    mov     %ax,        %es

    cld # DF = 0
    mov     $my_text,   %si
    mov     $0x00,      %di
    mov     $my_text_len, %cx
    rep movsb

    mov     $number,    %ax # lower 16bit is $number
    mov     %ax,        %bx # address where number is saved to
    mov     $5,         %cx
    mov     $10,        %si

_loop:
    xor     %dx,        %dx # higher 16bit is 0x0000
    div     %si
    mov     %dl,        (%bx)
    inc     %bx
    loop _loop

    mov     $number,    %bx
    mov     $4,         %si

_show:
    mov     (%bx, %si), %al
    add     $'0',       %al
    mov     $0x70,      %ah
    movw    %ax,        %es:(%di)
    add     $2,         %di
    dec     %si
    jns     _show

    movw    $0x7020,    %es:(%di) # add a space

    jmp     .

.align 16
.org 256
number: .byte 0, 0, 0, 0, 0

.org 510
boot_flag:
    .word 0xAA55
