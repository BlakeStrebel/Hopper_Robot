#include "NU32.h"
#include <stdio.h>
#include "blower.h"
#include "blower_dac.h"
#include "utilities.h"

#define BLOWER_ON LATDbits.LATD6

void blowercontrol_setup(void)// setup blower control module
{

	TRISDbits.TRISD6 = 0;	// set up blower on/off switch
	blower_off();			// turn off blower
	
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

