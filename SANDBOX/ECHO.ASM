.model tiny
.code

		org 100h
Start:		jmp Start2		
		db ', but most of all, Samy is my hero.', 0ah, 0dh, '$'

Start2:		mov ah, 09h
		mov dx, 81h
		int 21h
		
		mov ax, 4c00h
		int 21h

End Start
