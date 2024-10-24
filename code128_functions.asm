img_width		EQU 0
img_height		EQU 4
img_linebytes	EQU 8
img_bitsperpel	EQU 12
img_pImg		EQU	16

section	.text

global draw_pattern

global draw_stop

global fill_white


; =========================================================
; draw_pattern - draws lines according to the given pattern
; arguments:
; 	rdi - pImg pointer
; 	rsi - x coordinate
; 	rdx - pattern
; 	rcx - lineWidth
; return value: rdi pointer
; =========================================================
draw_pattern:
    push 	rbp
    mov 	rbp, rsp
	mov 	r8, rdi
	mov 	r9, rcx
	mov		ecx, esi		; x
	mov 	bl, r9b			; line width
	mov 	bh, 11			; counter

pattern_mask:
	mov 	r8d, edx		; copy pattern
	and 	r8d, 0x400		; apply mask
	jnz		pattern_draw_black ; draw if edi != 0

pattern_skip_white:
	inc 	ecx
	dec 	bl
	jnz 	pattern_skip_white
	jmp		shift_pattern

pattern_draw_black:
	call 	draw_line
	inc		ecx
	dec 	bl
	jnz		pattern_draw_black

shift_pattern:
	dec 	bh
	jz 		draw_pattern_exit ; exit if counter == 0
	mov 	bl, r9b			; reset line width
	shl 	rdx, 1			; next bit
	jmp 	pattern_mask

draw_pattern_exit:
    mov 	rax, r8
    pop 	rbp
    ret

; =========================================================
; draw_stop - draws stop code lines
; arguments:
; 	rdi - pImg pointer
; 	rsi - x coordinate
; 	rdx - lineWidth
; return value: rdi pointer
; =========================================================

draw_stop:
    push 	rbp
    mov 	rbp, rsp
    mov 	rcx, rsi	; x
	mov 	r9, rdx
    mov 	bl, r9b	; line width
    mov 	edx, 0x18EB		; pattern
    mov 	bh, 13

stop_loop:
    test 	edx, 0x1000		; test if the highest bit is set
    jz 		stop_skip_white

stop_draw_black:
    call 	draw_line

stop_skip_white:
    inc 	ecx
    dec 	bl
    jnz 	stop_loop_continue

shift_stop:
    dec 	bh
    jz 		draw_stop_exit
    mov 	bl, r9b
    shl 	edx, 1

stop_loop_continue:
    jmp 	stop_loop

draw_stop_exit:
    mov 	rax, rdi
    pop 	rbp
    ret

; =========================================================
; draw_line - draws a single line
; arguments:
; 	rdi - pImg pointer
; 	ecx - x coordinate
; return value: none
; =========================================================

draw_line:
	push 	rsi
	push 	rcx
	push 	rdx
	push 	rbx
	mov 	ebx, ecx		; copy x coordinate
	mov 	esi, img_height[rdi]
	dec		esi

height_loop:
	mov 	ecx, ebx		; x
	mov 	edx, esi		; y

draw_pixel:
	mov 	eax, img_linebytes[rdi]
	mul 	edx

	mov 	edx, ecx
	shr 	edx, 3
	add 	eax, edx
	add 	eax, img_pImg[rdi]

	and 	ecx, 0x7
	mov 	ch, 0x80
	shr		ch, cl

    xor     [eax], ch

	dec 	esi
	test 	esi, esi
	jge 	height_loop ; if y < 0 exit

draw_line_exit:
	pop 	rbx
	pop 	rdx
	pop 	rcx
	pop 	rsi
	ret

; =========================================================
; fill_white - fills the given bmp file with white pixels
; arguments:
;	rdi - pImg pointer
; return value: pImg pointer
; =========================================================

fill_white:
	push 	rbp
    mov 	rbp, rsp
	push	rbx
	mov     rsi, rdi	; pImg
	mov 	edi, img_height[esi]
	dec		edi

reset_width:
	mov 	ebx, img_width[esi]
	dec 	ebx

fill_loop:
	mov 	ecx, ebx		; x
	mov 	edx, edi		; y

white_pixel:
	mov 	eax, img_linebytes[esi]
	mul 	edx

	mov 	edx, ecx
	shr 	edx, 3
	add 	eax, edx
	add 	eax, img_pImg[esi]

	and 	ecx, 0x7
	mov 	ch, 0x80
	shr		ch, cl

    or     [eax], ch

	dec 	ebx
	test	ebx, ebx
	jge 	fill_loop		; if x < 0 fill next line

	dec 	edi
	test 	edi, edi
	jge 	reset_width 	; if y < 0 exit

fill_white_exit:
	mov 	rax, rsi
	pop 	rbx
    pop 	rbp
    ret

  