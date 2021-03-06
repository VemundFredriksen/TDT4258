#include <stdint.h>
#include <stdbool.h>

#include "efm32gg.h"

void activateDAC()
{
	// Enable DAC Clock 
	*CMU_HFPERCLKEN0 |= CMU2_HFPERCLKEN0_DAC0;

	// Select appropriate prescale
	uint32_t dacPrescale = 0x50010;
	*DAC0_CTRL = dacPrescale;

	// Enable left and right sound channel   
	*DAC0_CH0CTRL = 1;
	*DAC0_CH1CTRL = 1;
}

void deactivateDAC()
{
	*DAC0_CTRL = 0;
	*DAC0_CH0CTRL = 0;
	*DAC0_CH1CTRL = 0;
	*CMU_HFPERCLKEN0 &= ~CMU2_HFPERCLKEN0_DAC0;
}

void writeToDAC(int amplitude)
{
	*DAC0_CH0DATA = amplitude;
	*DAC0_CH1DATA = amplitude;
}
