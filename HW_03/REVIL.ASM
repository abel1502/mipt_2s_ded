.model tiny
.286
.code

VIDEOSEG	equ 0b800h
FrameStyle	equ 00011111b


InstallIRQ	macro number
		
		mov ax, 3500h OR number
		int 21h
		mov ax, es
		
		cmp bx, offset Int&number&Handler
		je SkipInstall
		
		
		mov Int&number&Handler_oldOff, bx
		mov Int&number&Handler_oldSeg, ax
		
		; cli not needed
		
		mov ax, 2500h OR number
		mov dx, offset Int&number&Handler
		int 21h
		
		endm


UninstallIRQ	macro number
		
		push ds
		
		mov ax, 2500h OR number
		mov dx, Int&number&Handler_oldOff
		mov bx, Int&number&Handler_oldSeg
		mov ds, bx
		
		int 21h
		
		pop ds
		
		endm


NextIRQ		macro number
		
		db 0eah  ; jmp far
Int&number&Handler_oldOff	dw 0
Int&number&Handler_oldSeg	dw 0
		
		endm


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


org 100h
Start:		call SetCharInit
		
		; mov ax, 3509h
		; int 21h
		; mov ax, es
		
		; cmp bx, offset Int9Handler
		; je SkipInstall
		
		
		; mov Int9Handler_oldOff, bx
		; mov Int9Handler_oldSeg, ax
		
		; ; As the docs recommend, we may as well free our environment block
		; push es
		; push cs:2ch
		; pop es
		; mov ah, 49h
		; int 21h
		; pop es
		
		
		; ; cli not needed
		
		; mov ax, 2509h
		; mov dx, offset Int9Handler
		; int 21h
		
		
		; As the docs recommend, we may as well free our environment block
		push es
		push cs:2ch
		pop es
		mov ah, 49h
		int 21h
		pop es
		
		InstallIRQ 9
		
		InstallIRQ 8
		
		mov ax, 3100h
		mov dx, offset ProgEnd
		shr dx, 4
		inc dx
		int 21h
		
		
SkipInstall:	mov ah, 09h
		mov dx, offset SkipMsg
		int 21h
		
		mov ax, 4c00h
		int 21h


; INT 9 (kbd) handler
Int9Handler	proc far
		
		;pusha
		
		;mov ax, 0ah
		;mov bx, 0bh
		;mov cx, 0ch
		;mov dx, 0dh
		
		pusha
		push es ds
		
		mov bp, sp  ; Old bp saved by pusha
		
		mov ax, cs
		mov ds, ax
		
		;call SetCharInit  ; I guess we may always call it
		
		in al, 60h
		mov ah, al
		shr ah, 7  ; ah holds whether it's a key pressed or depressed
		and al, 01111111b
		
		cmp al, 4fh  ; Numpad 1
		je Int9Handler_Num1
		cmp al, 52h  ; Numpad 0
		je Int9Handler_Num0
		
		jmp Int9Handler_next
		
Int9Handler_Num1:
		xor Int8Handler_show, ah  ; TODO: ?
		
		jmp Int9Handler_end
		
Int9Handler_Num0:
		UninstallIRQ 9
		
		mov Int8Handler_kill, 1
		
		; Further shutdown happens within timer interrupt
		
		; jmp Int9Handler_end ; Happens automatically
		
Int9Handler_end:
		in al, 61h
		mov ah, al
		or al, 1000000b
		out 61h, al
		mov al, ah
		nop
		nop  ; As recommended
		out 61h, al
		
		mov al, 20h
		out 20h, al
		
		pop ds es
		popa
		
		;popa
		
		iret
		
Int9Handler_next:
		pop ds es
		popa
		
		;popa
		
		NextIRQ 9

Int9Handler	endp


; INT 8 (timer) handler
Int8Handler	proc far
		
		;push ax
		;mov al, 20h
		;out 20h, al
		;pop ax
		;iret
		
		;pusha
		
		;mov ax, 0ah
		;mov bx, 0bh
		;mov cx, 0ch
		;mov dx, 0dh
		
		pusha
		push es ds
		
		mov bp, sp  ; Old bp saved by pusha
		
		mov ax, cs
		mov ds, ax
		
		
		test Int8Handler_kill, 1
		jnz Int8Handler_detach
		
		
		mov al, Int8Handler_ticks
		test al, al
		jz Int8Handler_doTick
		jmp Int8Handler_next
Int8Handler_doTick:
		mov Int8Handler_ticks, Int8Handler_interval
		
		call SetCharInit  ; I guess we may always call it
		
		
		test Int8Handler_show, 1
		jnz Int8Handler_maybeShow  ; TODO: Restore videobuf
		jmp Int8Handler_maybeHide
		
