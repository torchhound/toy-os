BITS 16
ORG 0x0000
global start

gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

start:
    mov si, load_msg
    call print

    cli
    xor ax, ax
    mov ds, ax

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

print:
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

load_msg db 'Loading loader...', 0

BITS 32
protected_mode:
    mov esi, protected_load_msg
    call pprint

    mov ax, 0x10

    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x90000

    call 0x000101ab
    jmp $

pprint:
    pusha
    mov edi, 0xB8000   ; start of VGA text buffer
.next:
    lodsb              ; load byte from [esi] into al
    or al, al
    jz .done
    mov ah, 0x0F       ; bright white text on black bg
    stosw              ; store ax at [edi], advance edi
    jmp .next
.done:
    popa
    ret

protected_load_msg:
    db 'Loading protected mode...', 0