;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This file has 1 big job:
;;;
;;; It defines "wrapper" subroutines for the TRAPS
;;; in os.asm.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; WRAPPER SUBROUTINES FOLLOW ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
.CODE
.ADDR x0010    ;; we start after line 10, to preserve USER_START


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_PUTC Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_putc

	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	; setup arguments for TRAP_PUTC:
	LDR R0, R5, #3	; copy param (c) from stack, into register R0
	TRAP x01        ; R0 has been set, so we can call TRAP_PUTC
	
	; TRAP_PUTC has no return value, so nothing to copy back to stack

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_PUTS Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_puts
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 
	; setup arguments for TRAP_PUTS:
	LDR R0, R5, #3	; copy param (c) from stack, into register R0
	TRAP x02

	; TRAP_PUTS has no return value, so nothing to copy back to stack

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_GETC Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_getc_timer
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1

	LDR R0, R6, #2

	LEA R7, STACK_SAVER
	STR R6, R7, #0

	TRAP x08
	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0	

	LDR R7, R6, #1
	;; save TRAP return value on stack
	STR R0, R6, #1
	;; restore user base-pointer
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_DRAW_SPRITE Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_draw_sprite
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	; marshall arguments
	LDR R0, R6, #3		; x
	LDR R1, R6, #4		; y
	LDR R2, R6, #5		; color
	LDR R3, R6, #6		; sprite address
	
	; save R6
	LEA R7, STACK_SAVER	; TRAP_DRAW_RECT overwrite R5 & R6
	STR R6, R7, #0		; save it out to data memory
	
	; call trap
	TRAP x06
	
	; restore R6 & R5	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	ADD R5, R6, #0
	
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_DRAW_PIXEL Wrapper  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_draw_pixel
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	; marshall arguments (flip x and y to make sure everything is in correct order)
	LDR R0, R6, #4		; y 
	LDR R1, R6, #3		; x
	LDR R2, R6, #5		; color
	
	; save R6
	LEA R7, STACK_SAVER	; TRAP_DRAW_RECT overwrite R5 & R6
	STR R6, R7, #0		; save it out to data memory
	
	; call trap
	TRAP x04
	
	; restore R6 & R5	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	ADD R5, R6, #0
	
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_DRAW_CIRCLE Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_draw_circle
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	; marshall arguments	
	LDR R0, R6, #3		; x
	LDR R1, R6, #4		; y
	LDR R2, R6, #5		; radius
	LDR R3, R6, #6		; color
	
	; save R6
	LEA R7, STACK_SAVER	; TRAP_DRAW_RECT overwrite R5 & R6
	STR R6, R7, #0		; save it out to data memory
	
	; call trap
	TRAP x05
	
	; restore R6 & R5	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	ADD R5, R6, #0
	
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TRAP_LFSR_SET_SEED Wrapper ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_lfsr_set_seed
	;; R5 is the base pointer as well as the 
	;; TRAP return register.  If the trap returns
	;; a value, we have to save and restore the user's
	;; base-pointer
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1

	; marshall arguments	
	LDR R0, R6, #3		; seed

	LEA R7, STACK_SAVER
	STR R6, R7, #0
	
	TRAP x09
	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	
	LDR R7, R6, #1
	;; save LFSR return value on stack
	STR R0, R6, #1
	;; restore user base-pointer
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TRAP_LFSR Wrapper          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_lfsr 
	;; R5 is the base pointer as well as the 
	;; TRAP return register.  If the trap returns
	;; a value, we have to save and restore the user's
	;; base-pointer
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1

	LEA R7, STACK_SAVER
	STR R6, R7, #0
	
	TRAP x0A
	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	
	LDR R7, R6, #1
	;; save LFSR return value on stack
	STR R0, R6, #1
	;; restore user base-pointer
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_HALT Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN	
lc4_halt
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 
	TRAP x0B

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_RESET_VMEM Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_reset_vmem
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	; save R6
	LEA R7, STACK_SAVER	; TRAP_DRAW_RECT overwrite R5 & R6
	STR R6, R7, #0		; save it out to data memory

	;; function body 
	TRAP x0C

	; restore R6 & R5	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	ADD R5, R6, #0

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_BLT_VMEM Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.FALIGN
lc4_blt_vmem
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	; save R6
	LEA R7, STACK_SAVER	; TRAP_DRAW_RECT overwrite R5 & R6
	STR R6, R7, #0		; save it out to data memory

	;; function body 
	TRAP x0D

	; restore R6 & R5	
	LEA R7, STACK_SAVER
	LDR R6, R7, #0
	ADD R5, R6, #0

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET
