#ifndef ENCODER_H
#define ENCODER_H
/*

Linmot AB Encoder Simulation (RS422) is used to determine slider position.

Encoder is configured with:
	Resolution r (1/4 Period Length): 10 um
	Minimal Edge Separation: 1 us
	Max velocity: 10um/1us = 10 m/s

Decoder is preprogrammed dsPIC
(drive) -> (dsPIC)
A+ (X13.9)  -> B8
B+ (X13.10) -> B7

Decoder communicates with PIC32 via SPI3
(PIC32) -> (dsPIC)
SDO3(D3) -> B13
SDI3(D2) -> B14
SCK3(D1) -> B12
SS3(D0)  -> B9

*/

int encoder_counts(void);   	// Return encoder counts
int encoder_position(void); 	// Return slider position in um
void encoder_init(void);    	// Initialize module
void encoder_reset(void);   	// Reset encoder position to 0(32768 counts)

#endif