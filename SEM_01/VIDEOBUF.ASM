.model tiny
.186
.code

VIDEOSEG	equ 0b800h

org 100h
Start:		mov cl, 'A'
		mov ch, 4
		mov bx, 0804h
		call SetChar
		
		;jmp $
		
		mov ax, 4c00h
		int 21h


; void SetChar(cl:char letter, ch: char attrs, bh:unsigned row, bl:unsigned column)
SetChar		proc near
		mov ax, 40h
		mov es, ax
		mov ax, es:4ah  ; 80 most often
		mul bh
		xor bh, bh
		add bx, ax
		shl bx, 1
		
		mov dx, VIDEOSEG
		int 11h
		xor ax, 30h
		shl ax, 11
		or ax, dx
		mov es, ax
		
		mov es:[bx], cx
		
		ret
SetChar		endp



.data

Msg		db 'This program works even in bare BIOS. Crazy, right?', 00h


end Start