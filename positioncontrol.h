#ifndef POSITIONCONTROL_H
#define POSITIONCONTROL_H

/*

Contains functions for linear motor control.

Linmot driver is configured in current control mode. Current is controlled by differential input (+/-10V) on driver (1V = 1A).

*/
void positioncontrol_setup(void);               	// Setup position control module
void set_position_gains(void);                  	// Set position gains
void get_position_gains(void);                  	// Get position gains
void set_force_gains(void);							// Set force gains
void get_force_gains(void);							// Get force gains
void get_pos(void);                           		// Get desired position from client
void reset_pos(void);								// Reset desired position to origin (0 um)
void load_position_trajectory(void);                // Load desired position trajectory from client
void load_force_trajectory(void);					// Load desired current trajectory from client 
float position_controller(int reference, int acutal);	// Calculates control using PID positiion feedback 
float force_controller(short reference, short actual);	// Calculates control using PID force feedback and motor constant
#endif