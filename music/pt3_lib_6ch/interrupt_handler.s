	;================================
	;================================
	; mockingboard interrupt handler
	;================================
	;================================
	; On Apple II/6502 the interrupt handler jumps to address in 0xfffe
	; This is in the ROM, which saves the registers
	;   on older IIe it saved A to $45 (which could mess with DISK II)
	;   newer IIe doesn't do that.
	; It then calculates if it is a BRK or not (which trashes A)
	; Then it sets up the stack like an interrupt and calls 0x3fe

	; Note: the IIc is much more complicated
	;	its firmware tries to decode the proper source
	;	based on various things, including screen hole values
	;	we bypass that by switching out ROM and replacing the
	;	$fffe vector with this, but that does mean we have
	;	to be sure status flag and accumulator set properly

interrupt_handler:
	php			; save status flags
	cld			; clear decimal mode
	pha			; save A				; 3
				; A is saved in $45 by firmware
	txa
	pha			; save X
	tya
	pha			; save Y



;	inc	$0404		; debug (flashes char onscreen)


.include "pt3_lib_irq_handler.s"

	jmp	exit_interrupt

	;=================================
	; Finally done with this interrupt
	;=================================

quiet_exit:
	stx	DONE_PLAYING
	jsr	clear_ay_both

	ldx	#$ff		; also mute the channel
	stx	AY_REGISTERS_2+7	; just in case
.if 0
	stx	AY_REGISTERS+7	; just in case
.endif

exit_interrupt:

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a				; 4

	; on II+/IIe (but not IIc) we need to do this?
interrupt_smc:
	lda	$45		; restore A
	plp

	rti			; return from interrupt			; 6

								;============
								; typical
								; ???? cycles

	;=============================
	; Disable Interrupt
	;=============================
	; disables all the 6522 timer interrupts

mockingboard_disable_interrupt:

	sei			; disable interrupts just in case

	lda	#$40		; Continuous interrupts, don't touch PB7
disable_irq_smc1:
	sta	MOCK_6522_ACR	; ACR register
	lda	#$7F		; clear all interrupt flags
disable_irq_smc2:
	sta	MOCK_6522_IER	; IER register (interrupt enable)

	rts