Int8Handler_maybeShow:
		test Int8Handler_wasShown, 1
		jnz Int8Handler_notShow
		
		; TODO: Save segment under frame
		mov bx, Int8Handler_FrameS
		mov cx, Int8Handler_FrameE
		call SaveBG
		
		mov Int8Handler_wasShown, 1
		
Int8Handler_notShow:
		mov bx, Int8Handler_FrameS
		mov cx, Int8Handler_FrameE
		call DrawFrame
		
		mov bx, Int8Handler_FrameT
		mov cl, Int8Handler_LegendLen
		mov si, offset Int8Handler_Legend
		call DrawStr
		
		mov ax, Int8Handler_OldA
		mov bx, Int8Handler_FrameTA
		call DrawNumHex
		
		mov ax, Int8Handler_OldB
		mov bx, Int8Handler_FrameTB
		call DrawNumHex
		
		mov ax, Int8Handler_OldC
		mov bx, Int8Handler_FrameTC
		call DrawNumHex
		
		mov ax, Int8Handler_OldD
		mov bx, Int8Handler_FrameTD
		call DrawNumHex
		
		jmp Int8Handler_next
		
Int8Handler_detach:
		UninstallIRQ 8
		
		test Int8Handler_show, 1
		jz Int8Handler_detach_noHide
		
		mov bx, Int8Handler_FrameS
		mov cx, Int8Handler_FrameE
		call RestoreBG
		
