#ifndef UTILITIES_H
#define UTILITIES_H
/*

Maintains variable holding operating mode and arrays to hold position/force data during tracking.

Motor data is sent to client in real-time utalizing a circular buffer data structure.

*/

#define REFERENCE_DATA 14000	// Reference data for trajectory tracking	
#define BUFLEN 1024		// Actual data; sent to client using circular buffer

typedef enum {IDLE, POSITION_HOLD, POSITION_TRACK, HOMING, CURRENT_HOLD, CURRENT_TRACK} mode;    // define data structure containing modes

typedef struct {                          // Define data structure containing control data
    int position_reference[REFERENCE_DATA];
    int position_actual[BUFLEN];
	float current_reference[REFERENCE_DATA];
	float current_actual[BUFLEN];
} control_data_t;

// MODE
mode getMODE();                                       		// Return the current operating mode
void setMODE(mode newMODE);                                 // Set operating mode

// NUMBER OF SAMPLES
void setN_client(void);                             		// Recieve number N of samples to save into data buffer
int getN(void);                                    			// Returns number N of samples  
 
// REFERENCE DATA                                                            
void write_reference_position(int position, int index);  	// Write reference position
int get_reference_position(int index);                  	// Get reference position
void  write_reference_current(float current, int index);	// Write reference current	
float get_reference_current(int index);						// Get reference current

// ACTUAL DATA
int buffer_empty();				// return true if the buffer is empty (read = write)
int buffer_full();				// return true if the buffer is full.
int buffer_read_position();		// reads position from current buffer location; assumes buffer not empty
float buffer_read_current();	// reads current from current buffer location; assumes buffer not empty
void buffer_read_increment();	// increments buffer read index
void buffer_write(int actual_position, float actual_current);	// write data to buffer
void send_data(void);			// send data to client as it becomes available




#endif 