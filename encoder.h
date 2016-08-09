#ifndef ENCODER_H
#define ENCODER_H

int encoder_counts(void);   	// Return encoder counts
double encoder_position(void); 	// Return slider position in mm
void encoder_init(void);    	// Initialize module
void encoder_reset(void);   	// Reset encoder position to 0(32768 counts)

#endif