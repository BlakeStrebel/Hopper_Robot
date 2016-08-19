#include "NU32.h"
#include "blower.h"
#include "blower_dac.h"

#define BLOWER_ON LATDbits.LATD6

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

