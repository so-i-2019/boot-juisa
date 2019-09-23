;; Copyright (c) 2019 - 
;;			João Guilherme Madeira Araujo, 
;;			Luísa Souza Moura, 10692179
;;
;; This is free software and distributed under GNU GPL vr.3. Please 
;; refer to the companion file LICENSING or to the online documentation
;; at https://www.gnu.org/licenses/gpl-3.0.txt for further information.


	bits 16
	org 0x7c00

	xor 	ax, ax
	mov 	ds, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	gs, ax
	jmp 	init

;; ---------------------------------------
;; Strings
;; ---------------------------------------
welcome: 	db 'Think of a number from 1 to 65000. We will easily guess it', 0xd, 0xa, 0x0 
intro: 		db 'Type 0 if its just right, 1 if your number is smaller, and 2 if its greater', 0xd, 0xa, 0x0
guess:		db 'I bet you the number you were thinking is '
final: 		db 'I told you it would be easy!', 0xd, 0xa, 0x0
new_line:	db 0xd, 0xa, 0x0


;; ---------------------------------------
;; Main function
;; ---------------------------------------
init:
	mov 	ah, 0xe				; Configure BIOS teletype mode
	
	mov		bx, welcome			; Load welcome string
	call 	print_string 		; Call print function
	
	mov		bx, intro			; Load intro string
	call 	print_string		; Call print function
	
	mov		cx, 0x0				; Initialize left pointer (0)
	mov		dx, 0xffff			; Initialize right pointer (65536)
	call	binary_search		; Call binary search

	mov 	bx, 0				; May be 0 because org directive.
	jmp 	stop				; The end


;; ---------------------------------------
;; Print a string
;; ---------------------------------------
print_string:
	push 	ax					; Store ax in the stack
	push 	bx					; Store bx in the stack
	
	jmp 	loop_print

loop_print:
	mov 	al, [bx]			; Store [bx] in al
	
	cmp 	al, 0x0				; Compare al and 0
	je 		end_loop_print		; If al == 0, the loop ends

	call 	put_char			; Print one character
	add 	bx, 0x1				; Add 1 to bx
	
	jmp 	loop_print			; Loop to print next char

end_loop_print:
	pop 	bx					; Recover bx from stack
	pop 	ax					; Recover ax from stack
	ret

;; ---------------------------------------
;; Print one character
;; ---------------------------------------
put_char:
	push 	ax					; Store ax in the stack

	mov 	ah, 0x0e			; Print ax
	int 	0x10

	pop 	ax					; Recover ax from stack
	ret

;; ---------------------------------------
;; Print an integer
;; ---------------------------------------
print_int:
push	ax					; Store ax in the stack
	push 	cx					; Store bx in the stack

	mov		cx, 0x2710 			; Initialize 10000 in cx
	call 	print_int_loop		; Start printing

	push 	bx					; Store bx in the stack
	mov 	bx, new_line		; Load new_line string
	call	print_string		; Call print string
	
	pop 	bx					; Recover bx from stack
	pop		cx					; Recover cx from stack
	pop 	ax					; Recover ax from stack
	ret

print_int_loop:
	push	ax					; Store ax in the stack
	
	mov		bx, cx				; Copy value of mod to bx
	call 	divide				; Divide ax and bx
	call 	mod					; Calculate mod, to get the number to print (in bx)

	add		bx, '0'				; Int to char
	mov		ax, bx				; Copy char to ax
	call 	put_char			; Print char
	
	mov		bx, 0xa				; Divide mod by 10
	mov		ax, cx
	call 	divide
	mov 	cx, ax

	pop 	ax					; Recover ax from stack

	cmp		cx, 0x0				; Compare mod and 0
	jne		print_int_loop		; If they're equal, done printing number
	ret


;; ---------------------------------------
;; Divide to numbers (ax = ax/bx)
;; ---------------------------------------
divide:
	push 	dx					; Store dx in the stack

	mov		dx, 0x0				; Reset dx
	div 	bx					; Divide ax by bx

	pop 	dx					; Recover dx from stack
	ret


;; ---------------------------------------
;; Get mod (ax - floor(ax/cx) * cx)
;; ---------------------------------------
mod:
	push	ax					; Store ax in the stack
	push	cx					; Store cx in the stack
	push	dx					; Store dx in the stack

	mov		bx, ax				; Copy ax to bx
	mov		cx, 0xa				; Initialize cx = 10

	mov		dx, 0x0				; Reset dx
	div		cx					; ax = ax/cx
	
	mov		dx, 0x0				; Reset dx
	mul		cx					; ax = ax * cx

	sub		bx, ax				; bx = bx - ax

	pop		dx					; Recover dx from stack
	pop		cx					; Recover cx from stack
	pop		ax					; Recover ax from stack
	ret


;; ---------------------------------------
;; ---- Read one int from stdin ----------
;; ---------------------------------------
get_int:
	push 	ax					; Store ax in the stack
	push	cx					; Store cx in the stack
	mov		bx, 0x0				; Initialize bx = 0

get_int_loop:
	mov		ah, 0x0				; Get char
	int		0x16				; Interruption
	
	cmp		al, 0xe				; al = 14
	jl		get_int_end			; Number is over

	mov		ah, 0xe				
	int		0x10				; Interruption

	movzx	cx, al				; Copy al to cx
	sub		cx, '0'				; Char to integer
	imul	bx, 0xa				; Multiplies bx by 10
	add		bx, cx				; bx = bx + cx

	jmp 	get_int_loop

get_int_end:
	push 	bx					; Store bx in the stack
	mov 	bx, new_line		; Load new_line string
	call	print_string		; Call print string
	
	pop 	bx					; Recover bx from stack
	pop 	cx					; Recover cx from stack
	pop 	ax					; Recover ax from stack
	
	ret

;---------------------------------------------
; Binary search
; mid = ax; cx = left; dx = right
;---------------------------------------------
binary_search:
	mov		ax, cx				; mid = left
	add		ax, dx				; mid += right 
	mov 	bx, 0x2				; Initialize bx = 2

	call	divide				; mid /= 2
	call	print_int			; Print mid

	call	get_int				; Get number from stdin

	cmp		bx, 0x0				; bx = 0
	je	 	rigthAns			; if bx == 0, number was guessed
	
	cmp		bx, 0x1				; bx = 1
	je		tooMuch				; bx == 1, number was too big

	jmp		tooLittle			; else, number was too small

tooMuch:
	mov		dx, ax				; right = mid
	sub		dx, 0x1				; mid -= 1
	jmp		binary_search		; Continue binary search

tooLittle:
	mov		cx, ax				; left = mid
	add		cx, 0x1				; mid += 1
	jmp		binary_search		; Continue binary search

rigthAns:
	mov		bx, final			; Load final string
	call	print_string		; Call print function
	ret


stop:
	jmp stop					; The end \o/


times 510 - ($-$$) db 0			; Pad with zeros
dw 0xaa55						; Boot signatures