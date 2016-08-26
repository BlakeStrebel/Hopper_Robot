#ifndef UTILITIES_H
#define UTILITIES_H

#define DATA_SIZE 7501

typedef enum {IDLE, HOLD, TRACK, LOOP, HOMING, CURRENT_SET, CURRENT_TRACK} mode;    // define data structure containing modes

typedef struct {                          // Define data structure containing control data
    int position_reference[DATA_SIZE];
    int position_actual[DATA_SIZE];
	float current[DATA_SIZE];
} control_data_t;

// MODE
mode getMODE();                                              	// Return the current operating mode
void setMODE(mode newMODE);                                   	// Set operating mode

// NUMBER OF SAMPLES
void setN_manual(int n);                                 		// Manually set number N of samples to save into data buffers during next TRACK or ITEST
void setN_client(void);                             			// Recieve number N of samples to save into data buffers during next TRACK or ITEST
int getN(void);                                      			// Returns number N of samples  

// POSITION DATA                                                            
void write_reference_position(int position, int index);  		// Write reference position
void write_actual_position(int position, int index);     		// Write actual position
int get_reference_position(int index);                  		// Get reference position
void send_position_data(void);                        			// Send position buffers to client 
// CURRENT DATA
void  write_current(float current, int index);					// Write actual current
float get_reference_current(int index);							// Get reference current
void  send_current_data(void);									// Send data from current mode


#endif 