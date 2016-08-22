#ifndef BLOWER_H
#define BLOWER_H

void blower_init(void);
void blower_on(void);
void blower_off(void);
void setFrequency(float frequency);
unsigned int ADC_read(void);
void ADC_setup(void);
float frequency_read(void);

#endif