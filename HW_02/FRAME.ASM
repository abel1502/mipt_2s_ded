.model tiny
.286
.code

VIDEOSEG	equ 0b800h
FrameStyle	equ 00011111b

org 100h
Start:		call SetCharInit
		
		
		mov ax, 0600h
		mov cx, 0000h
		mov dx, 0ffffh
		mov bh, 00111111b
		int 10h
		
		mov ax, 7h
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
		
		mov ax, 3802
		add bh, 3
		add bl, 5
		;call DrawCmd
		
		push ax
		push bx
		call DrawNum10
		
		pop bx
		push bx
		mov cl, 'd'
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		pop bx
		pop ax
		inc bh
		push ax
		push bx
		call DrawNumL1
		
		pop bx
		push bx
		mov cl, 'b'
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		pop bx
		pop ax
		inc bh
		push ax
		push bx
		call DrawNumL3
		
		pop bx
		push bx
		mov cl, 'o'
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		pop bx
		pop ax
		inc bh
		push ax
		push bx
		call DrawNumL4
		
		pop bx
		push bx
		mov cl, 'x'
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		
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
		
		mov ax, 0600h
		mov cx, 0000h
		mov dx, 0ffffh
		mov bh, 7h
		int 10h
		
		mov ax, 4c00h
		int 21h


; Same as Coords2Key, but embeddable
; macro(result (register letter, can't be d), coords (register letter, can't be d))
Coords2KeyM	macro result, coords
		
		mov result&x, SetChar_width
		mul coords&h
		xor coords&h, coords&h
		add result&l, coords&l
		adc result&h, 0
		shl result&x, 1
		
		endm


; void DrawFrame(bh: fromRow, bl: fromCol, ch: toRow, cl: toCol)
; uses ax, bx, cx, dx, di, SetChar
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
		
		mov ax, 0600h
		mov dx, cx
		mov cx, bx
		inc cl
		inc ch
		inc dl
		inc dh
		mov bh, 00001111b
		int 10h
		
		;mov ax, ' '
		;call FillRect
		; There's a swifter way to achieve this
		dec cl
		dec ch
		dec dl
		dec dh
		mov bh, FrameStyle
		int 10h
		
		mov ch, FrameStyle
		mov cl, 201
		mov bh, DrawFrame_fromRow
		mov bl, DrawFrame_fromCol
		call SetChar
		
		mov ch, FrameStyle
		mov cl, 187
		mov bh, DrawFrame_fromRow
		mov bl, DrawFrame_toCol
		call SetChar
		
		mov ch, FrameStyle
		mov cl, 188
		mov bh, DrawFrame_toRow
		mov bl, DrawFrame_toCol
		call SetChar
		
		mov ch, FrameStyle
		mov cl, 200
		mov bh, DrawFrame_toRow
		mov bl, DrawFrame_fromCol
		call SetChar
		
		
		; es is already set by SetChar
		cld
		xor ch, ch
		
		mov cl, DrawFrame_toCol
		sub cl, DrawFrame_fromCol
		dec cl
		test cl, 1 SHL 7
		jnz DrawFrame_loopH_end
		
		mov bl, DrawFrame_fromCol
		mov bh, DrawFrame_fromRow
		Coords2KeyM a, b
		inc ax
		inc ax
		mov di, ax
		
		mov ah, FrameStyle
		mov al, 205
		
		rep stosw
		
		
		mov cl, DrawFrame_toCol
		sub cl, DrawFrame_fromCol
		dec cl
		
		mov bl, DrawFrame_fromCol
		mov bh, DrawFrame_toRow
		Coords2KeyM a, b
		inc ax
		inc ax
		mov di, ax
		
		mov ah, FrameStyle
		mov al, 205
		
		rep stosw
		
DrawFrame_loopH_end:
		
		mov cl, DrawFrame_toRow
		sub cl, DrawFrame_fromRow
		dec cl
		test cl, 1 SHL 7
		jnz DrawFrame_loopH_end
		
		mov bl, DrawFrame_fromCol
		mov bh, DrawFrame_fromRow
		inc bh
		Coords2KeyM a, b
		
		mov di, ax
		mov ax, SetChar_width  ; TODO: Change previous macro params instead
		shl ax, 1
		
		xor bh, bh
		mov bl, DrawFrame_toCol
		sub bl, DrawFrame_fromCol
		shl bl, 1
		jnc DrawFrame_loopV
		xor bl, bl
		
