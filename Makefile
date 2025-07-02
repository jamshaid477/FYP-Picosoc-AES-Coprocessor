# This is free and unencumbered software released into the public domain.

CROSS_COMPILE = riscv64-unknown-elf-
CC = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

CFLAGS = -march=rv32im_zk -mabi=ilp32 -nostdlib -ffreestanding
LDFLAGS = -T linker.ld -nostdlib -Wl,-m,elf32lriscv

all: program.hex

program.o: program.S aes_common.S
	$(CC) $(CFLAGS) -c program.S -o program.o

program.elf: program.o linker.ld
	$(CC) $(LDFLAGS) program.o -o program.elf

program.bin: program.elf
	$(OBJCOPY) -O binary program.elf program.bin

program.hex: program.bin
	od -An -tx4 -w4 -v program.bin > program.hex

clean:
	rm -f program.o program.elf program.bin program.hex

.PHONY: all clean
