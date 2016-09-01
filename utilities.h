#ifndef UTILITIES_H
#define UTILITIES_H
/*

Contains system mode, data buffers, and functions for data handling

*/

#define CURRENT_DATA_SIZE 13001		// Adjust sizes to optimize data collection time (or implement circular buffering/decimation)
#define POSITION_DATA_SIZE 2500		

typedef enum {IDLE, HOLD, TRACK, LOOP, HOMING, CURRENT_SET, CURRENT_TRACK} mode;    // define data structure containing modes

typedef struct {                          // Define data structure containing control data
    int position_reference[POSITION_DATA_SIZE];
    int position_actual[CURRENT_DATA_SIZE];
	float current_reference[CURRENT_DATA_SIZE];
	float current_actual[POSITION_DATA_SIZE];
} control_data_t;

// MODE
mode getMODE();                                       		// Return the current operating mode
void setMODE(mode newMODE);                                 // Set operating mode

// NUMBER OF POSITION SAMPLES
void setN_manual(int n);                                	// Manually set number N of samples to save into data buffers during next TRACK
void setN_client(void);                             		// Recieve number N of samples to save into data buffers during next TRACK
int getN(void);                                    			// Returns number N of samples  
// NUMBER OF CURRENT SAMPLES
void setM_manual(int m);                               		// Manually set number M of samples to save into data buffers during next CURRENT_TRACK
void setM_client(void);                           			// Recieve number M of samples to save into data buffers during next CURRENT_TRACK
int getM(void);                                    			// Returns number M of samples  

// POSITION DATA                                                            
void write_reference_position(int position, int index);  	// Write reference position
void write_actual_position(int position, int index);     	// Write actual position
int get_reference_position(int index);                  	// Get reference position
void send_position_data(void);                        		// Send position buffers to client 
// CURRENT DATA
void  write_reference_current(float current, int index);	// Write reference current
void write_actual_current(float current, int index);		// Write actual current	
float get_reference_current(int index);						// Get reference current
void  send_current_data(void);								// Send data from current mode


#endif 