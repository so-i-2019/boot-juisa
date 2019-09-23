;; Copyright (c) 2019 - 
;;			João Guilherme Madeira Araujo, 9725165
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
	mov		esp, 0x8000
	; mov		sp, 0x8000
	jmp 	init

;; ---------------------------------------
;; Strings
;; ---------------------------------------
welcome: 	db 'Think of a number from 0 to 32000. We will easily guess.', 0xd, 0xa, 0x0 
intro: 		db 'Type 0 if its just right, 1 if your number is smaller or 2 if its greater', 0xd, 0xa, 0x0
guess:		db 'I bet you the number you thought is ', 0xd, 0xa, 0x0
final: 		db 'I told you it would be easy!', 0xd, 0xa, 0x0
error_str: 	db 'a', 0xd, 0xa, 0x0
new_line:	db 0xd, 0xa, 0x0


;; ---------------------------------------
;; Main function
;; ---------------------------------------
init:
	mov		bx, welcome			; Load welcome string
	call 	print_string 		; Call print function
	
	mov		bx, intro			; Load intro string
	call 	print_string		; Call print function
	
	mov		cx, 0x0				; Initialize left pointer (0)
	mov		dx, 0x07d00			; Initialize right pointer (65536)
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
    push	ax					; Store ax in the stack
    push	cx					; Store cx in the stack
	push	dx					; Store dx in the stack
    mov		bx, 0				

get_int_loop:
    mov		ah, 0x0
    int		0x16    			; Reads a single character from the keyboard

    cmp		al, 14  			; Checks if char is '\n'
    jl		get_int_end

    mov		ah, 0xe 			; Immediately prints it on screen (didn't call printChar because it's already in al)
    int		0x10

    movzx	dx, al				; Stores read digit in dx (zero-extendension from 8 to 16 bits)
    sub		dx, '0' 			; Transforms ASCII into integer (not checking if it is between '0' and '9')

    imul	bx, 0xA				; Multiplies the number being read by 10 so that newly read int can be added

    add		bx, dx  			; Adds digit that was just read

    jmp		get_int_loop

get_int_end:
	push	bx					; Store bx in the stack
	mov 	bx, new_line		; Load new_line string
	call	print_string		; Call print string
	
	pop		bx					; Recover bx from stack
	pop 	dx					; Recover dx from stack
	pop		cx					; Recover cx from stack
    pop		ax					; Recover ax from stack
    ret

;---------------------------------------------
; Binary search
; mid = ax; cx = left; dx = right
;---------------------------------------------
binary_search:
	mov		ax, cx				; mid = left
	add		ax, dx				; mid += right
	mov 	bx, 0x2			; Initialize bx = 2

	call	divide				; mid /= 2

	mov	 	bx, guess			; Load guess string
	call	print_string		; Call print function

	call	print_int			; Print mid

	call	get_int				; Get number from stdin

	cmp		bx, 0x0				; bx = 0
	je	 	rigthAns			; if bx == 0, number was guessed
	
	cmp		bx, 0x1				; bx = 1
	je		tooMuch				; bx == 1, number was too big
	
	cmp		bx, 0x2				; bx = 2
	je		tooLittle			; bx == 2, number was too small

	jmp 	error

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

error:
	mov	 	bx, error_str		; Load error string
	call	print_string		; Call print function
	jmp 	stop				; Jump to the end

stop:
	jmp stop					; The end \o/


times 510 - ($-$$) db 0			; Pad with zeros
dw 0xaa55						; Boot signatures