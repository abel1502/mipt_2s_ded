.model tiny
.186
.code

VIDEOSEG	equ 0b800h

org 100h
Start:		mov ax, 8h
		mov bx, 0909h
		mov cx, 0F46h
		
Main_loop:	test ax, ax
		jz Main_loop_end
		
		push ax
		push bx
		push cx
		call DrawFrame
		pop cx
		pop bx
		
		mov ax, 10000
		call Sleep
		
		pop ax
		
		dec bh
		dec bl
		inc ch
		inc cl
		
		dec ax
		jmp Main_loop
Main_loop_end:
		
		mov bx, 2000
		mov cx, 8
		call Beep
		
		mov bx, 100
Pause_loop:	test bx, bx
		jz Pause_loop_end
		
		mov ax, 0FFFFh
		call Sleep
		
		dec bx
		jmp Pause_loop
Pause_loop_end:
		
		mov ax, 4c00h
		int 21h


; void DrawFrame(bh: fromRow, bl: fromCol, ch: toRow, cl: toCol)
DrawFrame	proc near

DrawFrame_fromRow	equ [bp-1]
DrawFrame_fromCol	equ [bp-2]
DrawFrame_toRow		equ [bp-3]
DrawFrame_toCol		equ [bp-4]
		
		push bp
		mov bp, sp
		sub sp, 4
		
		mov DrawFrame_fromRow, bh
		mov DrawFrame_fromCol, bl
		mov DrawFrame_toRow, ch
		mov DrawFrame_toCol, cl
		
		;mov ax, ' '
		;call FillRect
		; There's a swifter way to achieve this
		mov ax, 0600h
		mov dx, cx
		mov cx, bx
		mov bh, 7h
		int 10h
		
		mov ch, 15
		mov cl, 201
		mov bh, DrawFrame_fromRow
		mov bl, DrawFrame_fromCol
		call SetChar
		
		mov ch, 15
		mov cl, 187
		mov bh, DrawFrame_fromRow
		mov bl, DrawFrame_toCol
		call SetChar
		
		mov ch, 15
		mov cl, 188
		mov bh, DrawFrame_toRow
		mov bl, DrawFrame_toCol
		call SetChar
		
		mov ch, 15
		mov cl, 200
		mov bh, DrawFrame_toRow
		mov bl, DrawFrame_fromCol
		call SetChar
		
		mov al, DrawFrame_fromCol
		xor ah, ah
		mov di, ax
		inc di
		
DrawFrame_loopH:
		mov al, DrawFrame_toCol
		xor ah, ah
		cmp di, ax
		jae DrawFrame_loopH_end
		
		mov ch, 15
		mov cl, 205
		mov bx, di
		mov bh, DrawFrame_fromRow
		call SetChar
		
		mov ch, 15
		mov cl, 205
		mov bx, di
		mov bh, DrawFrame_toRow
		call SetChar
		
		inc di
		jmp DrawFrame_loopH
DrawFrame_loopH_end:
		
		mov al, DrawFrame_fromRow
		xor ah, ah
		mov di, ax
		inc di
		
DrawFrame_loopV:
		mov al, DrawFrame_toRow
		xor ah, ah
		cmp di, ax
		jae DrawFrame_loopV_end
		
		mov ch, 15
		mov cl, 186
		mov bx, di
		shl bx, 8
		mov bl, DrawFrame_fromCol
		call SetChar
		
		mov ch, 15
		mov cl, 186
		mov bx, di
		shl bx, 8
		mov bl, DrawFrame_toCol
		call SetChar
		
		inc di
		jmp DrawFrame_loopV
DrawFrame_loopV_end:
		
		
		mov sp, bp
		pop bp
		ret
DrawFrame	endp


; void FillRect(ax: symb, bh: fromRow, bl: fromCol, ch: toRow, cl: toCol)
FillRect	proc near
FillRect_fromRow	equ [bp-1]
FillRect_fromCol	equ [bp-2]
FillRect_toRow		equ [bp-3]
FillRect_toCol		equ [bp-4]	
FillRect_symb		equ [bp-6]
		push bp
		mov bp, sp
		sub sp, 6
		
		mov FillRect_fromRow, bh
		mov FillRect_fromCol, bl
		mov FillRect_toRow, ch
		mov FillRect_toCol, cl
		mov FillRect_symb, ax
		
		mov ah, FillRect_fromRow
		
FillRect_loopV:	mov bh, FillRect_toRow
		cmp ah, bh
		jae FillRect_loopV_end
		
		mov al, FillRect_fromCol
	FillRect_loopH:	mov bl, FillRect_toCol
			cmp al, bl
			jae FillRect_loopH_end
			
			mov cx, FillRect_symb
			mov bx, ax
			push ax
			call SetChar
			pop ax
			
			inc al
			jmp FillRect_loopH
	FillRect_loopH_end:
		
		inc ah
		jmp FillRect_loopV
FillRect_loopV_end:
		
		mov sp, bp
		pop bp
		ret
FillRect	endp


; void SetChar(cl: letter, ch: attrs, bh: row, bl: column)
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


; void Beep(bx: frequency, cx: length)
Beep		proc near
		mov al, 182
		out 43h, al
		mov ax, bx
		out 42h, al
		mov al, ah
		out 42h, al
		in al, 61h
		or al, 00000011b
		out 61h, al
		mov bx, cx


Beep_pause1:	mov cx, 65535
Beep_pause2:	dec cx
		jnz Beep_pause2
		dec bx
		jnz Beep_pause1
		in al, 61h
		and al, 11111100b
		out 61h, al
		
		ret
Beep		endp


; void Sleep(ax: duration)
Sleep		proc near
		
Sleep_loop:	test ax, ax
		jz Sleep_loop_end
		dec ax
		jmp Sleep_loop
Sleep_loop_end:
		ret
Sleep		endp


.data


end Start