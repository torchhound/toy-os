BITS 32
section .text
global start
extern kmain

start:
    mov ax, 0x10

    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x90000

    call kmain
    jmp $