DrawFrame_loopV:
		mov word ptr es:[di],    (FrameStyle SHL 8) OR 186
		mov word ptr es:[di+bx], (FrameStyle SHL 8) OR 186
		
		add di, ax
		loop DrawFrame_loopV
		
DrawFrame_loopV_end:
		
		
		mov sp, bp
		pop bp
		ret
DrawFrame	endp


; void SetCharInit()
; uses: ax, bx, es
SetCharInit	proc near
		
		int 11h
		xor ax, 30h
		shl ax, 11
		or ax, VIDEOSEG
		mov SetChar_buf, ax
		
		mov ax, 40h
		mov es, ax
		mov ax, es:4ah  ; 80 most often
		mov SetChar_width, ax
		
SetCharInit	endp


; Coords2KeyM moved up


; ax: coords Coords2Key(bh: row, bl: column)
; uses: ax, (bx), dx
Coords2Key	proc near
		Coords2KeyM a, b
Coords2Key	endp


; ax: index SetChar(cl: letter, ch: attrs, bh: row, bl: column)
; uses: ax, (bx), (cx), dx, es
SetChar		proc near
		Coords2KeyM a, b
		
		xchg ax, bx
		
		mov dx, SetChar_buf
		mov es, dx
		mov es:[bx], cx
		
		xchg ax, bx
		
		ret

SetChar_width	dw 80
SetChar_buf	dw 0
SetChar		endp


; void Beep(bx: frequency, cx: length)
; uses ax, bx, cx
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


; TODO: Maybe use the int 15h 81h
; void Sleep(ax: duration)
; uses ax
Sleep		proc near
		
Sleep_loop:	test ax, ax
		jz Sleep_loop_end
		dec ax
		jmp Sleep_loop
Sleep_loop_end:
		ret
Sleep		endp


; void DrawCmd(bh: row, bl: column)
; uses ax, bx, cx, si, SetChar
DrawCmd		proc near
DrawCmd_i	equ [bp-1]
DrawCmd_origCol	equ [bp-2]
		push bp
		mov bp, sp
		sub sp, 2
		
		mov DrawCmd_origCol, bl
		mov al, ds:80h
		mov DrawCmd_i, al
		mov si, 81h
		
DrawCmd_loop:	mov al, DrawCmd_i
		test al, al
		jz DrawCmd_loop_end
		
		mov cl, [si]
		xor cl, '$'
		je DrawCmd_nl
		xor cl, '$'
		
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		inc bl
		
		jmp DrawCmd_nl_skip
		
DrawCmd_nl:	mov bl, DrawCmd_origCol
		inc bh
		
DrawCmd_nl_skip:
		inc si
		dec byte ptr DrawCmd_i
		jmp DrawCmd_loop
DrawCmd_loop_end:
		
		mov sp, bp
		pop bp
		ret
DrawCmd		endp


; void DrawNum10(ax: num, bh: row, bl: column)
; uses ax, bx, cx, dx, SetChar
DrawNum10	proc near
		;add bl, 5
		add bl, 17
		
DrawNum10_loop:	test ax, ax
		jz DrawNum10_loop_end
		
		;aam  ; This is faster than division and more convenient, although relies on ax being small enough
		mov cl, 10
		xor ch, ch
		xor dx, dx
		div cx
		
		add dl, '0'
		mov cl, dl
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		
		push ax
		call SetChar
		pop ax
		
		dec bl
		jmp DrawNum10_loop
DrawNum10_loop_end:

		ret
DrawNum10	endp


; macro(base)
; void DrawNumL&base(ax: num, bh: row, bl: column)
; uses ax, bx, cx, SetChar
DrawNumLB	macro base
		
DrawNumL&base	proc near
		;add bl, base
		add bl, 17
		
DrawNumL&base&_loop:
		test ax, ax
		jz DrawNumL&base&_loop_end
		
		mov cl, al
		and cl, (1 SHL base) - 1
		
		cmp cl, 10
		jae DrawNumL&base&_bigDigit
		
		add cl, '0'
		
		jmp DrawNumL&base&_notBigDigit
DrawNumL&base&_bigDigit:
		add cl, 'A'-10
DrawNumL&base&_notBigDigit:
		
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		
		shr ax, base
		
		push ax
		call SetChar
		pop ax
		
		dec bl
		jmp DrawNumL&base&_loop
DrawNumL&base&_loop_end:

		ret
DrawNumL&base&	endp
		
		endm



DrawNumLB	1 ;2
DrawNumLB	3 ;3
DrawNumLB	4 ;4


.data


end Start