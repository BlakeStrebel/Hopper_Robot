#include <stdio.h>
#include "NU32.h"
#include "positioncontrol.h"
#include "utilities.h"
#include "linmot.h"
#include "encoder.h"


// PID control gains
static volatile float Kp = 1;	// A/mm
static volatile float Ki = 0;	// A/(mm*s)
static volatile float Kd = 3;   // A/(mm/s)  
static volatile float desired_pos = 0, Eint=0, Eold=0;    

void set_position_gains(void)   // recieve position control gains
{
    char buffer[100];
    float Kptemp, Kitemp, Kdtemp;
    NU32_ReadUART3(buffer,100);                              // Store gains in buffer
    sscanf(buffer, "%f %f %f",&Kptemp, &Kitemp, &Kdtemp);   // Extract gains to temporary variables
    __builtin_disable_interrupts();                         // Disable interrupts briefly
    Kp = Kptemp;                                            // Set gains
    Ki = Kitemp;
    Kd = Kdtemp;
    __builtin_enable_interrupts();                          // Reenable interrupts
}

void get_position_gains(void)   // provide position control gains
{
    char buffer[10];
    sprintf(buffer, "%f\r\n",Kp);   // Extract gains to buffer 
    NU32_WriteUART3(buffer);        // Send gains to client
    sprintf(buffer, "%f\r\n",Ki);
    NU32_WriteUART3(buffer);
    sprintf(buffer, "%f\r\n",Kd);
    NU32_WriteUART3(buffer);
}

void get_pos(void)            // Get desired position from client
{
    char buffer [100]; float pos_temp;
    NU32_ReadUART3(buffer,100);			// Read desired angle from client
    sscanf(buffer,"%f",&pos_temp);    	// Extract angle from buffer
    __builtin_disable_interrupts();     // Disable interrupts quickly
    desired_pos = pos_temp;         	// Set desired angle  
    __builtin_enable_interrupts();      // Reenable interrupts
    Eint = 0;                           // Reset PID error
    Eold = 0;
}

void reset_pos(void)
{
	__builtin_disable_interrupts();
	desired_pos = 0;
	__builtin_enable_interrupts();
}

void positioncontrol_setup(void)// setup position control module
{
    // Set up peripheral Timer4 to interrupt at 1000 Hz
    T4CONbits.TCKPS = 3;    // Timer4 prescalar N = 8
    PR4 = 9999;             // Frequency = 1000 Hz
    TMR4 = 0;               // Timer4 initial count 0;
    T4CONbits.ON = 1;       // Turn on Timer4
    IPC4bits.T4IP = 6;      // Priority
    IFS0bits.T4IF = 0;      // Clear interrupt flag
    IEC0bits.T4IE = 1;      // Enable interrupt
	
	setMODE(IDLE);
	TRISBbits.TRISB10 = 0;	// heartbeat pin
}

void load_trajectory(void)      // Load trajectory for tracking
{
    int i, n;
    float data;
    char buffer[50];
    setN_client();      // Recieve number of samples from client
    n = getN();         // Determine number of samples
    
    for (i = 0; i < n; i++)
    {
        NU32_ReadUART3(buffer,50);          // Read reference position from client
        sscanf(buffer,"%f",&data);         	// Store position in data
        write_reference_position(data, i);	// Write data to reference position array
    }
	
	//
}

float PID_controller(float reference, float actual)  // Calculate control effort
{
    static float Enew, Edot, u;
 
    Enew = reference - actual;              // Calculate error
    Eint = Eint + Enew;                     // Calculate intergral error
    Edot = Enew - Eold;                     // Calculate derivative error
    Eold = Enew;                            // Update old error
    
    u = Kp*Enew + Ki*Eint + Kd*Edot;        // Calculate effort
        
	
	
    if (u > 1.5)                           // Set max current (10 A)
    {
        u = 1.5;
    }
    else if (u < -1.5)
    {
        u = -1.5;
    }
        
	setCurrent(u);     // Update DAC to set new current value
	return u;
}


void __ISR(_TIMER_4_VECTOR, IPL6SOFT) PositionController(void)  // 1 kHz position interrupt
{
    static float actual_pos, u;
	static int i = 0;
	char buffer[50];
    
    switch (getMODE())
    {
        case HOLD:  // Hold desired angle
        {
            actual_pos = encoder_position();              // Read position from encoder
			if (actual_pos > 150 || actual_pos < -5)
			{
				motor_off();
			}				
            PID_controller(desired_pos, actual_pos);    // Calculate control
            break;
        }
		case TRACK: // Track reference trajectory
        {
            if (i == getN())    // Done tracking when index equals number of samples
            { 
                setMODE(HOLD);          // Hold final position
                send_position_data();   // Send position data to client
                i = 0;                  // Reset index
            }
            else
            {
                desired_pos = get_reference_position(i);    	// Get desired position
                actual_pos = encoder_position();          		// Read actual position
                write_actual_position(actual_pos, i);        	// Write actual position
                u = PID_controller(desired_pos, actual_pos);	// Calculate effort
				write_current_control(u, i);					// Write control current
                i++;                                          	// Increment index
            }
            break;
        }
		case LOOP:	// Loop reference trajectory
		{
		    desired_pos = get_reference_position(i);    	// Get desired position
			actual_pos = encoder_position();          		// Read actual position
			u = PID_controller(desired_pos, actual_pos);	// Calculate effort
			write_current_control(u, i);					// Write control current
			i++;											// Increment index
            
			if (i == getN())
            { 
                i = 0;                  // Reset index
            }
		}
    } 
    LATBbits.LATB10 = !(LATBbits.LATB10);
    IFS0bits.T4IF = 0;      // Clear interrupt flag
}





