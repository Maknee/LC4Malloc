;;;;;;;;;;;;;;;;;;;;;;;;;;;;printnum;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
printnum
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-13	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRnp L2_malloc_test
	LEA R7, L4_malloc_test
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L1_malloc_test
L2_malloc_test
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L6_malloc_test
	LDR R7, R5, #3
	NOT R7,R7
	ADD R7,R7,#1
	STR R7, R5, #-13
	JMP L7_malloc_test
L6_malloc_test
	LDR R7, R5, #3
	STR R7, R5, #-13
L7_malloc_test
	LDR R7, R5, #-13
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRzp L8_malloc_test
	LEA R7, L10_malloc_test
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L1_malloc_test
L8_malloc_test
	ADD R7, R5, #-12
	ADD R7, R7, #10
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #0
	JMP L12_malloc_test
L11_malloc_test
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	LDR R3, R5, #-1
	CONST R2, #10
	MOD R3, R3, R2
	CONST R2, #48
	ADD R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #-1
	CONST R3, #10
	DIV R7, R7, R3
	STR R7, R5, #-1
L12_malloc_test
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L11_malloc_test
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L14_malloc_test
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #45
	STR R3, R7, #0
L14_malloc_test
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L1_malloc_test
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;endl;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
endl
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, L17_malloc_test
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L16_malloc_test
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;main;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
main
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-3	;; allocate stack space for local variables
	;; function body
	JSR intialize_heap
	ADD R6, R6, #0	;; free space for arguments
	CONST R7, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-2
	CONST R7, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-1
	CONST R7, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-3
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #0
	LDR R7, R5, #-2
	LDR R3, R5, #-1
	STR R3, R7, #1
	LDR R7, R5, #-2
	CONST R3, #1
	STR R3, R7, #2
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	STR R3, R7, #0
	LDR R7, R5, #-1
	LDR R3, R5, #-3
	STR R3, R7, #1
	LDR R7, R5, #-1
	CONST R3, #2
	STR R3, R7, #2
	LDR R7, R5, #-3
	LDR R3, R5, #-1
	STR R3, R7, #0
	LDR R7, R5, #-3
	CONST R3, #0
	STR R3, R7, #1
	LDR R7, R5, #-3
	CONST R3, #3
	STR R3, R7, #2
	LDR R7, R5, #-1
	LDR R7, R7, #0
	LDR R7, R7, #2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR printnum
	ADD R6, R6, #1	;; free space for arguments
	JSR endl
	ADD R6, R6, #0	;; free space for arguments
	LDR R7, R5, #-1
	LDR R7, R7, #2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR printnum
	ADD R6, R6, #1	;; free space for arguments
	JSR endl
	ADD R6, R6, #0	;; free space for arguments
	LDR R7, R5, #-1
	LDR R7, R7, #1
	LDR R7, R7, #2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR printnum
	ADD R6, R6, #1	;; free space for arguments
	JSR endl
	ADD R6, R6, #0	;; free space for arguments
	CONST R7, #0
L18_malloc_test
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.DATA
L17_malloc_test 		.STRINGZ "\n"
		.DATA
L10_malloc_test 		.STRINGZ "-32768"
		.DATA
L4_malloc_test 		.STRINGZ "0"
