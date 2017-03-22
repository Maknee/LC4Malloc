;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File: OS.ASM
;;; Purpose: provide PennSim with an OS to handle I/O
;;; PennSim will load the contents of this file in x8200
;;; author: Amir Roth; modified by CJT 10/17/10; by TJF 3/17/14
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;   OS - TRAP VECTOR TABLE   ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; when user calls a trap, PC jumps here
	; then the "JMP" below jumps to trap implementation
.OS
.CODE
.ADDR x8000
  ; TRAP vector table
	JMP TRAP_GETC           ; x00
	JMP TRAP_PUTC           ; x01
	JMP TRAP_PUTS           ; x02
	JMP TRAP_VIDEO_COLOR    ; x03
	JMP TRAP_DRAW_PIXEL     ; x04
	JMP TRAP_DRAW_CIRCLE    ; x05
	JMP TRAP_DRAW_SPRITE    ; x06
	JMP TRAP_TIMER          ; x07
	JMP TRAP_GETC_TIMER     ; x08
	JMP TRAP_LFSR_SET_SEED  ; x09
	JMP TRAP_LFSR           ; x0A
	JMP TRAP_HALT			; x0B
	JMP TRAP_RESET_VMEM		; x0C
	JMP TRAP_BLT_VMEM		; x0D
	; this table can go up to xFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;   OS - MEMORY ADDRESS CONSTANTS   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; these handy alias' will be used in the TRAPs that follow
	USER_CODE_ADDR 	.UCONST x0000		; start of USER code
	OS_CODE_ADDR 	.UCONST x8000		; start of OS code

	OS_GLOBALS_ADDR .UCONST xA000		; start of OS global mem
	OS_STACK_ADDR 	.UCONST xBFFF		; start of OS stack mem
	OS_VIDEO_ADDR 	.UCONST xC000		; start of OS video mem
	OS_VIDEO_NUM_COLS .UCONST #128		; columns in video mem
	OS_VIDEO_NUM_ROWS .UCONST #124		; rows in video mem	

	OS_KBSR_ADDR	.UCONST xFE00		; keyboard status register
	OS_KBDR_ADDR	.UCONST xFE02		; keyboard data register
	OS_ADSR_ADDR	.UCONST xFE04		; display status register
	OS_ADDR_ADDR	.UCONST xFE06		; display data register
	OS_TSR_ADDR	.UCONST xFE08		; timer register
	OS_TIR_ADDR	.UCONST xFE0A		; timer interval register
	OS_VDCR_ADDR	.UCONST xFE0C	        ; video display control register
	OS_MCR_ADDR	.UCONST xFFEE		; machine control register

	TIM_INIT 	.UCONST #320		; default value for timer

	MASK_L15 	.UCONST x7FFF		; handy masks to clear regs
	MASK_H4		.UCONST xF000
	MASK_H1		.UCONST x8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; OS RESERVE VIDEO MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xC000	
OS_VIDEO_MEM .BLKW x3E00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; OS RESERVE GLOBAL MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xA000
OS_GLOBALS_MEM	.BLKW x1000
;;;  LFSR value used by lfsr code
LFSR .FILL 0x0001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;   OS & TRAP SUBROUTINES START HERE   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;   OS_START   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Initalize Timer and return to user memory: x0000
;;; Inputs           - none
;;; Outputs          - none

.CODE
.ADDR x8200
OS_START
	;; initialize timer
	LC R0, TIM_INIT
	LC R1, OS_TIR_ADDR
	STR R0, R1, #0

	;; R7 <- User code address (x0000)
	LC R7, USER_CODE_ADDR 
	RTI			; RTI removes the privilege bit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_HALT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: halts the program and jumps to OS_START
;;; Inputs           - none
;;; Outputs          - none

.CODE
TRAP_HALT	
	; clear run bit in MCR
	LC R3, OS_MCR_ADDR
	LDR R0, R3, #0
	LC R1, MASK_L15
	AND R0,R0, R1
	STR R0, R3, #0
	JMP OS_START 	; restart machine
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_RESET_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; In double-buffered video mode, resets the video display
;;; Inputs - none
;;; Outputs - none
.CODE	
TRAP_RESET_VMEM
	LC R4, OS_VDCR_ADDR
	CONST R5, #1
	STR R5, R4, #0
	RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_BLT_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_BLT_VMEM - In double-buffered video mode, copies the contents
