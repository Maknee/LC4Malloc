;;;;;;;;;;;;;;;;;;;;;;;;;;;;printnum;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.ADDR 0x1400
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
	BRnp L2_malloc
	LEA R7, L4_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L1_malloc
L2_malloc
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L6_malloc
	LDR R7, R5, #3
	NOT R7,R7
	ADD R7,R7,#1
	STR R7, R5, #-13
	JMP L7_malloc
L6_malloc
	LDR R7, R5, #3
	STR R7, R5, #-13
L7_malloc
	LDR R7, R5, #-13
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRzp L8_malloc
	LEA R7, L10_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L1_malloc
L8_malloc
	ADD R7, R5, #-12
	ADD R7, R7, #10
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #0
	JMP L12_malloc
L11_malloc
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
L12_malloc
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L11_malloc
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L14_malloc
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #45
	STR R3, R7, #0
L14_malloc
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L1_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;endl;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.FALIGN
endl
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, L17_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L16_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;assertGTZero;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.FALIGN
assertGTZero
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L19_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L19_malloc
L18_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;assertEQZero;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.FALIGN
assertEQZero
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRz L22_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L22_malloc
L21_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;assertLTZero;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.FALIGN
assertLTZero
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRnz L25_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L25_malloc
L24_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;sbrk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRzp L28_malloc
	LEA R7, L30_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	CONST R7, #-1
	JMP L27_malloc
L28_malloc
	LEA R7, breakAddr
	LDR R7, R7, #0
	CONST R3, #0
	HICONST R3, #64
	CONST R2, #0
	HICONST R2, #48
	ADD R3, R3, R2
	CMP R7, R3
	BRn L31_malloc
	LEA R7, L33_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	CONST R7, #-1
	JMP L27_malloc
L31_malloc
	LEA R7, breakAddr
	LDR R7, R7, #0
L27_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

main_arena 		.FILL #18522
		.FILL #1
		.FILL x0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;intialize_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
L34_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;find_block;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	JMP L37_malloc
L36_malloc
	LDR R7, R5, #3
	LDR R3, R5, #-1
	STR R3, R7, #0
	LDR R7, R5, #-1
	LDR R7, R7, #2
	STR R7, R5, #-1
L37_malloc
	LDR R7, R5, #-1
	ADD R3, R7, #0
	CONST R2, #0
	CMP R3, R2
	BRz L39_malloc
	LDR R7, R7, #0
	STR R7, R5, #-2
	CONST R3, #0
	HICONST R3, #128
	AND R3, R7, R3
	CONST R2, #0
	CMP R3, R2
	BRnp L36_malloc
	LDR R7, R5, #4
	LDR R3, R5, #-2
	CMP R3, R7
	BRn L36_malloc
L39_malloc
	LDR R7, R5, #-1
L35_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;extend_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRnp L41_malloc
	LDR R7, R5, #4
	ADD R7, R7, #8
	STR R7, R5, #-2
	JMP L42_malloc
L41_malloc
	LDR R7, R5, #4
	ADD R7, R7, #4
	STR R7, R5, #-2
L42_malloc
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
	BRnp L43_malloc
	CONST R7, #0
	JMP L40_malloc
L43_malloc
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
	BRnp L45_malloc
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #1
	JMP L46_malloc
L45_malloc
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRz L47_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #3
	STR R3, R7, #1
L47_malloc
L46_malloc
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
	BRz L49_malloc
	LDR R7, R5, #3
	LDR R3, R5, #-1
	STR R3, R7, #2
L49_malloc
	LDR R7, R5, #-1
L40_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;shrink_heap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
L54
	LDR R2, R0, #0
	STR R2, R1, #0
	ADD R0, R0, #1
	ADD R1, R1, #1
	ADD R3, R3, #-1
BRnp L54
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
	BRnp L52_malloc
	CONST R7, #0
	JMP L51_malloc
L52_malloc
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
L51_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;split_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
L55_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;malloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRz L57_malloc
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
	BRz L59_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L59_malloc
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
	BRn L61_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L62_malloc
L61_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #3
	CONST R2, #0
	HICONST R2, #128
	OR R3, R3, R2
	STR R3, R7, #0
L62_malloc
	LDR R7, R5, #-1
	STR R7, R7, #3
	JMP L58_malloc
L59_malloc
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
	BRnp L58_malloc
	CONST R7, #0
	JMP L56_malloc
L57_malloc
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
	BRnp L65_malloc
	CONST R7, #0
	JMP L56_malloc
L65_malloc
L58_malloc
	LDR R7, R5, #-1
	ADD R7, R7, #4
