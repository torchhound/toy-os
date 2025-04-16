extern keyboard_handler
global isr1

isr1:
    pusha
    call keyboard_handler
    popa
    iretd
