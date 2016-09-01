#include <stdio.h>
#include "NU32.h"
#include "utilities.h"
#include "linmot.h" 
 
#define DECIMATION 4	// Store every 10th value

 
static volatile mode MODE;            	// Operating mode
static volatile control_data_t DATA;    // Struct containing data arrays
static volatile int N;                  // Number of position samples to store
static volatile int M;                  // Number of current samples to store

void setMODE(mode newMODE) {  // Set mode
    MODE = newMODE;     // Update global MODE
}

mode getMODE() {  // Return mode
    return MODE;
}

void setN_client(void)          // Recieve number of values to store in position data arrays from client
{                   
    char buffer[10];            // Buffer holding number of samples
    NU32_ReadUART3(buffer,10);  // Read number of samples from client
    sscanf(buffer,"%d",&N);     // Update global N
}


void setN_manual(int n)         // Manually set number of values to store in data arrays
{
    N = n;                      // Store input into global N
}

int getN(void){
    return N;                   // Return number of samples to be stored
}

void setM_client(void)          // Recieve number of values to store in data arrays from client
{                   
    char buffer[10];            // Buffer holding number of samples
    NU32_ReadUART3(buffer,10);  // Read number of samples from client
    sscanf(buffer,"%d",&M);     // Update global M
}


void setM_manual(int m)         // Manually set number of values to store in data arrays
{
    M = m;                      // Store input into global M
}

int getM(void){
    return M;                   // Return number of samples to be stored
}

void write_reference_position(int position, int index)     // Write reference position to data array
{
    DATA.position_reference[index] = position;
}

void write_actual_position(int position, int index)        // Write actual position to data array
{
	static int decctr = 0;
	
	decctr++;
	if (decctr == DECIMATION)
	{
		DATA.position_actual[index/DECIMATION] = position;
		decctr = 0;
	}
	 
}

int get_reference_position(int index)           		// Return reference position to given index
{
	return DATA.position_reference[index];
}

void send_position_data(void)   // Send position data to client for plotting
{
    int i; char buffer[50];
    
    sprintf(buffer,"%d\r\n",N/DECIMATION); // Store number of samples in buffer
    NU32_WriteUART3(buffer);    // Send number of samples to client
    
    for (i = 0; i < N/DECIMATION; i++) {      
        sprintf(buffer, "%d %d %f\r\n",DATA.position_reference[i*DECIMATION],DATA.position_actual[i],DATA.current_actual[i]);   // Store data in buffer
        NU32_WriteUART3(buffer);  // Write data to client
    }
}

void  write_reference_current(float current, int index)	// Write reference current
{
	DATA.current_reference[index] = current;
}

float get_reference_current(int index)							// Return reference current from given index
{
	return DATA.current_reference[index];
}

void write_actual_current(float current, int index)		// Write actual current
{
	static int decctr = 0;
	static float avg_current = 0;
	
	decctr++;
	avg_current += current;
	if (decctr == DECIMATION)
	{
		avg_current /= (float)DECIMATION;
		DATA.current_actual[index/DECIMATION] = avg_current;
		decctr = 0;
		avg_current = 0;
	}
		
}	


void send_current_data(void)									// Send current buffers to client
{
	int i; char buffer[50];
    
    sprintf(buffer,"%d\r\n",M/DECIMATION); // Store number of samples in buffer
    NU32_WriteUART3(buffer);    // Send number of samples to client
    
    for (i = 0; i < M/DECIMATION; i++) {      
        sprintf(buffer, "%f %d\r\n",DATA.current_reference[i*DECIMATION]*100,DATA.position_actual[i]);   // Store data in buffer
        NU32_WriteUART3(buffer);  // Write data to client
    };
}



    