all:
	nasm -f bin ./../bootloader/boot.asm -o ./boot.bin
	dd if=./../bootloader/SECTOR_TWO_DATA >> ./boot.bin
	dd if=/dev/zero bs=512 count=0 >> ./boot.bin
