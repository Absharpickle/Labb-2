;
; Labb2.asm
;

.equ	T=10
.equ	N=10

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
DELAY_OUTER_LOOP:
	ldi		r17,$1F
DELAY_INNER_LOOP:
	dec		r17
	brne	DELAY_INNER_LOOP
	dec		r18
	brne	DELAY_OUTER_LOOP
	pop		r17
	ret

HW_INIT:	; är det detta som menas?
	ldi		ZH,HIGH(MESSAGE*2)
	ldi		ZL,LOW(MESSAGE*2)
HW_INIT_EXIT:
	ret		; gå till MORSE

GET_CHAR:
	lpm		r16,Z+
	;brne	LOOKUP
	;call	SEND
	;brne	GET_CHAR
GET_CHAR_EXIT:
	ret		; gå till MORSE

SEND_IT:
	call	BEEP_CHAR
	brne	GET_CHAR
SEND_IT_EXIT:
	ret

BEEP_CHAR:
	call	LOOKUP
	call	SEND
	ldi		r17,2*N
	;call	NOBEEP
BEEP_CHAR_EXIT:
	ret

SEND:
	lsl		r16
	ldi		r18,3*N
SEND_BITS:
	brcc	SHORT_BEEP	; Hur sätter vi längden?
	brcs	BEEP
	;call	NOBEEP
	andi	r16,$FF
	brne	SEND
SEND_EXIT:
	ret

SHORT_BEEP:
	ldi		r18,N
BEEP:
	sbi		PORTB,7	
	call	DELAY
	cbi		PORTB,7
BEEP_EXIT:
	ret

;NOBEEP:
;	ldi		r18,N



LOOKUP:
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



;;;;;;;;;;;;;;;;;;;; Huvudprogrammet
MORSE:
	call	HW_INIT
	call	GET_CHAR
	call	SEND_IT
MORSE_EXIT:
	ret		; Gå till AGAIN