L56_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;merge_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRz L68_malloc
	LDR R7, R7, #0
	CONST R2, #0
	HICONST R2, #128
	AND R7, R7, R2
	CONST R2, #0
	CMP R7, R2
	BRnp L68_malloc
	LEA R7, main_arena
	LDR R7, R7, #2
	CMP R3, R7
	BRz L68_malloc
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
	BRz L70_malloc
	LDR R7, R5, #3
	LDR R3, R7, #2
	STR R7, R3, #1
L70_malloc
	CONST R7, #1
	JMP L67_malloc
L68_malloc
	CONST R7, #0
L67_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;check_if_valid;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRz L73_malloc
	LDR R7, R5, #3
	STR R7, R5, #-1
	CONST R3, #0
	HICONST R3, #64
	CMP R7, R3
	BRn L75_malloc
	LEA R7, main_arena
	LDR R7, R7, #2
	LDR R3, R5, #-1
	CMP R3, R7
	BRzp L75_malloc
	LDR R7, R5, #3
	LDR R3, R7, #3
	CMP R3, R7
	BRnp L77_malloc
	CONST R7, #1
	JMP L72_malloc
L77_malloc
L75_malloc
L73_malloc
	CONST R7, #0
L72_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;free;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRz L80_malloc
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
	BRz L82_malloc
	LDR R7, R7, #0
	CONST R3, #0
	HICONST R3, #128
	AND R7, R7, R3
	CONST R3, #0
	CMP R7, R3
	BRnp L82_malloc
	LDR R7, R5, #3
	LDR R7, R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
L82_malloc
L83_malloc
	LDR R7, R5, #3
	LDR R7, R7, #2
	CONST R3, #0
	CMP R7, R3
	BRz L84_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L84_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRnp L81_malloc
	JMP L81_malloc
L84_malloc
	LDR R7, R5, #3
	LDR R7, R7, #1
	CONST R3, #0
	CMP R7, R3
	BRz L88_malloc
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
	JMP L81_malloc
L88_malloc
	JSR intialize_heap
	ADD R6, R6, #0	;; free space for arguments
	JMP L81_malloc
L80_malloc
	LEA R7, L90_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L81_malloc
L79_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;calloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	JMP L93_malloc
L92_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-3
	ADD R7, R7, R3
	CONST R3, #0
	STR R3, R7, #0
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
L93_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L92_malloc
	CONST R7, #0
L91_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;copy_chunk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	JMP L97_malloc
L96_malloc
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
L99
	LDR R2, R0, #0
	STR R2, R1, #0
	ADD R0, R0, #1
	ADD R1, R1, #1
	ADD R3, R3, #-1
BRnp L99
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
L97_malloc
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L96_malloc
L95_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;realloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BRnp L101_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR malloc
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	JMP L100_malloc
L101_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR check_if_valid
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRz L103_malloc
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
	BRn L105_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L104_malloc
L105_malloc
	LDR R7, R5, #3
	LDR R7, R7, #2
	CONST R3, #0
	CMP R7, R3
	BRz L107_malloc
	LEA R3, main_arena
	LDR R3, R3, #2
	CMP R7, R3
	BRz L107_malloc
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR merge_chunk
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #1
	CMP R7, R3
	BRnp L104_malloc
	LDR R7, R5, #3
	LDR R7, R7, #0
	LDR R3, R5, #4
	SUB R7, R7, R3
	STR R7, R5, #-4
	LDR R7, R5, #-4
	LDR R3, R5, #-2
	CMP R7, R3
	BRn L104_malloc
	LDR R7, R5, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR split_chunk
	ADD R6, R6, #2	;; free space for arguments
	JMP L104_malloc
L107_malloc
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
	JMP L100_malloc
L103_malloc
	LEA R7, L113_malloc
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR lc4_halt
	ADD R6, R6, #0	;; free space for arguments
L104_malloc
	CONST R7, #0
L100_malloc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

	.DATA
	.ADDR 0x3900
breakAddr 		.BLKW 1
L113_malloc 	.STRINGZ "SEGFAULT - Realloc - ptr is invalid"
L90_malloc 		.STRINGZ "SEGFAULT - freeing twice"
L33_malloc 		.STRINGZ "Break cannot be placed after the heap (break < 0x3000)"
L30_malloc 		.STRINGZ "Break cannot be placed before the heap (break < 0x4000)"
L17_malloc 		.STRINGZ "\n"
L10_malloc 		.STRINGZ "-32768"
L4_malloc 		.STRINGZ "0"
