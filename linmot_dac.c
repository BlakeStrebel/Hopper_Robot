#include "linmot_dac.h"
#include "NU32.h"

#define CS LATDbits.LATD4	// chip select pin for linear motor

void linmot_dac_init()
{
  // SPI3 pins are: SDO3(D2), SCK3(D1), SS3(D4)
  
  // set up chip select pins as outputs
  // clear CS to low when a command is beginning
  // set CS to high when a command is ending
  TRISDbits.TRISD4 = 0;
  CS = 1;
  

/*   SPI3CONbits.CKE = 1;      // data changes when clock goes from hi to lo (since CKP is 0)
    // SPI initialization for reading from the decoder chip
  SPI3CON = 0;              // stop and reset SPI3
  SPI3BUF;                  // read to clear the rx receive buffer
  SPI3BRG = 0x3;            // bit rate to 20 MHz, SPI4BRG = 80000000/(2*desired)-1
  SPI3STATbits.SPIROV = 0;  // clear the overflow
  SPI3CONbits.MSTEN = 1;    // master mode
  SPI3CONbits.MODE16 = 1;   // 16 bit mode
  SPI3CONbits.MODE32 = 0; 
  SPI3CONbits.SMP = 1;      // sample at the end of the clock
  SPI3CONbits.ON = 1;       // turn SPI3 on */
}

// send two bytes via SPI and return the response
unsigned short SPI3_IO_L(unsigned short write)
{
    SPI3BUF = write;
    while(!SPI3STATbits.SPIRBF) { // wait to receive the byte
        ;
    }
    return SPI3BUF;
}

// convert voltage value to 8-bit output level (0-255)
unsigned char convert8(float voltage)
{
	// adjust large values
	if (voltage > 10)
	{
		voltage = 10;
	}
	
	return voltage*25.5;
}

// set voltage for MCP4902 DAC
// positive voltages are output by VoutA
// negative voltages are output by VoutB
// voltages are amplified (G = 2) by LM348N Op-amp
// amplified voltages are fed into linmot driver
void setVoltage_L(float voltage)
{    
	static int channel, prev_chan;
	static unsigned char output;
	
	// Choose output channel
	if (voltage < 0) {
		channel = 1;
		voltage = voltage * -1; // make positive
	} else if (voltage > 0) {
		channel = 0;
	}
	
	output = convert8(voltage); //convert voltage to 8-bit output level
	
	CS = 0; // start writing
	SPI3_IO_L((channel << 15 | 0x7000)|(output << 4)); // (0-3)config bits; (4-11) 8-bit output level; (12-15) XXXX
	CS = 1; // finish writing

	// check for sign change and zero
	if (!(channel == prev_chan) || output == 0)
	{
		CS = 0;
		SPI3_IO_L((!channel) << 15 | 0x7000)); 	// set output level to zero
		CS = 1;
	}
	
	prev_chan = channel;
}
