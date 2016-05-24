; module for input/output array

include io.inc

;============================
str_arr proc c
	arg @str, @num, @beg, @end
	uses ax
	push @beg
	push @str
	call strcpy
	add sp, 4
	push 10
	push offset tmp
	push @num
	call itoa
	add sp, 6
	push offset tmp
	push @str
	call strcat
	add sp, 4
	push @end
	push @str
	call strcat
	add sp, 4
	ret
str_arr endp
;============================

;============================
arr_icin proc c
	arg @arr, @n
	uses bx, cx
	mov bx, @arr
	xor cx, cx
@@cycle:
	cmp cx, @n
	je @@end
	push offset str_arr_end
	push offset str_arr_beg
	push cx
	push offset arr_out
	call str_arr
	add sp, 8
	push offset arr_out
	call icin
	add sp, 2
	mov word ptr[bx], ax
	add bx, 2
	inc cx
	jmp @@cycle
@@end:
	ret
arr_icin endp
;============================

;============================
arr_ifin proc c
	arg @arr, @n, @handle
	uses bx, cx, dx, si
	
	sub sp, 80
	mov dx, sp
	
	mov si, @arr
	xor cx, cx
	
	push dx
	push @handle
	
	putc ' '
	putc ' '
	putc ' '
	putc '{'
	
@@cycle:
	cmp cx, @n
	je @@end
	call ifin
	cmp bl, 0
	je @@ns
	putc endl
	add sp, 84
	mov ax, 1
	ret
@@ns:
	mov [si], ax
	puts dx
	putc ','
	putc ' '
	add si, 2
	inc cx
	jmp @@cycle
	
@@end:
	add sp, 84
	putc 8
	putc 8
	putc '}'
	putc endl
	xor ax, ax
	ret
arr_ifin endp
;============================

;============================
arr_icout proc c
	arg @arr, @n
	uses ax, bx, cx, dx
	putc ' '
	putc ' '
	putc ' '
	putc '{'
	sub sp, 10
	mov dx, sp
	mov bx, @arr
	mov cx, @n
@@cycle:
	cmp cx, 0
	je @@end
	push 10
	push dx
	push [bx]
	call itoa
	add sp, 6
	puts dx
	putc ','
	putc ' '
	add bx, 2
	dec cx
	jmp @@cycle
@@end:
	add sp, 10
	putc 08h
	putc 08h
	putc '}'
	putc endl
	ret
arr_icout endp
;============================

;============================
arr_ifout proc c
	arg @arr, @n, @handle
	uses ax, bx, cx, dx
	
	sub sp, 10
	mov dx, sp
	
	xor cx, cx
	mov bx, @arr
	
	push 10
	push dx
	
@@cycle:
	cmp cx, @n
	je @@end
	
	push [bx]
	call itoa
	add sp, 2
	
	push @handle
	push dx
	call fputs
	add sp, 4
	
	fputc ' ', @handle
	
@@ns:
	inc cx
	add bx, 2
	jmp @@cycle
	
@@end:
	fputc endl, @handle
	ret
arr_ifout endp
;============================