#include "NU32.h"
#include <stdio.h>
#include "blower.h"
#include "blower_dac.h"
#include "utilities.h"

#define BLOWER_ON LATDbits.LATD6
#define NUMSAMP 301

static volatile int R;
static volatile float reference_frequency[NUMSAMP];
static volatile float actual_frequency[NUMSAMP];

void blowercontrol_setup(void)// setup blower control module
{

	TRISDbits.TRISD6 = 0;	// set up blower on/off switch
	blower_off();			// turn off blower
	
	// Set up AD10 as analog input
	AD1PCFGbits.PCFG10 = 0;	        // configure B10 as analog input
    AD1CON3bits.ADCS = 2;           // tad = 2 * 12.5 ns * (ADCS + 1) = 75ns
    AD1CON1bits.SSRC = 0b111;       // auto conversion
	AD1CON1bits.ASAM = 0;			// manual sampling
    AD1CON1bits.ON = 1;             // turn on ADC
}

void blower_on(void)
{
	BLOWER_ON = 1;	// turn on the blower	
}

void blower_off(void)
{
	BLOWER_ON = 0;		// turn off the blower
	setFrequency(0);	// set frequency to 0
}

void setFrequency(float frequency)
{
	static float scale = 12;				// scale factor for conversion				
	static float offset = 0;				// offset for conversion
	setVoltage_B(frequency/scale + offset);	// convert frequency to voltage and set
}

unsigned int ADC_read(void)
{
	static unsigned int elapsed, finish_time;
    static int i, adcval;
     
    adcval = 0;  
    for (i = 0; i < 9; i++) {
       
        AD1CHSbits.CH0SA = 10;      // connect AN10 to MUXA for sampling
        AD1CON1bits.SAMP = 1;       // start sampling
        elapsed = _CP0_GET_COUNT();
        finish_time = elapsed + 100;                       // 100 core timer ticks = 3750 ns
        while (_CP0_GET_COUNT() < finish_time) {;}         // sample for more than 3750 ns
        while (!AD1CON1bits.DONE){;}                       // wait for conversion process to finish
        
        adcval = adcval + ADC1BUF0; // read buffer with result
    }
    return adcval / 10 ;    // return average ADC reading
}

float frequency_read(void)
{
	int adc = ADC_read();				// read 16-bit adc value
	float scale = (float)60/1023;		// scale factor for conversion
	float frequency = (float)adc*scale;	// convert adc value to frequency
	return frequency;				
}

