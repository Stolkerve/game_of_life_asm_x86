build:
	nasm -g -f elf64 -o main.o main.asm
	ld -o main main.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -L./raylib -lraylib -lm
