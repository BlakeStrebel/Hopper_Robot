#ifndef DAC_H
#define DAC_H

/*

Contains functions which allow writing to digital-to-analog converters used for linear motor and blower motor control.


*/

void DAC_init();
unsigned char SPI4_IO(unsigned char write);
unsigned char v_convert8(float voltage);
void setVoltage_L(float voltage);
unsigned short v_convert12(float voltage)




#endif
