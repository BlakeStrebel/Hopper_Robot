#include "NU32.h"
#include "encoder.h"                   

#define CS LATDbits.LATD0	// chip select pin for encoder

static int encoder_command(int read) { // send a command to the encoder chip
                                       // 0 = reset count to 32,768, 1 = return the count
  CS = 0;							   // start data transmission
  SPI3BUF = read;                      // send the command
  while (!SPI3STATbits.SPIRBF) { ; }   // wait for the response
  SPI3BUF;                             // garbage was transferred, ignore it
  SPI3BUF = 5;                         // write garbage, but the read will have the data
  while (!SPI3STATbits.SPIRBF) { ; }
  CS = 1;							   // stop data transmission
  return SPI3BUF;
}

int encoder_counts(void) {
  return encoder_command(1);
}

int encoder_position(void) {
	static int position; 
	position = (32768 - encoder_counts())*10;	// convert counts to position (um)
    return position;
}

void encoder_reset(void) {
    encoder_command(0);
}

void encoder_init(void) {
  
  TRISDbits.TRISD4 = 0;	// setup chip select pin as output
  CS = 1;
  
  // SPI initialization for reading from the decoder chip
  SPI3CON = 0;              // stop and reset SPI3
  SPI3BUF;                  // read to clear the rx receive buffer
  SPI3BRG = 0x3;            // bit rate to 20 MHz, SPI4BRG = 80000000/(2*desired)-1
  SPI3STATbits.SPIROV = 0;  // clear the overflow
  SPI3CONbits.MSTEN = 1;    // master mode
  SPI3CONbits.MODE16 = 1;   // 16 bit mode
  SPI3CONbits.MODE32 = 0; 
  SPI3CONbits.SMP = 1;      // sample at the end of the clock
  SPI3CONbits.ON = 1;       // turn SPI3 on
}
