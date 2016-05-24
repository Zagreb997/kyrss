.model small
.386
.stack 3000h
.data
	head		db "<<Search>>", endl, 0
	str_fin		db '1. File input (F/f)', endl, 0
	str_cin		db '2. Console input (C/c)', endl, 0
	str_n		db 'n = ', 0
	str_id		db '   Invalid data!!!', endl, 0
	str_nf		db '   Not found!!!', endl, 0
	exit_tab	db endl, '   Enter ESC for exit', endl, 0
	str_arr_beg	db 'arr[', 0
	str_arr_end	db '] = ', 0
	str_value	db 'value = ', 0
	file_err	db 'not exist!!!', endl, 0
	prompt		db 'file: ', 0
	str_save	db 'Save in file y/n  :  ', 0
	
	;str_endl	db 0ah, 0dh, 0
	len			dw ?
	n			dw 0
	value		dw 0
	arr			dw ?
	handle		dw ?
	
	file_name	db 80 dup(0)
	arr_out		db 80 dup(0)
	tmp 		db 80 dup(0)
.code

LOCALS

include arr_io.inc

;============================
cmpnum proc c
	arg @a, @b
	uses bx, si
	mov si, @a
	mov ax, word ptr[si]
	mov si, @b
	mov bx, word ptr[si]
	cmp ax, bx
	je @@ecv
	jl @@less
	mov ax, 1
	jmp @@end
@@ecv:
	xor ax, ax
	jmp @@end
@@less:
	mov ax, -1
@@end:
	ret
cmpnum endp
;============================

;============================
; void search(const void *searchkey, const void *arr, size_t arr_len, size_t size_elem, int (*funccompar)(const void *, const void *))
search proc c
	arg @searchkey, @arr, @arr_len, @size_elem, @comparator
	uses bx, cx, dx, si
	mov bx, @searchkey
	xor cx, cx
	mov dx, @size_elem
	mov si, @arr
@@cycle:
	cmp cx, @arr_len
	je @@not_found
	push bx
	push si
	mov ax, @comparator
	call ax
	add sp, 4
	cmp ax, 0
	jne @@ns
	mov ax, si
	ret
@@ns:
	inc cx
	add si, dx
	jmp @@cycle
@@not_found:
	mov ax, -1
	ret
search endp
;============================

;============================
file_save proc c
	uses ax
	puts str_save
@@fsave:
	call _getch
	cmp al, 'y'
	je @@save
	cmp al, 'Y'
	je @@save
	cmp al, 'n'
	je @@end
	cmp al, 'N'
	je @@end
	jmp @@fsave
	
@@save:
	putc endl
	putc endl
	puts prompt
	
	push offset file_name
	call gets
	add sp, 2
	
	push WO
    push offset file_name
    call fopen
    add sp, 4
	
	mov handle, ax
	
	push 10
	push offset tmp
	push n
	call itoa
	add sp, 6
	
	push handle
	push offset tmp
	call fputs
	add sp, 4
	
	fputc endl, handle
	
	push handle
	push n
	push arr
	call arr_ifout
	add sp, 6
	
	push handle
	call fclose
	add sp, 2
	
@@end:
	putc endl
	putc endl
	ret
file_save endp
;============================

;============================
main proc
    mov ax, @data
    mov ds, ax

@@beg_app:

; menu
	puts head
	putc endl
	puts str_fin
	puts str_cin
	puts exit_tab
@@check_input:
	call _getch
	cmp al, 31h
	je @@fin
	cmp al, 'f'
	je @@fin
	cmp al, 'F'
	je @@fin
	cmp al, 32h
	je @@cin
	cmp al, 'c'
	je @@cin
	cmp al, 'C'
	je @@cin
	cmp ah, 1
	jne @@check_input
	_exit
	
; file input
@@fin:
	putc endl
	puts prompt
	push offset file_name
	call gets
	putc endl
	putc endl
	
	push RO
    push offset file_name
    call fopen
    add sp, 4
	
	test ax, ax
    jne @@ns2
	putc ' '
	putc ' '
	putc ' '
	putc '"'
	puts file_name
	putc '"'
	putc ' '
	puts file_err
	putc endl
	jmp @@beg_app
	
@@ns2:
	mov handle, ax
	
	push offset tmp
	push handle
	call ifin
	add sp, 4
	
	cmp bl, 0
	je @@ns3					; file open
	
	; error
	puts str_id
	jmp @@beg_app
	
@@ns3:
	mov n, ax
	
	add ax, ax
	mov len, ax
	sub sp, ax
	mov arr, sp
	
	puts str_n
	puts tmp
	putc endl
	putc endl
	
	push handle
	push n
	push arr
	call arr_ifin
	add sp, 6
	
	push ax
	putc endl
	pop ax
	
	cmp al, 0
	je @@alg
	
	; error
	putc endl
	puts str_id
	
	; memory free
	add sp, n
	add sp, n
	
	; goto @@beg_app
	jmp @@beg_app
	
; console input
@@cin:
	putc endl

	push offset str_n
	call icin
	add sp, 2
	mov n, ax
	
	
	; reserved memory
	add ax, ax
	mov len, ax
	sub sp, ax
	mov arr, sp
	
	putc endl
	
	; input arr
	push n
	push arr
	call arr_icin
	add sp, 4
	
	putc endl
	
	push n
	push arr
	call arr_icout
	add sp, 4
	putc endl

	call file_save
	
@@alg:
	; input search value
	push offset str_value
	call icin
	add sp, 2
	mov value, ax
	
	; search
	push offset cmpnum
	push 2
	push n
	push arr
	push offset value
	call search
	add sp, 10
	
	cmp ax, -1
	je @@ns1					; value not found
	
	push ax
	putc endl
	puts str_arr_beg
	pop ax
	
	sub ax, arr
	mov bl, 2
	div bl
	cbw
	
	push 10
	push offset tmp
	push ax
	call itoa
	add sp, 6
	puts tmp
	
	puts str_arr_end
	
	push 10
	push offset tmp
	push value
	call itoa
	add sp, 6
	puts tmp
	
	putc endl
	putc endl
	jmp @@end
	
@@ns1:
	; value not found
	putc endl
	puts str_nf
	
@@end:
	; memory free
	add sp, n
	add sp, n
	
@@end_app:
	_exit
main endp
;============================
end main