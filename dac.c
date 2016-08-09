#include "dac.h"
#include "NU32.h"

#define CS LATBbits.LATB15       // chip select pin

void dac_init()
{
  // SPI4 pins are: SDO4(F5), SCK4(B14), SS4 (B15)
  
  // set up chip select pin as an output
  // clear CS to low when a command is beginning
  // set CS to high when a command is ending
  TRISBbits.TRISB15 = 0;
  CS = 1;
  
  // setup SPI4
  SPI4CON = 0;              // turn off the SPI module and reset it
  SPI4BUF;                  // clear the rx buffer by reading from it
  SPI4BRG = 0x3;            // baud rate to 20 MHz [SPI4BRG = (80000000/(2*desired))-1]
  SPI4STATbits.SPIROV = 0;  // clear the overflow bit
  SPI4CONbits.CKE = 1;      // data changes when clock goes from hi to lo (since CKP is 0)
  SPI4CONbits.MSTEN = 1;    // master operation
  SPI4CONbits.ON = 1;       // turn on SPI4
}

// send a byte via SPI and return the response
unsigned char SPI4_IO(unsigned char write)
{
    SPI4BUF = write;
    while(!SPI4STATbits.SPIRBF) { // wait to receive the byte
        ;
    }
    return SPI4BUF;
}

// convert voltage value to 8-bit output level (0-255)
unsigned char v_convert(float voltage)
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
// voltages are amplified (G = +/-2) by LM348N Op-amp
void setVoltage(float voltage)
{    
	int channel;
	static int prev_chan;
	unsigned char output;
	
	// Choose output channel
	if (voltage < 0) {
		channel = 1;
		voltage = voltage * -1; // make positive
	} else if (voltage > 0) {
		channel = 0;
	}
	
	output = v_convert(voltage); //convert voltage to 8-bit output level
	
    CS = 0; // start writing
    
    // write data
    // (0-3) config bits 
    // (4-11) 8-bit output level
    // (12-15) XXXX
	SPI4_IO((channel << 7 | 0b01110000)|(output >> 4));
    SPI4_IO(output << 4);
   
    CS = 1; // finish writing (latch data)

	// Check for sign change and zero
	if (!(channel == prev_chan) || output == 0)
	{
		CS = 0;
		SPI4_IO((!channel) << 7 | 0b01110000);
		SPI4_IO(0b00000000);
		CS = 1;
	}
	
	prev_chan = channel;
}