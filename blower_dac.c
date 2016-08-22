#include "NU32.h"
#include "blower_dac.h"


#define CS LATBbits.LATB13	// chip select pin for blower motor

void blower_dac_init()
{
  // SPI4 pins are: SDO4(F5), SCK4(B14), SS4(B13)
  
  // set up chip select pins as outputs
  // clear CS to low when a command is beginning
  // set CS to high when a command is ending
  TRISBbits.TRISB13 = 0;
  CS = 1;
  
  /*
  SPI4CON = 0;              // turn off the SPI module and reset it
  SPI4BUF;                  // clear the rx buffer by reading from it
  SPI4BRG = 0x3;            // baud rate to 20 MHz [SPI4BRG = (80000000/(2*desired))-1]
  SPI4STATbits.SPIROV = 0;  // clear the overflow bit
  SPI4CONbits.CKE = 1;      // data changes when clock goes from hi to lo (since CKP is 0)
  SPI4CONbits.MSTEN = 1;    // master operation
  SPI4CONbits.ON = 1;       // turn on SPI4
*/
}

// send a byte via SPI and return the response
unsigned char SPI4_IO_B(unsigned char write)
{
    SPI4BUF = write;
    while(!SPI4STATbits.SPIRBF) { // wait to receive the byte
        ;
    }
    return SPI4BUF;
}

// convert voltage value to 12-bit output level (0-4095)
unsigned short convert12(float voltage)
{
	// set max/min
	if (voltage > 5)
	{
		voltage = 5;
	} 
	else if (voltage < 0)
	{
		voltage = 0;
	}
	
	return voltage*819;
}

// set voltage for MCP4921 DAC
// voltage is fed into FRENIC-mini blower motor driver
void setVoltage_B(float voltage)
{    
	static unsigned short output;

	output = convert12(voltage);
	
    CS = 0; // start writing
    
    // write data
    // (15-12) config bits 
    // (11-0) 12-bit output level
    
	SPI4_IO_B(0b01110000|(output >> 8));
    SPI4_IO_B(0b00000000|output);
	
	CS = 1; // finish writing (latch data)
}
