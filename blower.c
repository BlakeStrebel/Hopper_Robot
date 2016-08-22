#include "NU32.h"
#include <stdio.h>
#include "blower.h"
#include "blower_dac.h"

#define BLOWER_ON LATDbits.LATD6

void blower_init(void)
{
	TRISDbits.TRISD6 = 0;
	blower_off();
}

void setFrequency(float frequency)
{
	static float scale = 12;
	static float offset = 0;
	setVoltage_B(frequency/scale + offset);
}

void blower_on(void)
{
	BLOWER_ON = 1;
}

void blower_off(void)
{
	BLOWER_ON = 0;
	setFrequency(0);
}

void ADC_setup(void)
{
    AD1PCFGbits.PCFG10 = 0;	        // configure B10 as analog input
    AD1CON3bits.ADCS = 2;           // tad = 2 * 12.5 ns * (ADCS + 1) = 75ns
    AD1CON1bits.SSRC = 0b111;       // auto conversion
	AD1CON1bits.ASAM = 0;			// manual sampling
    AD1CON1bits.ON = 1;             // turn on ADC
}

unsigned int ADC_read(void)
{
	    AD1CHSbits.CH0SA = 10;      // connect AN10 to MUXA for sampling
        AD1CON1bits.SAMP = 1;       // start sampling
		while (!AD1CON1bits.DONE){
            ;                       // wait for conversion process to finish
        }
		return ADC1BUF0;          // return buffer with result
}

float frequency_read(void)
{
	int adc = ADC_read();
	float scale = (float)60/1023;
	float frequency = (float)adc*scale;
	return frequency;
}