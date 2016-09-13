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
  
/*   // setup SPI3
  SPI3CON = 0;              // turn off the SPI module and reset it
  SPI3BUF;                  // clear the rx buffer by reading from it
  SPI3BRG = 0x3;            // baud rate to 20 MHz [SPI4BRG = (80000000/(2*desired))-1]
  SPI3STATbits.SPIROV = 0;  // clear the overflow bit
  SPI3CONbits.CKE = 1;      // data changes when clock goes from hi to lo (since CKP is 0)
  SPI3CONbits.MSTEN = 1;    // master operation
  SPI3CONbits.ON = 1;       // turn on SPI3 */
}

// send a byte via SPI and return the response
unsigned char SPI3_IO_L(unsigned char write)
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
	static int channel;
	static int prev_chan;
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
    
    // write data
    // (0-3) config bits 
    // (4-11) 8-bit output level
    // (12-15) XXXX
	SPI3_IO_L((channel << 7 | 0b01110000)|(output >> 4));
    SPI3_IO_L(output << 4);
   
    CS = 1; // finish writing (latch data)

	// check for sign change and zero
	if (!(channel == prev_chan) || output == 0)
	{
		CS = 0;
		SPI3_IO_L((!channel) << 7 | 0b01110000);
		SPI3_IO_L(0b00000000);
		CS = 1;
	}
	
	prev_chan = channel;
}
