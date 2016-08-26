#ifndef POSITIONCONTROL_H
#define POSITIONCONTROL_H

/*
Linmot driver is configured in current control mode. Current is controlled by differential input (+/-10V) on driver (1V = 1A).

PIC32 utalizes PID feedback control to control motor position. 


*/

void set_position_gains(void);                  	// Set position gains
void get_position_gains(void);                  	// Get position gains
void positioncontrol_setup(void);               	// Setup position control module
void get_pos(void);                           		// Get desired position from client
void reset_pos(void);								// Reset desired position to origin (0 um)
void load_position_trajectory(void);                // Load desired trajectory from client
void load_current_trajectory(void); 
float PID_controller(int reference, int acutal);	// Calculates control
#endif