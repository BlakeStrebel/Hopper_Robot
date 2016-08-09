#ifndef UTILITIES_H
#define UTILITIES_H

#define DATA_SIZE 2016

typedef enum {IDLE, HOLD, TRACK, LOOP} mode;    // define data structure containing modes

typedef struct {                          // Define data structure containing control data
    float position_reference[DATA_SIZE];
    float position_actual[DATA_SIZE];
	float current_control[DATA_SIZE];
} control_data_t;

// MODE
mode getMODE();                                                                                           	// Return the current operating mode
void setMODE(mode newMODE);                                                                              	// Set operating mode

// NUMBER OF SAMPLES
void setN_manual(int n);                                                                                    // Manually set number N of samples to save into data buffers during next TRACK or ITEST
void setN_client(void);                                                                                     // Recieve number N of samples to save into data buffers during next TRACK or ITEST
int getN(void);                                                                                             // Returns number N of samples  

// DATA                                                            
void write_reference_position(float position, int index);                                                   // Write reference position
void write_actual_position(float position, int index);                                                      // Write actual position
void write_current_control(float current, int index);														// Write control current
float get_reference_position(int index);                                                                    // Get reference position
void send_position_data(void);                                                                         		// Send position buffers to client 

#endif 