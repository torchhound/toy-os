all: os-image

os-image: boot.o kernel.o isr.o
	ld -m elf_i386 -T link.ld -o kernel.bin boot.o kernel.o isr.o
	dd if=kernel.bin of=os-image.img bs=512 conv=notrunc

boot.o: boot.asm
	nasm -f elf32 boot.asm -o boot.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -fno-pic -nostdlib -nostartfiles -nodefaultlibs -c kernel.c -o kernel.o

isr.o: isr.asm
	nasm -f elf32 isr.asm -o isr.o

clean:
	rm -f *.o *.bin *.img
