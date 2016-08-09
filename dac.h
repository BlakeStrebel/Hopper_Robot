#ifndef DAC_H
#define DAC_H

void DAC_init();
unsigned char SPI4_IO(unsigned char write);
unsigned char v_convert(float voltage);
void setVoltage(float voltage);

#endif
