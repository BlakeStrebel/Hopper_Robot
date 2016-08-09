#ifndef LINMOT_H
#define LINMOT_H

void io_init(void);
void motor_off(void);
void state(void);				// Print motor status
void motor_startup(void);		// Start motor
void home(void);				// Perform homing
void error_ack(void);			// Acknowledge motor error
void setCurrent(float voltage);
void motor_on(void);

#endif 