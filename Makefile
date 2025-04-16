all: os-image

os-image: boot.bin loader_padded.bin kernel.bin
	cat boot.bin loader_padded.bin kernel.bin > os-image.img

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

loader.bin: loader.asm
	nasm -f bin loader.asm -o loader.bin

loader_padded.bin: loader.bin
	dd if=loader.bin of=loader_padded.bin bs=1024 count=1 conv=sync

kernel.o: kernel.c
	gcc -m32 -ffreestanding -fno-pic -nostdlib -nostartfiles -nodefaultlibs -c kernel.c -o kernel.o

kernel.bin: kernel.o isr.o
	ld -m elf_i386 -T link.ld -o kernel.bin kernel.o isr.o

isr.o: isr.asm
	nasm -f elf32 isr.asm -o isr.o

clean:
	rm -f *.o *.bin *.img