Int8Handler_detach_noHide:
		
		; TODO: Verify interrupt isn't hijacked and refuse to stop in that case (and same for int8)
		
		; Now I'll do something incredibly crotchy - that is freeing the memory block I reside in.
		; That clearly contradicts a well-known russian saying "Don't cut the branch you're sitting on",
		; but I believe this shouldn't overwrite us, thanks to how DOS doesn't support multithreading.
		; That should get us enough time to shut ourselves down as well. The only thing that has a chance
		; to interrupt us is a timer tick (which I intend to intercept myself as soon as I finish the 
		; keyboard part - then I'll move this bit of code there and it will become completely invincible).
		; But even now a disruption is unlikely - that would need the timer to request a memory block (or
		; start another program, which does that intrinsically), and that doesn't seem like things a timer
		; would ever want to do.
		
		push es
		push cs
		pop es
		mov ah, 49h
		int 21h
		pop es
		
		jmp Int8Handler_next
		
Int8Handler_maybeHide:
		test Int8Handler_wasShown, 1
		jz Int8Handler_next
		
		; Restore saved videobuf from under frame
		mov bx, Int8Handler_FrameS
		mov cx, Int8Handler_FrameE
		call RestoreBG
		
		mov Int8Handler_wasShown, 0
		
		jmp Int8Handler_next
		
Int8Handler_next:
		dec Int8Handler_ticks
		
		pop ds es
		popa
		
		;popa
		
		NextIRQ 8
		

Int8Handler_interval	equ 4
Int8Handler_ticks	db 0

Int8Handler_show	db 0
Int8Handler_wasShown	db 0
Int8Handler_kill	db 0

Int8Handler_Legend	db 'ax: 0000', 0ah, \
			   'bx: 0000', 0ah, \
			   'cx: 0000', 0ah, \
			   'dx: 0000'
Int8Handler_LegendLen	equ $ - Int8Handler_Legend

Int8Handler_FrameSX	equ 2
Int8Handler_FrameSY	equ 1
Int8Handler_FrameW	equ 11
Int8Handler_FrameH	equ 5
Int8Handler_FrameEX	equ Int8Handler_FrameSX + Int8Handler_FrameW
Int8Handler_FrameEY	equ Int8Handler_FrameSY + Int8Handler_FrameH

Int8Handler_FrameS	equ (Int8Handler_FrameSY SHL 8) OR Int8Handler_FrameSX
Int8Handler_FrameE	equ (Int8Handler_FrameEY SHL 8) OR Int8Handler_FrameEX

Int8Handler_FrameT	equ Int8Handler_FrameS + 0102h
Int8Handler_FrameTA	equ Int8Handler_FrameT + 0003h
Int8Handler_FrameTB	equ Int8Handler_FrameTA + 0100h
Int8Handler_FrameTC	equ Int8Handler_FrameTB + 0100h
Int8Handler_FrameTD	equ Int8Handler_FrameTC + 0100h

Int8Handler_OldA	equ [bp+18]
Int8Handler_OldB	equ [bp+12]
Int8Handler_OldC	equ [bp+16]
Int8Handler_OldD	equ [bp+14]

Int8Handler_BG		db (((Int8Handler_FrameH + 2) * (Int8Handler_FrameW + 2)) * 2)dup(?)

Int8Handler	endp


; void SaveBG(bh: fromRow, bl: fromCol, ch: toRow, cl: toCol)
; uses ax, bx, cx, dx, si, di
SaveBG		proc near
		push es ds
		
		inc ch
		inc cl
		
		push bx
		Coords2KeyM a, b
		pop bx
		
		mov si, ax
		mov di, offset Int8Handler_BG
		
		mov dx, cx
		sub dx, bx  ; actually dl -= bl; dh -= bh
		
		push SetChar_buf
		push ds
		pop es
		pop ds
		
		cld
		
		xor ch, ch
		
SaveBG_loop:	test dh, dh
		jz SaveBG_loop_end
		
		mov cl, dl
		
		rep movsw
		
		dec dh
		mov ax, es:SetChar_width
		shl ax, 1
		add si, ax
		xor ah, ah
		mov al, dl
		shl ax, 1
		sub si, ax
		
		jmp SaveBG_loop
SaveBG_loop_end:
		
		pop ds es
		
		ret
SaveBG		endp


; void RestoreBG(bh: fromRow, bl: fromCol, ch: toRow, cl: toCol)
; uses ax, bx, cx, dx, si, di
RestoreBG	proc near
		push es
		
		inc ch
		inc cl
		
		push bx
		Coords2KeyM a, b
		pop bx
		
		mov si, offset Int8Handler_BG
		mov di, ax
		
		mov dx, cx
		sub dx, bx  ; actually dl -= bl; dh -= bh
		
		push SetChar_buf
		pop es
		
		;mov word ptr ds:[si], 7h SHL 8 OR '!'
		;mov byte ptr ds:[si], '!'
		
		cld
		
		xor ch, ch
		
RestoreBG_loop:	test dh, dh
		jz RestoreBG_loop_end
		
		mov cl, dl
		
		rep movsw
		
		dec dh
		mov ax, SetChar_width
		shl ax, 1
		add di, ax
		xor ah, ah
		mov al, dl
		shl ax, 1
		sub di, ax
		
		jmp RestoreBG_loop
RestoreBG_loop_end:
		
		pop es
		
		ret
RestoreBG	endp


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
		
		ret
		
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
		push bx
		Coords2KeyM a, b
		
		xchg ax, bx
		
		mov dx, SetChar_buf
		mov es, dx
		mov es:[bx], cx
		
		pop bx
		
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


; void DrawStr(bh: row, bl: column, cl: length, si: source)
; uses ax, bx, cx, si, SetChar
DrawStr		proc near
DrawStr_i	equ [bp-1]
DrawStr_origCol	equ [bp-2]
		push bp
		mov bp, sp
		sub sp, 2
		
		mov DrawStr_origCol, bl
		mov DrawStr_i, cl
		
DrawStr_loop:	mov al, DrawStr_i
		test al, al
		jz DrawStr_loop_end
		
		mov cl, [si]
		cmp cl, 0ah
		je DrawStr_nl
		
		test cl, cl
		jz DrawStr_loop_end
		
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		call SetChar
		
		inc bl
		
		jmp DrawStr_nl_skip
		
DrawStr_nl:	mov bl, DrawStr_origCol
		inc bh
		
DrawStr_nl_skip:
		inc si
		dec byte ptr DrawStr_i
		jmp DrawStr_loop
DrawStr_loop_end:
		
		mov sp, bp
		pop bp
		ret
DrawStr		endp


; void DrawNum10(ax: num, bh: row, bl: column)
; uses ax, bx, cx, dx, SetChar
DrawNum10	proc near
		add bl, 5
		
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


; void DrawNumHex(ax: num, bh: row, bl: column)
; uses ax, bx, cx, SetChar
DrawNumHex	proc near
		add bl, 4
		
DrawNumHex_loop:
		test ax, ax
		jz DrawNumHex_loop_end
		
		mov cl, al
		and cl, 0fh
		
		cmp cl, 10
		jae DrawNumHex_bigDigit
		
		add cl, '0'
		
		jmp DrawNumHex_notBigDigit
DrawNumHex_bigDigit:
		add cl, 'A'-10
DrawNumHex_notBigDigit:
		
		mov ch, (FrameStyle AND 11110000b) OR 0100b
		
		shr ax, 4
		
		push ax
		call SetChar
		pop ax
		
		dec bl
		jmp DrawNumHex_loop
DrawNumHex_loop_end:

		ret
DrawNumHex	endp


ProgEnd:

.data

SkipMsg		db "Skipping installation.", 0ah, 0dh, "$"

end Start