;;; of video memory to the video display.
;;; Inputs - none
;;; Outputs - none
.CODE
TRAP_BLT_VMEM
	LC R4, OS_VDCR_ADDR
	CONST R5, #2
	STR R5, R4, #0
	RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - none
;;; Outputs          - R0 = ASCII character from ASCII keyboard

.CODE
TRAP_GETC
    LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
    LDR R0, R0, #0       ; R0 = value of keyboard status reg
    BRzp TRAP_GETC       ; if R0[15]=1, data is waiting!
                             ; else, loop and check again...

    ; reaching here, means data is waiting in keyboard data reg

    LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
    LDR R0, R0, #0       ; R0 = value of keyboard data reg
    RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a single character out to ASCII display
;;; Inputs           - R0 = ASCII character to write to ASCII display
;;; Outputs          - none

.CODE
TRAP_PUTC
  LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
  LDR R1, R1, #0    	; R1 = value of display status reg
  BRzp TRAP_PUTC    	; if R1[15]=1, display is ready to write!
		    	    ; else, loop and check again...

  ; reaching here, means console is ready to display next char

  LC R1, OS_ADDR_ADDR 	; R1 = address of display data reg
  STR R0, R1, #0    	; R1 = value of keyboard data reg (R0)
  RTI			; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a string of characters out to ASCII display
;;; Inputs           - R0 = Address for first character
;;; Outputs          - none

.CODE
TRAP_PUTS
  LC R4, OS_ADSR_ADDR
  LDR R1, R4, #0
  BRzp TRAP_PUTS    ; Loop while the MSB is zero

LOOP
  LC R4, OS_ADDR_ADDR
  LDR R1, R0, #0              ; load character to R1
  CMPI R1, #0
  BRz FINISH                  ; if 0, end the loop
  STR R1, R4, #0              ; Write out the character
  ADD R0, R0, #1              ; update the data memory address
  JMP LOOP

FINISH
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_VIDEO_COLOR   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Set all pixels of VIDEO display to a certain color
;;; Inputs           - R0 = color to set all pixels to
;;; Outputs          - none

.CODE
TRAP_VIDEO_COLOR
  LC R1, OS_VIDEO_NUM_ROWS ; loads num of rows into R1
  LC R2, OS_VIDEO_NUM_COLS ; loads num of columns into R2
  MUL R2, R1, R2 ; R2 = R1 * R2 (R2 = total pixel in screen)
  LEA R1, OS_VIDEO_MEM ; loads addr of first pixel into R1

VIDEO_COLOR_LOOP
  STR R0, R1, #0 ; Stores the color at the address of the pixel
  ADD R1, R1, #1 ; increments current pixel address
  ADD R2, R2, #-1 ; decrements loop counter
  BRp VIDEO_COLOR_LOOP ; if loop counter > 0, loop again

  RTI       ; PC = R7 ; PSR[15]=0
  RTI       ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_PIXEL   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw point on video display
;;; Inputs           - R0 = row to draw on (y)
;;;                  - R1 = column to draw on (x)
;;;                  - R2 = color to draw with
;;; Outputs          - none

.CODE
TRAP_DRAW_PIXEL
  LEA R3, OS_VIDEO_MEM       ; R3=start address of video memory
  LC  R4, OS_VIDEO_NUM_COLS  ; R4=number of columns

  CMPIU R1, #0    	     ; Checks if x coord from input is > 0
  BRn END_PIXEL
  CMPIU R1, #127    	     ; Checks if x coord from input is < 127
  BRp END_PIXEL
  CMPIU R0, #0    	     ; Checks if y coord from input is > 0
  BRn END_PIXEL
  CMPIU R0, #123    	     ; Checks if y coord from input is < 123
  BRp END_PIXEL

  MUL R4, R0, R4      	     ; R4= (row * NUM_COLS)
  ADD R4, R4, R1      	     ; R4= (row * NUM_COLS) + col
  ADD R4, R4, R3      	     ; Add the offset to the start of video memory
  STR R2, R4, #0      	     ; Fill in the pixel with color from user (R2)

END_PIXEL
  RTI       		     ; PC = R7 ; PSR[15]=0



;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_CIRCLE   ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draws the outline of a circle with a specific center col. and rad.
;;; Inputs           - R0 = x coordinate of center
;;; Inputs           - R1 = y coordinate of center
;;; Inputs           - R2 = radius of circle
;;; Inputs           - R3 = color of circle
;;; Outputs          - none

