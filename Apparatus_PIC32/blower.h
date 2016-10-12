#ifndef BLOWER_H
#define BLOWER_H
/*

Contains functions used to control blower motor

*/

void blowercontrol_setup(void);			// setup blower control
void blower_on(void);					// turn on the blower
void blower_off(void);					// turn off the blower
void setFrequency(float frequency);		// set blower frequency

#endif