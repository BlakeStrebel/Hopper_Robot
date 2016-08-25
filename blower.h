#ifndef BLOWER_H
#define BLOWER_H

void blowercontrol_setup(void);
void blower_on(void);
void blower_off(void);
void setFrequency(float frequency);
unsigned int ADC_read(void);
float frequency_read(void);

#endif