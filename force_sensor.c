#include "force_sensor.h"
#include "NU32.h"

#define CS LATDbits.LATD4	// chip select pin for ADC

void force_sensor_init()
{
  // SPI4 pins are: SDO4(F5), SCK4(B14), SS4(B13)
  
  // set up chip select pins as outputs
  // clear CS to low when a command is beginning
  // set CS to high when a command is ending
  TRISDbits.TRISD4 = 0;
  CS = 1;
  
  
  SPI4CON = 0;              // turn off the SPI module and reset it
  SPI4BUF;                  // clear the rx buffer by reading from it
  SPI4BRG = 19;             // baud rate to 2 MHz [SPI4BRG = (80000000/(2*desired))-1]
  SPI4STATbits.SPIROV = 0;  // clear the overflow bit
  SPI4CONbits.CKE = 1;      // data changes when clock goes from hi to lo (since CKP is 0)
  SPI4CONbits.MSTEN = 1;    // master operation
  SPI4CONbits.ON = 1;       // turn on SPI4
  
}

// send a byte via SPI and return the response
unsigned char SPI4_IO_F(unsigned char write)
{
    SPI4BUF = write;
    while(!SPI4STATbits.SPIRBF) { // wait to receive the byte
        ;
    }
    return SPI4BUF;
}

short force_read(void)	// return force reading in counts
{
	unsigned char TB1, RB1, RB2, RB3;
	short counts;
	
	// configure adc to read bipolar differential voltage between Ch0 and Ch1
	TB1 = 0b10000011;
	
	CS = 0; // start writing
	RB1 = SPI4_IO_F(TB1);	// send control byte
	RB2 = SPI4_IO_F(0x00);	// recieve force output (12-bit two's compliment)
	RB3 = SPI4_IO_F(0x00);	
	CS = 1; // stop writing
	
	// convert force output into counts
	counts = (RB2 << 4) | (RB3 >> 4);
	
	if (RB2 >> 7)
	{
	counts = -1 * ((~counts + 1 ) & 0x0FFF);	// implement two's compliment
	}

	return counts;
	}