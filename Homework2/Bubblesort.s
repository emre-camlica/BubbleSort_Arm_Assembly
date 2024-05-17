; Emre Çamlica, 150210071
ArraySize		EQU 0x190	; Array size = 100*4 = 400
				AREA copy_array, DATA, READWRITE
				ALIGN
sorted_array	SPACE	ArraySize
sorted_end

time_array		SPACE	ArraySize
time_end
				
				AREA main, CODE, READONLY
				ENTRY
				THUMB
				ALIGN
__main			FUNCTION
SysTick_CTRL        EQU    	0xE000E010    ;SYST_CSR -> SysTick Control and Status Register
SysTick_RELOAD      EQU    	0xE000E014    ;SYST_RVR -> SysTick Reload Value Register
SysTick_VAL         EQU    	0xE000E018    ;SYST_CVR -> SysTick Current Value Register
RELOAD				EQU		1132799 ; 1132799 is my value
START				EQU		0x7;#0111
STOP 				EQU 	0x6 ; #0110
				EXPORT __main

				LDR 	R0, =SysTick_CTRL
				LDR		R1, =SysTick_RELOAD
				LDR		R2, =RELOAD
				LDR		R3, =START
				
				STR		R2, [R1]			; set the reload value
				STR		R3,	[R0]
				
				LDR r0, =sorted_array ; address of the sorted array
				LDR r1, =time_array ; address of the execution times array
				LDR r2, =array	; address of the array
				LDR r3, =ArraySize-4 ; array size-1
				MOVS r7, #0; top loop iterator k

top_loop		
				push {r4, r5, r6} ; registers that will be used in the timer
				BL timer
				pop {r4, r5, r6} ; pop the register values back
				ADDS r1, #4 ; increment r1 by 1
				MOVS r4, #0 ; i = 0
				ADDS r7, #4 ; k=k+1
				CMP r7, r3 ; compare k with array size
				BLS copy ; if not equal, keep doing bubble sort
				B stoptimer	; if equal, exit
				
outer_loop		POP {r7} ; restore the value of r7
				CMP r4, r7 ; compare i with current array size (k)
				BEQ top_loop ; If equal, the array is sorted, stop.
				ADDS r4, #4 ; add 1 to i
				MOVS r5, #0 ; resets j
				PUSH {r7}	; save r7
				B inner_loop ; go to inner loop
				
inner_loop		CMP r4, r5	; compare i and j
				BEQ outer_loop ; If equal, go to outer loop
				LDR r6, [r0, r4] ; r6 = array[i]
				LDR r7, [r0, r5] ; r7 = array[j]
				push {r5} ; r5 is pushed so that it can be used in the swap function as a scratch register
				cmp r6, r7 ; compare a[i] and a[j]
				BLS swap ; if a[i] < a[j], swap the elements
				B cont; else, continue

cont			pop {r5}	; r5, is popped back
				STR r6, [r0, r4] ; stores the greater value at sorted a[i]
				STR r7, [r0, r5] ; stores the smaller value at sorted a[j]
				ADDS r5, #4 ; add 1 to j
				B inner_loop ; go to inner loop
				
swap			MOVS r5, r6 ; r8 = temp = r6
				MOVS r6, r7 ; r6 = r7
				MOVS r7, r5 ; r7 = temp = r6
				B cont ; continue the inner loop

copy			LDR r5, [r2, #0] ; r5 = real a[0]
				STR r5, [r0, #0] ; copy a[0] = r5
				ADDS r4, #4 ; i = i+1
				LDR r5, [r2, r4] ; r5 = real a[i]
				STR r5, [r0, r4] ; copy a[i] = r5
				CMP R4, R7	; checks if i = k
				BNE copy	; if not, keeps copying
				MOVS r4, #0 ; resets i, as it will be used in bubble sort
				PUSH {r7} ; save r7 (to avoid empty stack)
				B outer_loop ; start the bubble sort
				
timer			LDR r5, =SysTick_VAL ; store the systick value pointer in r5
				LDR r6, [r5] ; store the value of systick in r6
				LDR r5, = SysTick_RELOAD ; store the reload value pointer in r5
				LDR r4, [r5]	; store the reload value in r4
				SUBS r4, r4, r6 ; elapsed time is reload value - systick value
				ASRS r4, r4, #6 ; Divided by the CPU frequency (64 MHZ) 
				STR r4, [r1]	; store the systick value in r1
				;STR r6, [r5] ; the new start time is the current systick value
				LDR r6, = RELOAD ; to reset the current time, preventing running over 0. Effectively restarting the timer
				LDR r5, = SysTick_VAL ; Load r5 with systick value pointer
				STR r6, [R5] ; store the restart value in systick value register, to restart the timer
				BX LR ; go back
		
stoptimer		LDR R0, =SysTick_CTRL ; using systick control
				LDR	R3, =STOP	; to stop the timer
				STR	R3,	[R0]
				B stop
					
stop			B stop
				ALIGN
				ENDFUNC


array DCD 0xa603e9e1, 0xb38cf45a, 0xf5010841, 0x32477961, 0x10bc09c5, 0x5543db2b, 0xd09b0bf1, 0x2eef070e, 0xe8e0e237, 0xd6ad2467, 0xc65a478b, 0xbd7bbc07, 0xa853c4bb, 0xfe21ee08, 0xa48b2364, 0x40c09b9f, 0xa67aff4e, 0x86342d4a, 0xee64e1dc, 0x87cdcdcc, 0x2b911058, 0xb5214bbc, 0xff4ecdd7, 0x03da3f26, 0xc79b2267, 0x6a72a73a, 0xd0d8533d, 0x5a4af4a6, 0x5c661e05, 0xc80c1ae8, 0x2d7e4d5a, 0x84367925, 0x84712f8b, 0x2b823605, 0x17691e64, 0xea49cba, 0x01d4386fb, 0xb085bec8, 0x4cc0f704, 0x76a4eca9, 0x83625326, 0x95fa4598, 0xe82d995e, 0xc5fb78cb, 0xaf63720d, 0x0eb827b5, 0xcc11686d, 0x18db54ac, 0x8fe9488c, 0x0e35cf1, 0xd80ec07d, 0xbdfcce51, 0x9ef8ef5c, 0x3a1382b2, 0xe1480a2a, 0xfe3aae2b, 0x2ef7727c, 0xda0121e1, 0x4b610a78, 0xd30f49c5, 0x1a3c2c63, 0x984990bc, 0xdb17118a, 0x7dae238f, 0x77aa1c96, 0xb7247800, 0xb117475f, 0xe6b2e711, 0x1fffc297, 0x144b449f, 0x6f08b591, 0x4e614a80, 0x204dd082, 0x163a93e0, 0xeb8b565a, 0x05326831, 0xf0f94119, 0xeb6e5842, 0xd9c3b040, 0x9a14c068, 0x38ccce54, 0x33e24bae, 0xc424c12b, 0x5d9b21ad, 0x355fb674, 0xb224f668, 0x296b3f6b, 0x59805a5f, 0x8568723b, 0xb9f49f9d, 0xf6831262, 0x78728bab, 0x10f12673, 0x984e7bee, 0x214f59a2, 0xfb088de7, 0x8b641c20, 0x72a0a379, 0x225fe86a, 0xd98a49f3
array_end
				END
