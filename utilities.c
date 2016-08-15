#include <stdio.h>
#include "NU32.h"
#include "utilities.h"
#include "linmot.h" 
 
         
static volatile mode MODE;            	// Operating mode
static volatile control_data_t DATA;    // Struct containing data arrays
static volatile int N;                      // Number of samples to store

void setMODE(mode newMODE) {  // Set mode
    MODE = newMODE;     // Update global MODE
}

mode getMODE() {  // Return current mode
    return MODE;    // Return MODE
}

void setN_client(void)          // Recieve number of values to store in data arrays from client
{                   
    char buffer[10];            // Buffer holding number of samples
    NU32_ReadUART3(buffer,10);  // Read number of samples from client
    sscanf(buffer,"%d",&N);     // Update global N
}


void setN_manual(int n)         // Manually set number of values to store in data arrays
{
    N = n;                      // Store input into global N
}

int getN(void){ // Return number of samples to be stored
    return N;                   // Return number of samples to be stored
}

void write_reference_position(int position, int index)     // Write reference position to data array
{
    if (index < N)
    {
        DATA.position_reference[index] = position;
    }
}

void write_actual_position(int position, int index)        // Write actual position to data array
{
    if (index < N)
    {
        DATA.position_actual[index] = position;
    }
}

void write_control_current(float current, int index)	// Write control current to data array		
{
	if (index < N)
	{
		DATA.control_current[index] = current;
	}
}

int get_reference_position(int index)           		// Return reference position from given index
{
	return DATA.position_reference[index];
}

void send_position_data(void)   // Send position data to client for plotting
{
    int i; char buffer[50];
    
    sprintf(buffer,"%d\r\n",N); // Store number of samples in buffer
    NU32_WriteUART3(buffer);    // Send number of samples to client
    
    for (i = 0; i < N; i++) {      
        sprintf(buffer, "%d %d %f\r\n",DATA.position_reference[i],DATA.position_actual[i],DATA.control_current[i]*100);   // Store data in buffer
        NU32_WriteUART3(buffer);  // Write data to client
    }
}





    