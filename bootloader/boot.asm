ORG 0x7c00
BITS 16

BOOT_SEG_ADDR equ 0x0
BOOT_STACK_SEG_ADDR equ 0x0
BOOT_STACK_OFFSET equ 0x7c00
BIOS_PARM_BLK_SZ equ 33
READ_SECTOR_CMD equ 2
NUM_SECTORS equ 1
CYL_NUM_LOW equ 0
SECTOR_NUMBER equ 2
HEAD_NUM equ 0
DRIVE_NUM equ 1
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
	jmp short start
	nop

times BIOS_PARM_BLK_SZ db 0

start:
	jmp BOOT_SEG_ADDR:label
label:
	cli ; Clear interrupts
	mov ax, BOOT_SEG_ADDR
	mov ds, ax
	mov es, ax
	mov ax, BOOT_STACK_SEG_ADDR
	mov ss, ax
	mov sp, BOOT_STACK_OFFSET
	sti ; Enable interrupts
 	call read_second_sector
	cmp ax, 00
	je print_hd_data
	mov si, CONSOLE_ERR_MSG
	jmp print_msg
print_hd_data:
	mov si, second_sector
print_msg:
	call print_message

.load_protected:
	cli
	lgdt[gdt_desc]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32

; GDT descriptor
gdt_start:
gdt_null:
	dq 0
gdt_code:
	dw 0xffff
	dw 0
	db 0
	db 0x9a
	db 11001111b
	db 0
gdt_data:
	dw 0xffff
	dw 0
	db 0
	db 0x92
	db 11001111b
	db 0
gdt_end:

gdt_desc:
	dw gdt_end - gdt_start -1
	dd gdt_start

read_second_sector:
	mov ah, READ_SECTOR_CMD
	mov al, NUM_SECTORS
	mov ch, CYL_NUM_LOW
	mov cl, SECTOR_NUMBER
	mov dh, HEAD_NUM
	;mov dl, DRIVE_NUM already set
	mov bx, second_sector
	int 0x13
	jc preset
	xor ax, ax
	jmp return
preset:
	mov ax, 01
return:
	ret

print_message:
	mov bx, 0
.loop:
	lodsb
	cmp al, 0
	je .end
	call print_character
	jmp .loop
.end:
	ret

print_character:
	mov ah, 0eh
	mov bl, 02
	int 0x10
	ret

CONSOLE_ERR_MSG: db 'LOADING DISK FAILED ...', 0

[BITS 32]
load32:
	jmp $

times 510 - ($ - $$) db 0
dw 0xAA55

second_sector:
