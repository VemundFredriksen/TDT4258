#ifndef common
#define common

//The period between sound samples, in clock cycles 
#define   SAMPLE_PERIOD   317

//========== Song declarations ==========//
int happy[31];
int acid1[20];
int acid2[24];
int explosion[48];

int* happySamples;
int* acid1Samples;
int* acid2Samples;
int* explosionSamples;


/*
 *	Function declarations
 */
 
//========== DAC.c ==========//
void setupDAC();
void deactivateDAC();
void writeToDAC(int amplitude);

//========== Timer.c ==========//
void setupTimer(uint16_t period);
void startTimer();
void stopTimer();

//========== ex2.c ==========//
void toSleep(int energyMode);

/*
 *	Macro declarations
 */
 
//Expects the buttoninput from GPIO and the button to check if this button is pressed
#define CHECK_BTN(input,btn) (~(input) & (1<<(btn)))

#endif

