.code16
.global _start
.org 0x00
.equ BOOTSEG,           0x07c0
    ljmp    $BOOTSEG,   $_start

msg:
    .ascii "1 + 2 + 3 +...+ 100 = "
    .equ msg_len, . - msg

_start:
    # set ds = 0x07c0, es = 0xB800
    mov     $0x07C0,    %ax
    mov     %ax,        %ds
    mov     $0xB800,    %ax
    mov     %ax,        %es

    mov     $msg,       %si
    mov     $0x00,      %di
    mov     $msg_len,   %cx

_show_msg:
    mov     (%si),      %al
    mov     %al,        %es:(%di)
    inc     %di
    movb    $0x70,      %es:(%di)
    inc     %di
    inc     %si
    loop    _show_msg

    xor     %ax,        %ax
    mov     $1,         %cx

_add_from_1_to_100:
    add     %cx,        %ax
    inc     %cx
    cmp     $100,       %cx
    jle     _add_from_1_to_100

    xor     %cx,        %cx
    mov     %cx,        %sp
    mov     %cx,        %ss
    mov     $10,        %bx

_cal:
    inc     %cx                 # count stack length
    xor     %dx,        %dx
    div     %bx
    or      $0x30,      %dl     # same as add $'0', %dl
    push    %dx
    cmp     $0,         %ax
    jne     _cal

    # now, every number is in stack
_show:
    pop     %dx
    movb    %dl,        %es:(%di)
    inc     %di
    movb    $0x70,      %es:(%di)
    inc     %di
    loop    _show

    jmp     .

.align 16
.org 256
number: .byte 0, 0, 0, 0, 0

.org 510
boot_flag:
    .word 0xAA55
