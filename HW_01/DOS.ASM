.model tiny
.code

org 100h
Start:		lea si, [Msg]
		call DPrint
		
		mov ax, 4c00h
		int 21h


; void DPrint(esi:char *src)
DPrint		proc near
		mov ah, 2h
		
DPrint_loop_start:
		mov dl, [si]
		test dl, dl
		jz DPrint_loop_end
		int 21h
		inc si
		jmp DPrint_loop_start
		
DPrint_loop_end:
		ret
DPrint		endp


.data

Msg		db 'This program CAN (and should) be run in DOS mode', 0ah, 0dh, 00h


End Start
