.model tiny
.386
.code

org 100h
Start:
		call checkLicense
		
		test ax, ax
		jnz badLic

goodLic:	
		mov ah, 40h
		xor bx, bx
		inc bx
		mov cx, GoodMsgLen
		mov dx, offset GoodMsg
		int 21h
		
		jmp progEnd
		
badLic:		
		mov ah, 40h
		xor bx, bx
		inc bx
		mov cx, BadMsgLen
		mov dx, offset BadMsg
		int 21h
		
		
progEnd:	mov ax, 4c00h
		int 21h
		ret


; Non-zero means wrong license
; bool checkLicense()
checkLicense	proc near

PasswdBufLen	equ 40h
CharBuf		equ [bp-2-PasswdBufLen-1]
PasswdBuf	equ [bp-2-PasswdBufLen]
Canary		equ [bp-2]
CanaryVal	equ 0B1ADh
		
		push bp
		mov bp, sp
		sub sp, PasswdBufLen + 2 + 1
		
		call randomizeCanary

Canary_1:	; +3
		mov word ptr Canary, CanaryVal
		
		lea di, PasswdBuf
		call readPasswd
		cmp ax, PasswdLen
		je checkLicense_compare
		
		xor ax, ax
		inc ax
		jmp checkLicense_end
		
checkLicense_compare:
		
		lea di, PasswdBuf
		mov si, offset Passwd
		mov cx, PasswdLen
		
		cld
		repe cmpsb
		
		lahf
		neg ax
		shr ax, 6 + 8  ; ZF
		and al, 1
		
checkLicense_end:
		
		mov sp, bp
		pop bp
		ret
		
checkLicense	endp


; void readPasswd(di: char *buf)
readPasswd	proc near
		
		mov ah, 40h
		xor bx, bx
		inc bx
		mov cx, PromptLen
		mov dx, offset Prompt
		int 21h
		
		xor bx, bx
		xor cx, cx
		inc cx
		lea dx, CharBuf
		
		push di
		
readPasswd_loop:
		
		mov ah, 3fh
		int 21h
		
		mov al, [CharBuf]
		
		cmp al, 0ah  ; \n
		je readPasswd_loop_end
		cmp al, 0dh  ; \r
		je readPasswd_loop_end
		
		stosb
		
		jmp readPasswd_loop
		
readPasswd_loop_end:
		
		mov ax, Canary
Canary_2:	; +1
		cmp ax, CanaryVal
		je readPasswd_end
		
		mov ah, 40h
		xor bx, bx
		inc bx
		mov cx, CanaryMsgLen
		mov dx, offset CanaryMsg
		int 21h

readPasswd_end:
		pop ax
		sub ax, di
		neg ax
		
		ret
		
readPasswd	endp


; void randomizeCanary()
randomizeCanary	proc near
		
		mov ah, 2ch
		int 21h
		
		mov ax, dx
		shl ax, 7
		add al, dh
		xor ah, cl
		xor al, ch
		
		mov word ptr [Canary_1 + 3], ax
		mov word ptr [Canary_2 + 1], ax
		
		ret
		
randomizeCanary endp



.data

Passwd		db 'This aint no overflow!'
PasswdLen	equ $ - Passwd

GoodMsg		db 'Congratulations, you won, I guess...', 0ah, 0dh
GoodMsgLen	equ $ - GoodMsg

BadMsg		db 'Nope, try again.', 0ah, 0dh
BadMsgLen	equ $ - BadMsg

CanaryMsg	db 'Stack smashing detected (but whatever).', 0ah, 0dh
CanaryMsgLen	equ $ - CanaryMsg

Prompt		db 'Please enter your password: '
PromptLen	equ $ - Prompt

		
end Start
