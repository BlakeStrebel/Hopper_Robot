#ifndef LINMOT_DAC_H
#define LINMOT_DAC_H

/*

Contains functions which allow writing to digital-to-analog converters used for linear motor

*/

void linmot_dac_init();							// initialize dac control
unsigned char convert8(float voltage);			// convert float to 8 bit voltage output level
void setVoltage_L(float voltage);				// set linmot dac voltage
unsigned char SPI4_IO_L(unsigned char write);	// send a byte over spi and return the response


#endif
