.model tiny
.code

org 100h
Start:		mov ax, 0900h
		mov bx, 0004h
		mov cx, 80	; I know I could have done that inside the loop for every character, but that would slow it down a lot
		int 10h
		
		lea si, [Msg]
		call BPrint
		
		mov ax, 4c00h
		int 21h


; void BPrint(esi:char *src)
BPrint 		proc near
		mov ah, 0eh
		
BPrint_loop_start:
		mov al, [si]
		test al, al
		jz BPrint_loop_end
		int 10h
		inc si
		jmp BPrint_loop_start
		
BPrint_loop_end:
		ret
BPrint 		endp



.data

Msg		db 'This program works even in bare BIOS. Crazy, right?', 0ah, 0dh, 00h


end Start