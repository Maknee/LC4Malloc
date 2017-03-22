;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This file has 2 big jobs: 
;;; 1) It partitions USER memory for C programs
;;; 2) It ensures a LABEL called: main
;;;    will be the first function PennSim should jump
;;;    to when PennSim starts executing code.
;;;    NOTE: not a coincidence that we call our 
;;;    1st function in C language is: main ()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; 1) Setup USER Memory ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Declaration of Constants ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

USER_STACK_ADDR .UCONST x7FFF
USER_STACK_SIZE .UCONST x1000
USER_HEAP_SIZE  .UCONST x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Data ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA

;;; Reserve space for the heap and the stack so that the assembler will not try
;;; to place data in these regions.

.ADDR x4000
USER_HEAP .BLKW x3000

.ADDR x7000            
USER_STACK .BLKW x1000

;;;  We use this storage location to cache the Stack Pointer so that
;;;  we can restore the stack appropriately after a TRAP. It is only
;;;  needed for traps that overwrite R6
.ADDR x2000
STACK_SAVER .FILL 0x0000

;;; The following directive sets things up so that subsequent user globals will
;;; be stored in the right place.

.ADDR x2001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; 2) JUMP to MAIN subroutine ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
.CODE
.ADDR x0000    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Code ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
USER_START
    LC R6, USER_STACK_ADDR    ; initialize the stack pointer
    LEA R7, main
    JSRR R7                   ; invoke the main routine
END
    TRAP x0C                  ; call TRAP_HALT
