; io

include src\stdio.inc
include src\ctype.inc

;============================
ifin proc c
	arg @handle, @str
	uses cx
	
	push @handle
	
@@cycle1:
	call fgetc
	push ax
	call isspace
	mov bx, ax
	pop ax
	cmp bx, 0
	jne @@cycle1
	
	mov bx, @str
	mov [bx], al
	inc bx
	
@@cycle2:
	call fgetc
	push ax
	call isspace
	mov cx, ax
	pop ax
	cmp cx, 0
	jne @@end_fin
	mov [bx], al
	inc bx
	jmp @@cycle2
	
@@end_fin:
	mov byte ptr[bx], 0
	push @str
	call atoi
	add sp, 4
	ret
ifin endp
;============================

;============================
icin proc c
	arg @s
	uses bx, dx
	
	sub sp, 80
	mov dx, sp
	mov dx, sp
	
	push dx
	
@@cycle:
	puts @s
	call gets
	putc endl
	call strlen
	cmp ax, 0
	je @@err
	call atoi
	cmp bl, 0
	je @@end
@@err:
	puts str_id
	jmp @@cycle
@@end:
	add sp, 82
	ret
icin endp
;============================