.model tiny
.code

VIDEOSEG	equ 0b800h

org 100h
Start:		lea si, [Msg]
		mov bx, 0804h
		call RPrint
		
		;jmp $
		
		mov ax, 4c00h
		int 21h


; void RPrint(esi:char *src, bh:unsigned row, bl:unsigned column)
RPrint 		proc near
		mov al, 80
		mul bh
		xor bh, bh
		add bx, ax
		shl bx, 1
		
		mov cx, VIDEOSEG
		int 11h
		xor ax, 30h
		shl ax, 11
		or ax, cx
		mov es, ax
		
RPrint_loop_start:
		mov al, [si]
		test al, al
		jz RPrint_loop_end
		
		; Not gonna implement newlines here
		
		mov es:[bx], al
		inc bx
		mov byte ptr es:[bx], 4
		inc bx
		
		inc si
		jmp RPrint_loop_start
		
RPrint_loop_end:
		ret
RPrint 		endp



.data

Msg		db 'This program works even in bare BIOS. Crazy, right?', 00h


end Start