#ifndef FORCE_SENSOR_H
#define FORCE_SENSOR_H

/*

ATI Mini45 Force Sensor data is interpretted by F/T Controller. Controller outputs 6 differential analog output voltages (+/-5V)
representing Fx,Fy,Fz,Tx,Ty, and Tz. Fz value is read by 12-bit ADC converter (MAX1203) and communicated to PIC32 via SPI.

*/




void force_sensor_init();
unsigned char SPI4_IO_F(unsigned char write);
short adc_read(void);



#endif