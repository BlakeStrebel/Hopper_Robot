#ifndef BLOWER_DAC_H
#define BLOWER_DAC_H
/*

Contains functions which allow writing to digital-to-analog converters used for blower motor

*/

void blower_dac_init();							// initialize dac control
unsigned short convert12(float voltage);		// convert float to 12 bit voltage output level
void setVoltage_B(float voltage);				// set voltage for blower dac
unsigned char SPI4_IO_B(unsigned char write);	// send a byte via spi and return the response

#endif