;;;;;;;;;;;;;;;;;;;;;;;;;;;;sbrk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.ADDR x1600
		.FALIGN
sbrk
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, breakAddr
	LDR R3, R7, #0
	LDR R2, R5, #3
	ADD R3, R3, R2
	STR R3, R7, #0
	LDR R7, R7, #0
	CONST R3, #0
	HICONST R3, #64
	CMP R7, R3
	BRzp L2_malloc
	LEA R7, L4_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	CONST R7, #-1
	JMP L1_malloc
L2_malloc
	LEA R7, breakAddr
	LDR R7, R7, #0
	CONST R3, #0
	HICONST R3, #64
	CONST R2, #0
	HICONST R2, #48
	ADD R3, R3, R2
	CMP R7, R3
	BRn L5_malloc
	LEA R7, L7_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	CONST R7, #-1
	JMP L1_malloc
L5_malloc
	LEA R7, breakAddr
	LDR R7, R7, #0
L1_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;intialize_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
intialize_heap
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	CONST R7, #0
	HICONST R7, #64
	LEA R3, breakAddr
	STR R7, R3, #0
	LEA R3, main_arena
	STR R7, R3, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	CONST R2, #255
	HICONST R2, #127
	AND R3, R3, R2
	STR R3, R7, #0
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	STR R3, R7, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	STR R3, R7, #1
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	STR R3, R7, #3
L8_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;find_block;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
find_block
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	HICONST R7, #64
	STR R7, R5, #-1
	JMP L11_malloc
L10_malloc
	LDR R7, R5, #3
	LDR R3, R5, #-1
	STR R3, R7, #0
	LDR R7, R5, #-1
	LDR R7, R7, #2
	STR R7, R5, #-1
L11_malloc
	LDR R7, R5, #-1
	ADD R3, R7, #0
	CONST R2, #0
	CMP R3, R2
	BRz L13_malloc
	LDR R7, R7, #0
	STR R7, R5, #-2
	CONST R3, #0
	HICONST R3, #128
	AND R3, R7, R3
	CONST R2, #0
	CMP R3, R2
	BRnp L10_malloc
	LDR R7, R5, #4
	LDR R3, R5, #-2
	CMP R3, R7
	BRn L10_malloc
L13_malloc
	LDR R7, R5, #-1
L9_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;extend_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
extend_heap
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	LEA R7, main_arena
	LDR R7, R7, #2
	STR R7, R5, #-1
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R7, R7, #3
	CONST R3, #0
	CMP R7, R3
	BRnp L15_malloc
	LDR R7, R5, #4
	ADD R7, R7, #8
	STR R7, R5, #-2
	JMP L16_malloc
L15_malloc
	LDR R7, R5, #4
	ADD R7, R7, #4
	STR R7, R5, #-2
L16_malloc
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR sbrk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	LEA R3, main_arena
	STR R7, R3, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #-1
	CMP R7, R3
	BRnp L17_malloc
	CONST R7, #0
	JMP L14_malloc
L17_malloc
	LEA R7, main_arena
	ADD R7, R7, #2
	LDR R3, R7, #0
	ADD R3, R3, #-4
	STR R3, R7, #0
	LDR R7, R5, #-1
	LDR R3, R5, #4
	CONST R2, #0
	HICONST R2, #128
	OR R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #-1
	CONST R3, #0
	HICONST R3, #64
	CMP R7, R3
	BRnp L19_malloc
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #1
	JMP L20_malloc
L19_malloc
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRz L21_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #3
	STR R3, R7, #1
L21_malloc
L20_malloc
	LDR R7, R5, #-1
	LEA R3, main_arena
	LDR R3, R3, #2
	STR R3, R7, #2
	LDR R7, R5, #-1
	STR R7, R7, #3
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	HICONST R3, #64
	CONST R2, #0
	HICONST R2, #48
	ADD R3, R3, R2
	ADD R2, R7, #0
	SUB R3, R3, R2
	ADD R3, R3, #-4
	STR R3, R7, #0
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R3, R5, #-1
	STR R3, R7, #1
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #0
	STR R3, R7, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	STR R7, R7, #3
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRz L23_malloc
	LDR R7, R5, #3
	LDR R3, R5, #-1
	STR R3, R7, #2
