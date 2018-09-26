        .syntax unified
	
	      .include "efm32gg.s"

	/////////////////////////////////////////////////////////////////////////////
	//
    // Exception vector table
    // This table contains addresses for all exception handlers
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .section .vectors
	
	      .long   stack_top               /* Top of Stack                 */
	      .long   _reset                  /* Reset Handler                */
	      .long   dummy_handler           /* NMI Handler                  */
	      .long   dummy_handler           /* Hard Fault Handler           */
	      .long   dummy_handler           /* MPU Fault Handler            */
	      .long   dummy_handler           /* Bus Fault Handler            */
	      .long   dummy_handler           /* Usage Fault Handler          */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* SVCall Handler               */
	      .long   dummy_handler           /* Debug Monitor Handler        */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* PendSV Handler               */
	      .long   dummy_handler           /* SysTick Handler              */

	      /* External Interrupts */
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO even handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO odd handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler

	      .section .text

	/////////////////////////////////////////////////////////////////////////////
	//
	// Reset handler
    // The CPU will start executing here after a reset
	//
	/////////////////////////////////////////////////////////////////////////////

	      .globl  _reset
	      .type   _reset, %function
        .thumb_func
_reset:
	
	
	
	LDR R1, =CMU_BASE					//Loads the adress of the CMU_BASE
	LDR R2, [R1, #CMU_HFPERCLKEN0]		//Loads the content of the CMU_HFPERCLKNO memory
	
	MOV R3, #1							//
	LSL R3, R3, #13						//Sets the 13th bit high (GPIO-bit)
	ORR R2, R2, R3						//Enables the 13th bit in addition to other bits enabled
	
	STR R2, [R1, #CMU_HFPERCLKEN0]		//Stores the new enable-flags in the CMUHFPERCLKEN0-memory slot
	
	//=============================/
	
	LDR R0, =GPIO_PA_BASE				//Sets drive strength
	MOV R2, #0x2						//
	STR R2, [R1]						//

	ADD R7, R0, #GPIO_DOUT				//GPIO_PA_DOUT Constant for writing LEDs

	ADD R1, R0, #GPIO_MODEH				//Sets Port A to output
	LDR R2, =0x55555555					//
	STR R2, [R1]						//
	
	LDR R0, =GPIO_PC_BASE				//Sets Port C to input-mode
	LDR R2, =0x33333333
	ADD R1, R0, #GPIO_MODEL				
	STR R2, [R1]
	
	ADD R8, R0, #GPIO_DIN				//GPIO_PC_DIN Constant for reading buttons
	
	MOV R2, #0xff						//Enables pull-up resistors (C-port)
	ADD R1, R0, #GPIO_DOUT
	STR R2, [R1]
	
	MOV R1, #0xff						//Sets all bits in the LED-array high (because of active-low)
	LSL R1, #8							//Left shift 8 because LEDs are in the range [8, 15] in the GPIO_PA_DOUT
	STR R1, [R7]						//Updates memorylocation of GPIO_PA_DOUT
	
	LDR R0, =GPIO_BASE					//Clears interruptflags
	LDR R2, [R0, #GPIO_IF]
	STR R2, [R0, #GPIO_IFC]
	
	ADD R2, R0, #GPIO_EXTIPSELL			//Sets GPIO_EXTIPSELL to 0x22222222
	LDR R1, =0x22222222					//
	STR R1, [R2]						//
	
	ADD R2, R0, #GPIO_EXTIFALL			//Enabled interrupt on falling edge
	MOV R1, #0xff						//
	STR R1, [R2]						//
	
	ADD R2, R0, #GPIO_EXTIRISE
	MOV R1, #0xff
	STR R1, [R2]
	
	ADD R2, R0, #GPIO_IEN				//Enabled GPIO_IEN
	MOV R1, #0xff						//
	STR R1, [R2]						//
	
	
	
	LDR R2, =ISER0						//Enables interrupt handling
	LDR R1, =0x802						//
	STR R1, [R2]						//
	
	MOV R1, #0xff						//Sets all bits in the LED-array high (because of active-low)
	LSL R1, #8							//Left shift 8 because LEDs are in the range [8, 15] in the GPIO_PA_DOUT
	STR R1, [R7]						//Updates memorylocation of GPIO_PA_DOUT
	
	B main
	
	
main:
	B main


	
        .thumb_func
gpio_handler:  

		LDR R0, =GPIO_BASE					//Clears interruptflags
		LDR R2, [R0, #GPIO_IF]
		STR R2, [R0, #GPIO_IFC]

	    LDR R0, [R8]						//Buttons state
	
	
		AND R2, R0, #0x20					//Checks if Up-button is pressed
		CMP R2, #0x0						//
		BEQ add_dot							//If up is pressed
		AND R2, R0, #0x80					//Checks if Down-button is pressed
		CMP R2, #0x0						//
		BEQ remove_dot						//if down is pressed
		AND R2, R0, #0x40					//Checks if Right-button is pressed
		CMP R2, #0x0						//
		BEQ shift_right						//if right is pressed 
		AND R2, R0, #0x10					//Checks if Right-button is pressed
		CMP R2, #0x0						//
		BEQ shift_left						//if left is pressed
		
		B main

add_dot:					//Adds a dot to the 5th bit on the LED-array
	LSR R1, #8				//Rightshifts the array so we can work on bit 0 to 7
	MOV R2, #0x10			//Sets the 5 bit
	
	EOR R1, R1, #0xff		//Flips all the bits
	
	ORR R1, R1, R2			//Enables bit 5 in addition to other enabled bits in the LED-array
	EOR R1, R1, #0xff		//Flips the bits because LEDs are active low
	LSL R1, #8				//Left shift because LEDs are controlled on bit 8 to 15
	STR R1, [R7]			//Updates the LEDs memory location
	
	B main

remove_dot:					//Removes a dot from the 5th bit in the LED-array

	LSR R1, #8				//Rightshifts the array so we can work on bit 0 to 7
	MOV R2, #0x10			//Sets the 5 bit
	
	ORR R1, R1, R2			//Set bit 5 and keep others state intact, set the bit because of active-low
	
	LSL R1, #8				//Shifts the LED-array left again
	STR R1, [R7]			//Updates the state in the memory location

	B main
shift_right:
	
	
	LSR R1, #7				//Right-shifts 8 minus the one the dot should move
	ORR R1, 0x1				//Since the rightshift will add a 0 to the end, a 1 must be added
	LSL R1, #8				//Left shifts back into the [8, 15] range
	STR R1, [R7]			//Updates the LEDs

	B main
	
shift_left:
	
	LSR R1, #9				//Right-shifts 8 minus the one the dot should move
	ORR R1, 0x80			//Since the rightshift will add a 0 to the end, a 1 must be added
	LSL R1, #8				//Left shifts back into the [8, 15] range
	STR R1, [R7]			//Updates the LEDs
	
	
	B main

	/////////////////////////////////////////////////////////////////////////////
	
	.thumb_func
dummy_handler:  
        B main	
