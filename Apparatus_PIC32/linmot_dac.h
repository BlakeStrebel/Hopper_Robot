#ifndef LINMOT_DAC_H
#define LINMOT_DAC_H

/*

Contains functions which allow writing to digital-to-analog converters used for linear motor
MCP4902

*/

void linmot_dac_init();							// initialize dac control
unsigned char convert8(float voltage);			// convert float to 8 bit voltage output level
void setVoltage_L(float voltage);				// set linmot dac voltage
static int SPI3_IO_L(unsigned short write);		// send two bytes over spi and return the response


#endif
