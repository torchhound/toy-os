BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    
    mov ax, 0x1000
    mov es, ax
    mov bx, 0x0000
    mov ah, 0x02
    mov al, 2      ; load 2 sectors
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80   ; first hard disk
    int 0x13
    jc disk_error

    jmp 0x1000:0x0000

disk_error:
    mov si, error_msg
    call print
    jmp $

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

error_msg db 'Disk load error', 0

times 510 - ($ - $$) db 0
dw 0xAA55