.CODE
TRAP_DRAW_CIRCLE
  DRAW_CIRCLE_TEMPS .UCONST x5000  ; Reserved for temp variables
  LC R6 DRAW_CIRCLE_TEMPS ; loads temp array addr into R6
  STR R0 R6 #0 ; Store CX in Temp[0]
  STR R1 R6 #1 ; Store CY in Temp[1]
  STR R2 R6 #2 ; Store R in Temp[2]
  STR R3 R6 #3 ; Store Color in Temp [3]
  STR R2 R6 #4 ; Store X (= R) in Temp[4]

  CONST R5 #0 ; Const 0 into R5
  STR R5 R6 #5 ; Temp[5] is Y which is 0
  STR R7 R6 #11 ; Store Return Address in Temp[11]
  CONST R4 #2 ; put 2 in R4
  MUL R2 R2 R4 ; R = R*2
  CONST R4 #1 ; put 1 in R4
  SUB R5 R4 R2 ; XChange = 1 - 2*R
  STR R5 R6 #6 ; Store XChange (= 1-2*R) in Temp[6]
  STR R4 R6 #7 ; Store YChange (= 1) in Temp[7]
  CONST R0 #0 ; Load a 0 into R0
  STR R0 R6 #8 ; Temp[8] is RadiusError which is 0

DRAW_CIRCLE_WHILE
  LDR R0 R6 #4 ; Load X into R0
  LDR R1 R6 #5 ; Load Y into R1
  CMP R0 R1; X - Y
  BRn DRAW_CIRCLE_END ; While (X >= Y)

  ;;;;;;;;;;; Plot8CirclePoints ;;;;;;;;;;;;;
  LDR R2 R6 #3 ; Load Color into R2
  LDR R3 R6 #4 ; Load X into R3
  LDR R4 R6 #5 ; Load Y into R4
  LDR R5 R6 #0 ; Load CX into R5
  LDR R6 R6 #1 ; Load CY into R6

  ;; Point 1
  ADD R0 R5 R3 ; R0 = CX+X
  ADD R1 R6 R4 ; R1 = CY+Y
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 2
  SUB R0 R5 R3 ; R0 = CX-X
  ADD R1 R6 R4 ; R1 = CY+Y
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 3
  SUB R0 R5 R3 ; R0 = CX-X
  SUB R1 R6 R4 ; R1 = CY-Y
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 4
  ADD R0 R5 R3 ; R0 = CX+X
  SUB R1 R6 R4 ; R1 = CY-Y
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 5
  ADD R0 R5 R4 ; R0 = CX+Y
  ADD R1 R6 R3 ; R1 = CY+X
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 6
  SUB R0 R5 R4 ; R0 = CX-Y
  ADD R1 R6 R3 ; R1 = CY+X
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 7
  SUB R0 R5 R4 ; R0 = CX-Y
  SUB R1 R6 R3 ; R1 = CY-X
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;; Point 8
  ADD R0 R5 R4 ; R0 = CX+Y
  SUB R1 R6 R3 ; R1 = CY-X
  ; Draw Pixel
  JSR DRAW_CIRCLE_POINT

  ;;;;;; Plot8CirclePoints Done ;;;;;;;;;
  LC R6 DRAW_CIRCLE_TEMPS ; Load temp array back into R6
  LDR R1 R6 #5 ; Load Y into R1
  ADD R1 R1 #1 ; Y = Y + 1
  STR R1 R6 #5 ; Store Y

  LDR R2 R6 #8 ; Load RadiusError into R2
  LDR R3 R6 #7 ; Load YChange into R3
  ADD R2 R2 R3 ; RadiusError += YChange
  STR R2 R6 #8 ; Store RadiusError
  ADD R3 R3 #2 ; YChange += 2
  STR R3 R6 #7 ; Store YChange

  LDR R4 R6 #6 ; Load XChange
  CONST R0 #2 ; Put 2 into R0
  MUL R2 R2 R0 ; Now R2 = 2*RE
  ADD R2 R2 R4 ; R2 = 2*RE + XC
  BRnz DRAW_CIRCLE_AFTER_IF ; if (2*RE + XC > 0)

  LDR R0 R6 #4 ; Load X into R0
  ADD R0 R0 #-1 ; X -= 1
  STR R0 R6 #4 ; Store X

  LDR R1 R6 #6 ; Load XChange into R1
  LDR R2 R6 #8 ; Load RadiusError into R2
  ADD R2 R2 R1 ; RE += XC
  ADD R1 R1 #2 ; XC += 2
  STR R2 R6 #8 ; Store RE
  STR R1 R6 #6 ; Store XC

