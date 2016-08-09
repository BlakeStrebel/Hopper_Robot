#include <stdio.h>
#include "NU32.h"
#include "linmot.h"
#include "utilities.h"
#include "dac.h"
#include "encoder.h"
#include "positioncontrol.h"

// define state machine I/O
#define SWITCH_ON LATBbits.LATB0		// B0 -> Switch on (X14.14)
#define HOME LATBbits.LATB1 			// B1 -> Home (X14.2)
#define ERROR_ACK LATBbits.LATB2 		// B2 -> Error Acknowledge (X14.15)
#define SPECIAL_MODE LATBbits.LATB3 	// B3 -> Special Mode (X14.3)
#define GO_INIT_POS LATBbits.LATB4 		// B4 -> Go To Initial Position (X14.16)
#define IN_TARG_POS PORTEbits.RE0		// E0 <- In Target Position (X14.5)
#define WARNING PORTEbits.RE1			// E1 <- Warning (X14.18)	
#define ERROR PORTEbits.RE2				// E2 <- Error (X14.6)
#define SPECIAL_MOTION PORTEbits.RE3	// E3 <- Special Motion Active (X14.19)

// logic for outputs (note: drive configuration determines logic)
#define ON		1
#define OFF  	0
	
void io_init(void) {
	
	// initialize output pins
	TRISBbits.TRISB0 = 0;
	TRISBbits.TRISB1 = 0;
	TRISBbits.TRISB2 = 0;
	TRISBbits.TRISB3 = 0;
	TRISBbits.TRISB4 = 0;
	
	// initialize input pins
	TRISEbits.TRISE0 = 1;
	TRISEbits.TRISE1 = 1;
	TRISEbits.TRISE2 = 1;
	TRISEbits.TRISE3 = 1;
	
	// turn off outputs
	SWITCH_ON = OFF;
	HOME = OFF;
	ERROR_ACK = OFF;
	SPECIAL_MODE = OFF;
	GO_INIT_POS = OFF; 
	
}

void motor_off(void) {
	SWITCH_ON = OFF;
	setCurrent(0);
}

void motor_on(void) {
	SWITCH_ON = ON;
}

void state(void)
{
	int i; char buffer[10];
	int state[] = {!SWITCH_ON, !HOME, !ERROR_ACK, !SPECIAL_MODE, !GO_INIT_POS, IN_TARG_POS, WARNING, ERROR, SPECIAL_MOTION}; //logic flipped for outputs
	
	for (i = 0; i < 9; i++) {      
        sprintf(buffer, "%d\r\n",state[i]);  // store data in buffer
        NU32_WriteUART3(buffer);              // write data to client
    }
	
}

void home(void)
{
	HOME = ON;			// begin homing sequence	
	while (!IN_TARG_POS){
		;	// wait for homng sequence to complete
	}
	encoder_reset();	// set home position
	HOME = OFF;			// complete homing sequence
}

void error_ack(void)
{
	ERROR_ACK = ON;
	_CP0_SET_COUNT(0);
	while (_CP0_GET_COUNT() < 20000000){
		;
	}
	ERROR_ACK = OFF;
}

void setCurrent(float voltage)
{
	static float scale = 1;
	static float offset = -0.04;
	setVoltage(voltage*scale + offset);
}

void motor_startup(void) {
	
	setCurrent(0);	// set voltage (motor current) to zero
	
	error_ack();	// acknowledge any errors	

	// enable position control of the motor
	SWITCH_ON = OFF;
	_CP0_SET_COUNT(0);
	while (_CP0_GET_COUNT() < 20000000){
		;
	}
	
	motor_on();	// Switch on
	
	home();				// perform homing sequence
	SPECIAL_MODE = ON;	// enable current control
	
	reset_pos();	// reset desired position to 0 mm
	
	setMODE(HOLD);	// set MODE to HOLD
}


