.code16
.global _start, numbers

# There are 16 genetic registers in 8086 (ax, bx, cx, dx, si, di,bp, sp)
# and you can split the following 16-bit registers: ax, bx, cx, dx
# into 8-bit registers (ah, al, bh, bl, ch, cl, dh, dl)

# CS is Code Segment, DS is Data Segment
# modification of CS will cause CPU to start executing program at different location
# also there're another 3 registers called ES (extra segment), SS (stack register)
# and IP (instruction pointer) < Not modifiable

# Physical Address ==> Segment:Offset = (Segment << 4) + offset
# because offset always starts with 0x0000, so Segment address must be aligned with 16 bytes

# the boot sector is always 512 bytes, and will be loaded
# to 0x07C00

# 8086 can access up to 1 Mb memory
# with 0x00000-0x9FFFF being RAM
#      0xF0000-0xFFFFF being ROM-BIOS
# and there's a 320 Kb gap (0xA0000-0xEFFFF) mapped by the external devices,
# and 0xB8000-0xBFFFF is mapped for video memory (80x25, text mode only)
# (Machine starts at 0x0000fff0?)

# When ROM-BIOS deteced the boot sector, boot sector code will be loaded at the
# address of 0x0000:0x7C00

.org 0x00
    # In text mode, the Video Memory is mapped in 0xB800:0x0000 - 0xB800-0xFFFF
    # Video Memory format is <(ASCII)+(COLOR)>, i.e. 2 bytes being one unit
    # Background (KRGB)         Forground(IRGB)
    # K = 0, not flashing
    # K = 1, flashing
    # K  R  G  B
    # -  0  0  0  Black         I = 0 Black,        I = 1 Grey
    # -  0  0  1  Blue          I = 0 Blue,         I = 1 Light-Blue
    # -  0  1  0  Green         I = 0 Green,        I = 1 Light-Green
    # -  0  1  1  Cyan-Blue     I = 0 Cyan-Blue,    I = 1 Light-Cyan-Blue
    # -  1  0  0  Red           I = 0 Red,          I = 1 Light-Red
    # -  1  0  1  Magenta       I = 0 Magenta,      I = 1 Light-Magenta
    # -  1  1  0  Brown         I = 0 Brown,        I = 1 Yellow
    # -  1  1  1  White         I = 0 White,        I = 1 Light-White
    # COLOR Byte = KRGB IRGB

    # Assembly Syntax Intel & AT&T

    # Intel Code                    AT&T Code
    # mov eax,1                     movl $1,%eax
    # mov ebx,0ffh                  movl $0xff,%ebx
    # int 80h                       int  $0x80
    # mov ebx, eax                  movl %eax, %ebx
    # mov eax,[ecx]                 movl (%ecx),%eax
    # mov eax,[ebx+3]               movl 3(%ebx),%eax
    # mov eax,[ebx+20h]             movl 0x20(%ebx),%eax
    # add eax,[ebx+ecx*2h]          addl (%ebx,%ecx,0x2),%eax
    # lea eax,[ebx+ecx]             leal (%ebx,%ecx),%eax
    # sub eax,[ebx+ecx*4h-20h]      subl -0x20(%ebx,%ecx,0x4),%eax

    # Source and destinations are flipped in opcodes.
    # Intel is dest, src
    # AT&T is src, dest
    # AT&T decorates registers and immediates
    # Registers are prefixed with a “%”
    # Immediates are prefixed with a “$”. This applies to variables being passed in from C (when you’re inline).
    # Intel decorates memory operands to denote the operand’s size, AT&T uses different mnemonics to accomplish the same.
    # Intel syntax to dereference a memory location is “[ ]”. AT&T uses “( )”.

    # AT&T has instruction mnemonic suffix like -b(8bit) -w(16bit) -l(32bit)

.equ BOOTSEG,   0x07C0              # original address of boot-sector

    ljmp    $BOOTSEG,   $_start

_start:
    # write 'Label:' at the start of the screen
    mov     $0xB800,    %ax
    mov     %ax,        %es
    movb    $'L',       %es:0x00
    movb    $0x07,      %es:0x01
    movb    $'a',       %es:0x02
    movb    $0x07,      %es:0x03
    movb    $'b',       %es:0x04
    movb    $0x07,      %es:0x05
    movb    $'e',       %es:0x06
    movb    $0x07,      %es:0x07
    movb    $'l',       %es:0x08
    movb    $0x07,      %es:0x09
    movb    $':',       %es:0x0A
    movb    $0x07,      %es:0x0B
    movb    $' ',       %es:0x0C
    movb    $0x07,      %es:0x0D

    mov     $number,    %ax
    mov     $10,        %bx

    # mov %cs, %ds
    mov     %cs,        %cx
    mov     %cx,        %ds

    # div has 2 mode
    # 1st is 16bit / 8bit : %ax / <num> = %al -- %ah
    # 2st is 32bit / 16bit : <high16bit: %dx><low16bit: %ax> / <num> = %ax -- %dx

    # xor (eXclusive OR)
    # 0 xor 0 = 0
    # 0 xor 1 = 1
    # 1 xor 0 = 1
    # 1 xor 1 = 0
    # Or to put it simple, when different is 1, same is 0

    # show number
    movb    $' ',       %es:0x18
    movb    $0x07,      %es:0x19
    movb    $' ',       %es:0x16
    movb    $0x07,      %es:0x17

    # Highest, 4
    movw    $number,    %ax
    movb    $10,        %bh
    div     %bh

    addb    $'0',       %ah
    movb    %ah,        %es:0x14
    movb    $0x07,      %es:0x15

    # No.3
    xorb    %ah,        %ah
    div     %bh

    addb    $'0',       %ah
    movb    %ah,        %es:0x12
    movb    $0x07,      %es:0x13

    # No.2
    xorb    %ah,        %ah
    div     %bh

    addb    $'0',       %ah
    movb    %ah,        %es:0x10
    movb    $0x07,      %es:0x11

    # No.1
    xorb    %ah,        %ah
    div     %bh

    addb    $'0',       %ah
    movb    %ah,        %es:0x0E
    movb    $0x07,      %es:0x0F

    jmp     .

.org 374
number:

# for a boot sector to be valid, the last 2 byte should
# be 0x55 and 0xAA (0xAA55)
.org 510
boot_flag:
# .byte (8bit)
# .word (16bit)
# .long (32bit)
# .quad (64bit)
# .ascii "" (string)
# .fill <repeat>, <size(bytes)>, <value>
    .word 0xAA55
