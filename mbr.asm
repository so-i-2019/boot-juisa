; o que fazer:
; 	função de printar string - oks!
; 	função de ler int - ok!
; 	função printar int - ok(?)
; 	busca binaria
; 	funcionar

	org 0x7c00

	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp init

;Strings 
welcome: 	db 'Think of a number from 1 to 1000. We will easily guess it', 0xd, 0xa, 0x0 
intro: 		db 'Type 0 if its just right, 1 if the number is too low, and 2 if its too high', 0xd, 0xa, 0x0
guess:		db 'I bet you the number you were thinking is '
final: 		db 'I told it would be easy!', 0xd, 0xa, 0x0
new_line:	db 0xd, 0xa, 0x0

init:	
	mov 	ah, 0xe		; Configure BIOS teletype mode
	
	mov		bx, welcome
	call 	print_string 
	
	mov		bx, intro
	call 	print_string 
	
	mov 	bx, 0		; May be 0 because org directive.

;; ---------------------------------------
;; ---- Prints some string ----------------
;; parameters:
;;	bx: string address
;; ---------------------------------------
print_string:
	push 	bx
	push 	cx
	
	jmp 	loop_print

loop_print:
	mov 	cl, [bx]
	
	cmp 	cl, 0x0
	je 		end_loop_print

	call 	put_char
	add 	bx, 0x1
	
	jmp 	loop_print

end_loop_print:
	pop 	cx
	pop 	bx
	ret

;; ---------------------------------------
;; ---- Prints one char ----------------
;; ---------------------------------------
put_char:
	push 	ax

	mov 	ah, 0x0e
	mov 	al, cl
	int 	0x10

	pop 	ax
	ret

print_digit:
	push 	cx

	add 	cx, '0'
	call 	put_char

	pop 	cx
	ret

print_int:
	push 	ax
	push 	bx
	push 	cx
	push 	dx

	mov 	dx, -1
	push 	dx

print_int_loop:
	cmp 	cx, 0x0
	je 		print_int_end

	mov 	dx, 0x0
	mov 	bx, 0xa		;; denominador
	mov 	ax, cx		;; numerador

	div 	bx

	mov 	bx, cx
	mov 	cx, dx

	push 	cx

	mov 	cx, ax
	jmp 	loop_print_int
	
print_int_end:
	pop 	cx

	cmp 	cx, -1
	je 		reverse_int

	call 	print_digit
	jmp 	print_int_end

reverse_int:
	mov 	bx, new_line
	call 	print_string
	
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
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
;-----eax, o chute, cx o low, dx o high--------
;---------------------------------------------
binary_search:
	mov 	eax, cx
	add 	eax, dx
	mov 	edx, 0x0
	mov 	ax, 0x2
	div 	ax
	mov 	ax, eax

end:				; Jump forever (same as jmp end)
	jmp $

times 510 - ($-$$) db 0	; Pad with zeros
dw 0xaa55		; Boot signatures