DRAW_CIRCLE_AFTER_IF
  JMP DRAW_CIRCLE_WHILE

DRAW_CIRCLE_END
  LC R6 DRAW_CIRCLE_TEMPS ; Get address of temps
  LDR R7 R6 #11 ; load correct return address back into R7
  RTI

.FALIGN
DRAW_CIRCLE_POINT
    ; Draw Pixel
    LC R6 DRAW_CIRCLE_TEMPS ; Reload Temp array addr into R6
    STR R3 R6 #9 ; Store R3 in Temp[9]
    STR R4 R6 #10 ; Store R4 in Temp[10]
    LEA R3 OS_VIDEO_MEM       ; R3=start address of video memory
    LC  R4 OS_VIDEO_NUM_COLS  ; R4=number of columns

    CMPIU R1 #0          ; Checks if y coord from input is > 0
    BRn DRAW_CIRCLE_POINT_END
    CMPIU R1 #123          ; Checks if y coord from input is < 127
    BRp DRAW_CIRCLE_POINT_END
    CMPIU R0 #0          ; Checks if x coord from input is > 0
    BRn DRAW_CIRCLE_POINT_END
    CMPIU R0 #127          ; Checks if x coord from input is < 123
    BRp DRAW_CIRCLE_POINT_END

    MUL R4 R1 R4             ; R4= (row * NUM_COLS)
    ADD R4 R4 R0             ; R4= (row * NUM_COLS) + col
    ADD R4 R4 R3             ; Add the offset to the start of video memory
    STR R2 R4 #0             ; Fill in the pixel with color from user (R2)

DRAW_CIRCLE_POINT_END
    LDR R2 R6 #3 ; Load Color into R2
    LDR R3 R6 #4 ; Load X into R3
    LDR R4 R6 #5 ; Load Y into R4
    LDR R5 R6 #0 ; Load CX into R5
    LDR R6 R6 #1 ; Load CY into R6
    RET

  RTI       		; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_SPRITE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function:	draws an 8x8 sprite on the screen.
;;; Inputs:	R0 - video column (left)
;;;   		R1 - video row (upper) 
;;;   		R2 - color
;;;   		R3 - Address of sprite bitmap - an array of 8 words
;;;
;;; Outputs:    video memory will be updated to include sprite of approriate color

.CODE
TRAP_DRAW_SPRITE

;; STORE R0, R1 and R7
	LEA R6, OS_GLOBALS_MEM
	STR R0, R6, #0
	STR R1, R6, #1
	STR R7, R6, #2

;;; for (i=0; i < 8; ++i, ++ptr) {
;;;    temp = i + start_row;
;;;    if (temp < 0) continue;
;;;    if (temp >= NUM_ROWS) end;
;;;    byte = *ptr & 0xFF;
;;;    col = start_col + 7;
;;;    temp = VIDEO_MEM + (temp * 128) + col
;;;    do {
;;;       if (col >= 0 && col < NUM_COLS && byte & 0x1)
;;;          *temp = color
;;;       --col;
;;;       --temp;
;;;       byte >>= 1;
;;;    } while (byte)
;;; }
;;; 
;;; Register Allocation
;;;   R0 - i
;;;   R1 - temp
;;;   R2 - color
;;;   R3 - ptr
;;;   R4 - byte
;;;   R5 - col
;;;   R6 - scratch
;;;   R7 - scratch

	CONST R0, #0		; i = 0
	JMP TRAP_DRAW_SPRITE_F12

TRAP_DRAW_SPRITE_F11

	LEA R6, OS_GLOBALS_MEM
	LDR R1, R6, #1		; load start_row
	ADD R1, R1, R0		; temp = i + start_row
	BRn TRAP_DRAW_SPRITE_F13 ; temp < 0 continue
	LC R7 OS_VIDEO_NUM_ROWS
	CMP R1, R7
	BRzp TRAP_DRAW_SPRITE_END ; (temp >= NUM_ROWS) end
	LDR R4, R3, #0		  ; byte = *ptr
	CONST R7, 0xFF
	AND R4, R4, R7		; byte = byte & xFF

	LEA R6, OS_GLOBALS_MEM
	LDR R5, R6, #0		; load start_col
	ADD R5, R5, #7		; col = start_col + 7

	SLL R1, R1, #7		; temp = temp * 128
	ADD R1, R1, R5		; temp = temp + col
	LEA R7, OS_VIDEO_MEM
	ADD R1, R1, R7		; temp = temp + OS_VIDEO_MEM

	LC R7, OS_VIDEO_NUM_COLS

