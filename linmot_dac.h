#ifndef LINMOT_DAC_H
#define LINMOT_DAC_H

/*

Contains functions which allow writing to digital-to-analog converters used for linear motor


*/

void linmot_dac_init();
unsigned char convert8(float voltage);
void setVoltage_L(float voltage);


#endif
