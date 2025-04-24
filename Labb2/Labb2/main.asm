;
; Labb2.asm
;

.equ	T=10
.equ	N=70

ldi		r16,HIGH(RAMEND)
out		SPH,r16
ldi		r16,LOW(RAMEND)
out		SPL,r16
ldi		r16,0b10000000
out		DDRB,r16
clr		r16

jmp		AGAIN 

MESSAGE:	; Sparar ordet i flash
	.db		"O O",$00
BTAB:		; Sparar binärkodningen i flash
	.db		$60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8

;;;;;;;;;;;;;;;;;;;; Loopar huvudprogrammet
AGAIN:
	call	MORSE
	jmp		AGAIN

;;;;;;;;;;;;;;;;;;;; Subrutin DELAY(r16=length)
DELAY:
	push	r17
	push	r18
	ldi		r18,T
DELAY_OUTER_LOOP:
	ldi		r17,$1F
DELAY_INNER_LOOP:
	dec		r17
	brne	DELAY_INNER_LOOP
	dec		r18
	brne	DELAY_OUTER_LOOP
	pop		r18
	pop		r17
	ret

HW_INIT:	; är det detta som menas?
	ldi		ZH,HIGH(MESSAGE*2)
	ldi		ZL,LOW(MESSAGE*2)
HW_INIT_EXIT:
	ret		; gå till MORSE

GET_CHAR:
	lpm		r16,Z+
	cpi		r16,' '
	breq	DO_SPACE
GET_CHAR_EXIT:
	ret	



BEEP_CHAR:
	call	LOOKUP
	call	SEND
	ldi		r18,2*N
	call	NOBEEP
BEEP_CHAR_EXIT:
	ret

SEND:
	lsl		r16
	ldi		r18,3*N
SEND_BITS:
	brcc	SHORT_BEEP
	brcs	BEEP
SEND_BITS_2:
	ldi		r18,N
	call	NOBEEP
	cpi		r16,0b10000000
	brne	SEND
SEND_EXIT:
	ret

SHORT_BEEP:
	ldi		r18,N
BEEP:
	sbi		PORTB,7	
	call	DELAY
	cbi		PORTB,7
	call	DELAY
	dec		r18
	brne	BEEP
	jmp		SEND_BITS_2

NOBEEP:
	cbi		PORTB,7	
	call	DELAY
	cbi		PORTB,7
	call	DELAY
	dec		r18
	brne	NOBEEP
NOBEEP_EXIT:
	ret

SEND_IT:
	call	BEEP_CHAR
	jmp		MORSE_LOOP

LOOKUP: ; Konverterar till ASCII
	push	ZH
	push	ZL
	ldi		ZH,HIGH(BTAB*2)
	ldi		ZL,LOW(BTAB*2)
	subi	r16,'A'
	add		ZL,r16
	lpm		r16,Z
	pop		ZL
	pop		ZH
LOOKUP_EXIT:
	ret

DO_SPACE:
	ldi		r18,N
	push	r16
	ldi		r16,7
DO_SPACE_LOOP:
	call	NOBEEP
	dec		r16
	brne	DO_SPACE_LOOP
	pop		r16
	jmp GET_CHAR

;;;;;;;;;;;;;;;;;;;; Huvudprogrammet
MORSE:
	call	HW_INIT
MORSE_LOOP:
	call	GET_CHAR
	cpi		r16,$00
	brne	SEND_IT
MORSE_EXIT:
	ret		; Gå till AGAIN