L23_malloc
	LDR R7, R5, #-1
L14_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;shrink_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
shrink_heap
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-5	;; allocate stack space for local variables
	;; function body
	ADD R1, R5, #-5
	LEA R7, main_arena
	LDR R0, R7, #2
;ASGNB
	ADD R6, R6, #-1
	STR R2, R6, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
;blkloop!!!!
	AND R3, R3, #0
	ADD R3, R3, #5
L28
	LDR R2, R0, #0
	STR R2, R1, #0
	ADD R0, R0, #1
	ADD R1, R1, #1
	ADD R3, R3, #-1
BRnp L28
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R7, R5, #4
	NOT R7,R7
	ADD R7,R7,#1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR sbrk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	LEA R3, main_arena
	STR R7, R3, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	CONST R3, #-1
	CMP R7, R3
	BRnp L26_malloc
	CONST R7, #0
	JMP L25_malloc
L26_malloc
	LEA R7, main_arena
	ADD R7, R7, #2
	LDR R3, R7, #0
	ADD R3, R3, #-4
	ADD R3, R3, #-4
	STR R3, R7, #0
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R3, R5, #-5
	STR R3, R7, #0
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R3, R5, #3
	STR R3, R7, #1
	LEA R7, main_arena
	LDR R7, R7, #2
	ADD R3, R5, #-5
	LDR R3, R3, #2
	STR R3, R7, #2
	LEA R7, main_arena
	LDR R7, R7, #2
	ADD R3, R5, #-5
	LDR R3, R3, #3
	STR R3, R7, #3
	LDR R7, R5, #3
	LEA R3, main_arena
	LDR R3, R3, #2
	STR R3, R7, #2
	LEA R7, main_arena
	LDR R7, R7, #2
L25_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;split_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
split_chunk
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	LDR R3, R5, #4
	ADD R7, R7, R3
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R7, R7, #4
	STR R7, R5, #-2
	LDR R7, R5, #-2
	STR R7, R5, #-1
	LDR R7, R5, #-1
	LDR R3, R5, #3
	LDR R3, R3, #2
	STR R3, R7, #2
	LDR R7, R5, #-1
	LDR R3, R5, #3
	STR R3, R7, #1
	LDR R7, R5, #-1
	LDR R3, R5, #3
	LDR R3, R3, #0
	LDR R2, R5, #4
	SUB R3, R3, R2
	ADD R3, R3, #-4
	STR R3, R7, #0
	LDR R7, R5, #-1
	LDR R3, R7, #0
	CONST R2, #255
	HICONST R2, #127
	AND R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #-1
	STR R7, R7, #3
	LDR R7, R5, #-1
	LDR R3, R7, #2
	STR R7, R3, #1
	LDR R7, R5, #3
	LDR R3, R5, #4
	CONST R2, #0
	HICONST R2, #128
	OR R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #3
	LDR R3, R5, #-1
	STR R3, R7, #2
L29_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;malloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
malloc
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-1
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R7, R7, #3
	CONST R3, #0
	CMP R7, R3
	BRz L31_malloc
	LEA R7, main_arena
	LDR R7, R7, #2
	STR R7, R5, #-2
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR find_block
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #2	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRz L33_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L33_malloc
	LDR R7, R5, #-1
	LDR R7, R7, #0
	LDR R3, R5, #3
	SUB R7, R7, R3
	STR R7, R5, #-4
	CONST R7, #1
	STR R7, R5, #-3
	LDR R7, R5, #-3
	ADD R7, R7, #4
	STR R7, R5, #-3
	LDR R7, R5, #-4
	LDR R3, R5, #-3
	CMP R7, R3
	BRn L35_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L36_malloc
