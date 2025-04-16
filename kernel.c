#include <stdint.h>

#define PORT_KBD_DATA 0x60
#define PORT_PIC1_CMD 0x20
#define PORT_PIC1_DATA 0x21
#define IDT_SIZE 256

struct idt_entry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  zero;
    uint8_t  type_attr;
    uint16_t offset_high;
} __attribute__((packed));

struct idt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

struct idt_entry idt[IDT_SIZE];

void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void idt_set_gate(int n, uint32_t handler) {
    idt[n].offset_low = handler & 0xFFFF;
    idt[n].selector = 0x08;
    idt[n].zero = 0;
    idt[n].type_attr = 0x8E;
    idt[n].offset_high = (handler >> 16) & 0xFFFF;
}

extern void isr1(); // keyboard handler in asm

void idt_install() {
    struct idt_ptr idtp;
    idtp.limit = sizeof(struct idt_entry) * IDT_SIZE - 1;
    idtp.base = (uint32_t)&idt;

    idt_set_gate(0x21, (uint32_t)isr1);

    __asm__ volatile ("lidtl (%0)" : : "r"(&idtp));
    outb(PORT_PIC1_DATA, 0xFD); // unmask only IRQ1 (keyboard)
    outb(PORT_PIC1_CMD, 0x20);  // EOI
}

void kputc(char c) {
    static volatile char *video = (char*)0xb8000;
    static int pos = 0;
    video[pos++] = c;
    video[pos++] = 0x07;
}

void kprint(const char *s) {
    while (*s) kputc(*s++);
}

char scancode_to_ascii(uint8_t sc) {
    static char map[128] = {
        0,27,'1','2','3','4','5','6','7','8','9','0','-','=','\b',
        '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',0,
        'a','s','d','f','g','h','j','k','l',';','\'','`',0,'\\',
        'z','x','c','v','b','n','m',',','.','/',0,'*',0,' ',0
    };
    if (sc > 58) return 0;
    return map[sc];
}

void keyboard_handler() {
    uint8_t scancode = inb(PORT_KBD_DATA);
    char ascii = scancode_to_ascii(scancode);
    if (ascii) kputc(ascii);
    outb(PORT_PIC1_CMD, 0x20); // EOI
}

void kmain() {
    kprint("booting toy os...\n> ");
    idt_install();
    __asm__ volatile ("sti"); // enable interrupts
    while (1) __asm__ volatile ("hlt");
}
