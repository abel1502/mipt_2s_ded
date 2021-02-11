.model tiny
.code

org 100h
Start:		int 0h
		
		mov al, 123
		mov ah, 0
		div ah
		
		mov ah, 09h
		mov dx, offset Msg
		int 21h

		mov ax, 4c00h
		int 21h

.data

Msg:		db 'Nope.', 0ah, 0dh, '$'

End Start
