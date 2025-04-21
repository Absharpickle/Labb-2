;
; Labb2.asm
;

.equ	T=10
.equ	N=

ldi		r16,HIGH(RAMEND)
out		SPH,r16
ldi		r16,LOW(RAMEND)
out		SPL,r16
ldi		r16,0b00000001
out		DDRB,r16	; Sätter PB1 till utsignal
clr		r16

MESSAGE:	; Sparar ordet i flash
	.db		"DATORTEKNIK",$00	
BTAB:		; Sparar binärkodningen i flash
	.db		$60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8

;;;;;;;;;;;;;;;;;;;; Loopar huvudprogrammet
AGAIN:
	call	MORSE
	jmp		AGAIN

;;;;;;;;;;;;;;;;;;;; Subrutin DELAY(r16=length)
DELAY:
	push	r17
	sbi		PORTB,7
DELAY_OUTER_LOOP:
	ldi		r17,$1F
DELAY_INNER_LOOP:
	dec		r17
	brne	DELAY_INNER_LOOP
	dec		r16
	brne	DELAY_OUTER_LOOP
	cbi		PORTB,7
	pop		r17
	ret

HW_INIT:	; är det detta som menas?
	ldi		ZH,HIGH(MESSAGE*2)
	ldi		ZL,LOW(MESSAGE*2)
HW_INIT_EXIT:
	ret		; gå till MORSE

GET_CHAR:
	lpm		r16,Z+
	brne	LOOKUP
GET_CHAR_EXIT:
	ret		; gå till 

LOOKUP:
	push	ZH,ZL
	ldi		ZH,HIGH(BTAB*2)
	ldi		ZL,LOW(BTAB*2)
	subi	r16,'A'
	ldi		Z,Z+r16
	lpm		r16,Z
	pop		ZL,ZH
LOOKUP_EXIT:
	ret



;;;;;;;;;;;;;;;;;;;; Huvudprogrammet
MORSE:
	call	HW_INIT
	call	GET_CHAR
	call	SEND_IT
MORSE_EXIT:
	ret		; Gå till AGAIN

