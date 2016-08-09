#ifndef POSITIONCONTROL_H
#define POSITIONCONTROL_H

void set_position_gains(void);                  	// Set position gains
void get_position_gains(void);                  	// Get position gains
void positioncontrol_setup(void);               	// Setup position control module
void get_pos(void);                           		// Get desired position from client
void reset_pos(void);								// Reset desired position to origin (0 mm)
void load_trajectory(void);                     	// Load desired trajectory from client
void PID_controller(float reference, float acutal); // Calculates control
#endif