L35_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #3
	CONST R2, #0
	HICONST R2, #128
	OR R3, R3, R2
	STR R3, R7, #0
L36_malloc
	LDR R7, R5, #-1
	STR R7, R7, #3
	JMP L32_malloc
L33_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR extend_heap
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #2	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	STR R3, R7, #1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L32_malloc
	CONST R7, #0
	JMP L30_malloc
L31_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR extend_heap
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #2	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L39_malloc
	CONST R7, #0
	JMP L30_malloc
L39_malloc
L32_malloc
	LDR R7, R5, #-1
	ADD R7, R7, #4
L30_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;merge_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
merge_chunk
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	ADD R3, R7, #0
	LDR R7, R7, #0
	CONST R2, #255
	HICONST R2, #127
	AND R7, R7, R2
	ADD R7, R3, R7
	ADD R7, R7, #4
	STR R7, R5, #-1
	LDR R7, R5, #-1
	ADD R3, R7, #0
	CONST R2, #0
	CMP R3, R2
	BRz L42_malloc
	LDR R7, R7, #0
	CONST R2, #0
	HICONST R2, #128
	AND R7, R7, R2
	CONST R2, #0
	CMP R7, R2
	BRnp L42_malloc
	LEA R7, main_arena
	LDR R7, R7, #2
	CMP R3, R7
	BRz L42_malloc
	LDR R7, R5, #3
	LDR R3, R7, #0
	LDR R2, R7, #2
	LDR R2, R2, #0
	ADD R2, R2, #4
	ADD R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #3
	LDR R3, R7, #0
	CONST R2, #255
	HICONST R2, #127
	AND R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #3
	LDR R3, R5, #-1
	LDR R3, R3, #2
	STR R3, R7, #2
	LDR R7, R5, #3
	LDR R7, R7, #2
	CONST R3, #0
	CMP R7, R3
	BRz L44_malloc
	LDR R7, R5, #3
	LDR R3, R7, #2
	STR R7, R3, #1
L44_malloc
	CONST R7, #1
	JMP L41_malloc
L42_malloc
	CONST R7, #0
L41_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;check_if_valid;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
check_if_valid
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R7, R7, #3
	CONST R3, #0
	CMP R7, R3
	BRz L47_malloc
	LDR R7, R5, #3
	STR R7, R5, #-1
	CONST R3, #0
	HICONST R3, #64
	CMP R7, R3
	BRn L49_malloc
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R3, R5, #-1
	CMP R3, R7
	BRzp L49_malloc
	LDR R7, R5, #3
	LDR R3, R7, #3
	CMP R3, R7
	BRnp L51_malloc
	CONST R7, #1
	JMP L46_malloc
L51_malloc
L49_malloc
L47_malloc
	CONST R7, #0
L46_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;free;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
free
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LDR R7, R5, #3
	ADD R7, R7, #-4
	STR R7, R5, #3
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR check_if_valid
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRz L54_malloc
	LDR R7, R5, #3
	LDR R3, R7, #0
	CONST R2, #255
	HICONST R2, #127
	AND R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #3
	CONST R3, #0
	STR R3, R7, #3
	LDR R7, R5, #3
	LDR R7, R7, #1
	ADD R3, R7, #0
	CONST R2, #0
	CMP R3, R2
	BRz L56_malloc
	LDR R7, R7, #0
	CONST R3, #0
	HICONST R3, #128
	AND R7, R7, R3
	CONST R3, #0
	CMP R7, R3
	BRnp L56_malloc
	LDR R7, R5, #3
	LDR R7, R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
L56_malloc
L57_malloc
	LDR R7, R5, #3
	LDR R7, R7, #2
	CONST R3, #0
	CMP R7, R3
	BRz L58_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L58_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRnp L55_malloc
	JMP L55_malloc
