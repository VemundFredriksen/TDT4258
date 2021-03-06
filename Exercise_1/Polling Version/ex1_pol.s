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
	
	LDR R0, =GPIO_PA_BASE
	LDR R1, =GPIO_PC_BASE
	
	//Constant Registers
	ADD R7, R1, #GPIO_DIN				//MemoryLocation of ButtonInput: 	R7
	ADD R8, R0, #GPIO_DOUT				//MemoryLocation of LEDOutput:		R8
	// R3								//Last Button State					R3
	
	
	//=========== ENABLE CMU CLOCK FOR PERIPHIRALS ============//
	
	LDR R2, =CMU_BASE					//Adress of CMU_BASE
	LDR R3, [R2, #CMU_HFPERCLKEN0]		//Status of CMU_HFPERCLKEN0
	
	MOV R4, #1
	LSL R4, R4, #13						//Sets bit 13
	ORR R3, R3, R4						//Sets bit 13 in addition to other set bits
	STR R3, [R2, #CMU_HFPERCLKEN0]		//Updates CMU_HFPERCLKEN0 in memory	
	
	//=========== SETS DRIVE STRENGTH ===========//
	
	MOV R2, #0x2
	STR R2, [R0, #GPIO_CTRL]			//Stores 0x2 in GPIO_PA_CTRL
	
	//========== SETS PORT A TO OUTPUT ==========//
	
	LDR R2, =0x55555555
	STR R2, [R0, #GPIO_MODEH]			//Stores 0x55555555 GPIO_PA_MODEH memory location
	
	//========== SETS POR C TO INPUT ===========//
	
	LDR R2, =0x33333333
	STR R2, [R1, #GPIO_MODEL]
	
	//========= ENABLE PULLUP RESISTORS IN C PORT =========//
	
	MOV R2, #0xFF
	STR R2, [R1, #GPIO_DOUT]
	
	
	MOV R2, #0xFF						//Turns the LEDs off
	LSL R2, #8							//
	STR R2, [R8]						//
	
	B polling_func
	
		.thumb_func
polling_func:
	
	LDR R0, [R7]						//Loads button state into R0
	
	CMP R0, R3						//Checks if button state are changed
	BEQ polling_final_func			//If button state are not changed
	
	ANDS R2, R0, #0x20					//Checks if Up-button is pressed
	BEQ add_dot							//If up is pressed
	ANDS R2, R0, #0x80					//Checks if Down-button is pressed
	BEQ remove_dot						//if down is pressed
	ANDS R2, R0, #0x40					//Checks if Right-button is pressed
	BEQ shift_right						//if right is pressed 
	ANDS R2, R0, #0x10					//Checks if Right-button is pressed
	BEQ shift_left						//if left is pressed	
	
	
	B polling_final_func
	
polling_final_func:						//Should be the last call before starting the loop again
	
	MOV R3, R0							//Last button state
	
	B polling_func

add_dot:								//Adds a dot to the 5th bit on the LED-array
	LDR R1, [R8]						//Loads LED-state into R1
	
	LSR R1, #8							//Rightshifts the array so we can work on bit 0 to 7
	MOV R2, #0xEF						//Sets all bits except bit 5
	AND R1, R1, R2						//Clears LED 5 in the LED array
	
	LSL R1, #8							//Left shift because LEDs are controlled on bit 8 to 15
	STR R1, [R8]						//Updates the LEDs memory location
	
	B polling_final_func

remove_dot:					//Removes a dot from the 5th bit in the LED-array

	LDR R1, [R8]						//Loads LED-state into R1
	
	LSR R1, #8							//Rightshifts the array so we can work on bit 0 to 7
	MOV R2, #0x10						//Sets the 5 bit
	
	ORR R1, R1, R2						//Set bit 5 and keep others state intact, set the bit because of active-low
	
	LSL R1, #8							//Shifts the LED-array left again
	STR R1, [R8]						//Updates the state in the memory location

	B polling_final_func	

shift_right:
	LDR R1, [R8]						//Loads LED-state into R1
		
	LSR R1, #7							//Right-shifts 8 minus the one the dot should move
	ORR R1, 0x1							//Since the rightshift will add a 0 to the end, a 1 must be added
	LSL R1, #8							//Left shifts back into the [8, 15] range
	STR R1, [R8]						//Updates the LEDs
	
	B polling_final_func
	
shift_left:
	LDR R1, [R8]						//Loads LED-state into R1
	
	LSR R1, #9							//Right-shifts 8 minus the one the dot should move
	ORR R1, 0x80						//Since the rightshift will add a 0 to the end, a 1 must be added
	LSL R1, #8							//Left shifts back into the [8, 15] range
	STR R1, [R8]						//Updates the LEDs
	
	
	B polling_final_func

	
	.thumb_func
dummy_handler:  
        B polling_final_func

