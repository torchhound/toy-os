BITS 32
section .text
global start
extern kmain

start:
    ; protected mode setup (GDT etc) here if needed
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov esp, 0x90000

    call kmain
    jmp $