L58_malloc
	LDR R7, R5, #3
	LDR R7, R7, #1
	CONST R3, #0
	CMP R7, R3
	BRz L62_malloc
	LDR R7, R5, #3
	LDR R3, R7, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R7, R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR shrink_heap
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #2	;; free space for arguments
	JMP L55_malloc
L62_malloc
	JSR intialize_heap
	ADD R6, R6, #0	;; free space for arguments
	JMP L55_malloc
L54_malloc
	LEA R7, L64_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L55_malloc
L53_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;calloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
calloc
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-3	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-1
	LDR R7, R5, #3
	LDR R3, R5, #4
	MUL R7, R7, R3
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-3
	JMP L67_malloc
L66_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-3
	ADD R7, R7, R3
	CONST R3, #0
	STR R3, R7, #0
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
L67_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L66_malloc
	CONST R7, #0
L65_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;copy_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
copy_chunk
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-1
	LDR R7, R5, #4
	LDR R7, R7, #0
	CONST R3, #255
	HICONST R3, #127
	AND R7, R7, R3
	STR R7, R5, #-2
	CONST R7, #20
	LDR R3, R5, #3
	ADD R3, R3, R7
	STR R3, R5, #3
	LDR R3, R5, #4
	ADD R7, R3, R7
	STR R7, R5, #4
	JMP L71_malloc
L70_malloc
	CONST R7, #5
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LDR R3, R5, #4
	ADD R1, R7, R3
	LDR R3, R5, #3
	ADD R0, R7, R3
;ASGNB
	ADD R6, R6, #-1
	STR R2, R6, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
;blkloop!!!!
	AND R3, R3, #0
	ADD R3, R3, #5
L73
	LDR R2, R0, #0
	STR R2, R1, #0
	ADD R0, R0, #1
	ADD R1, R1, #1
	ADD R3, R3, #-1
BRnp L73
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
L71_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L70_malloc
L69_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;realloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
realloc
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	ADD R7, R7, #-4
	STR R7, R5, #3
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRnp L75_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	JMP L74_malloc
L75_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR check_if_valid
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRz L77_malloc
	LDR R7, R5, #3
	LDR R7, R7, #0
	LDR R3, R5, #4
	SUB R7, R7, R3
	STR R7, R5, #-3
	CONST R7, #1
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R7, R7, #4
	STR R7, R5, #-2
	LDR R7, R5, #-3
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L79_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L78_malloc
L79_malloc
	LDR R7, R5, #3
	LDR R7, R7, #2
	CONST R3, #0
	CMP R7, R3
	BRz L81_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L81_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #1
	CMP R7, R3
	BRnp L78_malloc
	LDR R7, R5, #3
	LDR R7, R7, #0
	LDR R3, R5, #4
	SUB R7, R7, R3
	STR R7, R5, #-4
	LDR R7, R5, #-4
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L78_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L78_malloc
L81_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #-20
	ADD R7, R7, R3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR copy_chunk
	ADD R6, R6, #2	;; free space for arguments
	LDR R7, R5, #3
	ADD R7, R7, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR free
	ADD R6, R6, #1	;; free space for arguments
	LDR R7, R5, #-1
	JMP L74_malloc
L77_malloc
	LEA R7, L87_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L78_malloc
	CONST R7, #0
L74_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

	.DATA
	.ADDR 0x3900
		.DATA
main_arena 		
		.FILL #18522
		.FILL #1
		.FILL x0
breakAddr 		.BLKW 1
L87_malloc 		.STRINGZ "SEGFAULT - Realloc - ptr is invalid"
L64_malloc 		.STRINGZ "SEGFAULT - freeing twice"
L7_malloc 		.STRINGZ "Break cannot be placed after the heap (break < 0x3000)"
L4_malloc 		.STRINGZ "Break cannot be placed before the heap (break < 0x4000)"