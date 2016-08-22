#ifndef BLOWER_DAC_H
#define BLOWER_DAC_H

/*

Contains functions which allow writing to digital-to-analog converters used for blower motor


*/

void blower_dac_init();
unsigned short convert12(float voltage);
void setVoltage_B(float voltage);
unsigned char SPI4_IO_B(unsigned char write);

#endif