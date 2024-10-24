CC=gcc
ASMBIN=nasm

code128 : image_test.o image.o code128_functions.o

code128_functions.o : code128_functions.asm
	$(ASMBIN) -o code128_functions.o -f elf64 -g -F dwarf code128_functions.asm

image.o : image.h image.c
	$(CC) -m64 -c -g -O0 image.c

image_test.o : image.h image_test.c
	$(CC) -m64 -c -g -O0 image_test.c

code128 : image_test.o image.o code128_functions.o
	$(CC) -no-pie -m64 -g -o code128 image_test.o image.o code128_functions.o

clean :
	rm *.o
	rm code128