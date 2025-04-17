all: os-image

os-image: boot.bin loader.o kernel.o isr.o
	ld -m elf_i386 -T link.ld -Map=kernel.map -o kernel.bin loader.o kernel.o isr.o
	cat boot.bin kernel.bin > os-image.img

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

loader.o: loader.asm
	nasm -f elf32 loader.asm -o loader.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -fno-pic -nostdlib -nostartfiles -nodefaultlibs -c kernel.c -o kernel.o

isr.o: isr.asm
	nasm -f elf32 isr.asm -o isr.o

clean:
	rm -f *.o *.bin *.img *.map
