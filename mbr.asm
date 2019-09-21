; o que fazer:
; 	função de printar string - oks!
; 	função de ler int - ok!
; 	função printar int - ok(?)
; 	busca binaria
; 	funcionar

	org 0x7c00

	xor 	ax, ax
	mov 	ds, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	gs, ax
	jmp 	init

;Strings 
welcome: 	db 'Think of a number from 1 to 65000. We will easily guess it', 0xd, 0xa, 0x0 
intro: 		db 'Type 0 if its just right, 1 if your number is smaller, and 2 if its greater', 0xd, 0xa, 0x0
guess:		db 'I bet you the number you were thinking is '
final: 		db 'I told you it would be easy!', 0xd, 0xa, 0x0
new_line:	db 0xd, 0xa, 0x0


init:
	mov 	ah, 0xe		; Configure BIOS teletype mode
	
	mov		bx, welcome
	call 	print_string 
	
	mov		bx, intro
	call 	print_string
	
	mov		cx, 0x0
	mov		dx, 0xffff
	call	binary_search

	mov 	bx, 0		; May be 0 because org directive.
	jmp 	stop

;; ---------------------------------------
;; ---- Prints some string ----------------
;; parameters:
;;	bx: string address
;; ---------------------------------------
print_string:
	push 	ax
	push 	bx
	
	jmp 	loop_print

loop_print:
	mov 	al, [bx]
	
	cmp 	al, 0x0
	je 		end_loop_print

	call 	put_char
	add 	bx, 0x1
	
	jmp 	loop_print

end_loop_print:
	pop 	bx
	pop 	ax
	ret

;; ---------------------------------------
;; ---- Prints one char ----------------
;; ---------------------------------------
put_char:
	push 	ax

	mov 	ah, 0x0e
	int 	0x10

	pop 	ax
	ret

print_int:
	push	ax
	push 	cx

	mov		cx, 0x2710 ;10000 in hex, allows for printing 4 digit numbers
	call 	print_int_loop

	push 	bx
	mov 	bx, new_line
	call	print_string
	
	pop 	bx
	pop		cx
	pop 	ax
	ret

print_int_loop:
	push	ax
	
	mov		bx, cx
	call 	divide
	call 	mod

	add		bx, '0'
	mov		ax, bx
	call 	put_char	
	
	mov		bx, 0xa
	mov		ax, cx
	call 	divide
	mov 	cx, ax

	pop 	ax

	cmp		cx, 0x0
	jne		print_int_loop

	ret

; ax = ax/bx
divide:
	push 	dx

	mov		dx, 0x0
	div 	bx

	pop 	dx
	ret

mod:
	push	ax
	push	cx
	push	dx

	mov		bx, ax
	mov		cx, 0xa

	mov		dx, 0x0
	div		cx
	
	mov		dx, 0x0
	mul		cx

	sub		bx, ax

	pop		dx
	pop		cx
	pop		ax
	ret

;; ---------------------------------------
;; ---- Read one int from stdin ----------
;; ---------------------------------------
get_int:
	push 	ax
	push	cx
	mov		bx, 0x0

get_int_loop:
	mov		ah, 0x0
	int		0x16
	
	cmp		al, 0xd
	jl		get_int_end

	mov		ah, 0xe
	int		0x10

	movzx	cx, al
	sub		cx, '0'
	imul	bx, 0xa
	add		bx, cx

	jmp 	get_int_loop

get_int_end:
	pop 	cx
	pop 	ax
	
	ret

;---------------------------------------------
;-----ax o chute, cx o low, dx o high---------
;---------------------------------------------
binary_search:
	mov		ax, cx
	add		ax, dx
	mov 	bx, 0x2

	call	divide
	call	print_int

	call	get_int

	cmp		bx, 0x0
	je	 	rigthAns
	
	cmp		bx, 0x1
	je		tooMuch

	jmp		tooLittle

tooMuch:
	mov		dx, ax
	sub		dx, 0x1
	jmp		binary_search

tooLittle:
	mov		cx, ax
	add		cx, 0x1
	jmp		binary_search

rigthAns:
	mov		bx, final
	call	print_string
	ret

stop:
	jmp stop

print_debug:


times 510 - ($-$$) db 0	; Pad with zeros
dw 0xaa55		; Boot signatures