TRAP_DRAW_SPRITE_W1

	CMPI R5, #0
	BRn TRAP_DRAW_SPRITE_W2	; col < 0 continue

	CMP R5, R7
	BRzp TRAP_DRAW_SPRITE_W2 ; col >= NUM_COLS continue

	AND R6, R4, 0x01
	BRz TRAP_DRAW_SPRITE_W2	; byte & 0x1 == 0 continue
	
	STR R2, R1, 0		; *temp = color
TRAP_DRAW_SPRITE_W2
	ADD R5, R5, #-1		; --col
	ADD R1, R1, #-1		; --temp
	SRL R4, R4, #1		; byte >>= 1
	
	BRnp TRAP_DRAW_SPRITE_W1
	
TRAP_DRAW_SPRITE_F13	
	ADD R0, R0, #1		; ++i
	ADD R3, R3, #1		; ++ptr
TRAP_DRAW_SPRITE_F12
	CMPI R0, #8
	BRn TRAP_DRAW_SPRITE_F11

TRAP_DRAW_SPRITE_END
	LEA R6, OS_GLOBALS_MEM
	LDR R7, R6, #2
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function:
;;; Inputs           - R0 = time to wait in milliseconds
;;; Outputs          - none

.CODE
TRAP_TIMER
  LC R1, OS_TIR_ADDR 	; R1 = address of timer interval reg
  STR R0, R1, #0    	; Store R0 in timer interval register

COUNT
  LC R1, OS_TSR_ADDR  	; Save timer status register in R1
  LDR R1, R1, #0    	; Load the contents of TSR in R1
  BRzp COUNT    	; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R0

  RTI       		; PC = R7 ; PSR[15]=0



;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - R0 = time to wait
;;; Outputs          - R0 = ASCII character from keyboard (or NULL)

.CODE
TRAP_GETC_TIMER

  LC R1, OS_TIR_ADDR  ; R1 = address of timer interval reg
  STR R0, R1, #0      ; Store R0 in timer interval register

GETC_COUNT
  LC R1, OS_TSR_ADDR    ; Save timer status register in R1
  LDR R1, R1, #0        ; Load the contents of TSR in R1
  BRzp GETC             ; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R1

  CONST R0 #0
  RTI

GETC
  LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
  LDR R0, R0, #0       ; R0 = value of keyboard status reg
  BRzp GETC_COUNT      ; if R0[15]=1, data is waiting!
                       ; else, loop and check again...

  LC R2, OS_KBDR_ADDR  ; R2 = address of keyboard data reg
  LDR R0, R2, #0       ; R0 = value of keyboard data reg

  RTI                  ; PC = R7 ; PSR[15]=0







;;;;;;;;;;;;;;;;;;;;;;;   TRAP_LFSR_SET_SEED   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: set a seed value for the TRAP_LFSR trap 
;;; Inputs           - R0 = 16-bit seed
;;; Outputs          - none

.CODE
TRAP_LFSR_SET_SEED
  LEA R1, LFSR    ; Save LFSR address in R1
  STR R0, R1, #0      ; Store the contents of R0 in LFSR


;;;;;;;;;;;;;;;;;;;;;;;   TRAP_LFSR   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Performs the LFSR algorithm on a 16-bit sequence
;;; Inputs           - None
;;; Outputs          - shifted bit pattern in R0 

.CODE
TRAP_LFSR
  INIT
  LEA R0 LFSR     ; Store address of the LFSR label into R0
  LDR R0 R0 #0    ; Load value

  CONST R4 #1     ; R4 = 1

  SRL R1 R0 15    ;; Shifts the register to the right 15 bits
  SRL R2 R0 13
  XOR R3 R1 R2    ; XOR the 15th and 13th bits

  SRL R1 R0 12    
  SRL R2 R0 10
 
  XOR R3 R3 R1   
  XOR R3 R3 R2    ; XOR the previous XOR value with the 12th and 10th bits

  AND R3 R3 R4    ; Isolate the LSB of the XOR result

  SLL R0 R0 1     ;; Shifts R0 to the left once
  ADD R0 R0 R3    ; Insert the LSB of the XOR result into the shifted RO sequence

  LEA R1, LFSR    ; R1 = address of LFSR
  STR R0, R1, #0  ; R0 = value of keyboard data reg

  RTI
