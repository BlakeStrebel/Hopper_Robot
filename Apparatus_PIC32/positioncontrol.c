#include <stdio.h>
#include "NU32.h"
#include "positioncontrol.h"
#include "utilities.h"
#include "linmot.h"
#include "encoder.h"
#include "force_sensor.h"

// PID position control gains
static volatile float Kp = .00185;	// A/um
static volatile float Ki = .000015;	// A/(um*s)
static volatile float Kd = .00525;   	// A/(um/s)
static volatile int desired_pos = 0;    

// PID force control gains
static volatile float Fp = 0.0088275;	// A/count
static volatile float Fi = 0.0035310;		// A/(count*s)
static volatile float Fd = 0;	// A/(count/s)
static volatile short desired_force = 0;

static volatile control_error P; // position control error
static volatile control_error F; // force control error

void positioncontrol_setup(void)// setup position control module
{
    // Set up peripheral Timer4 to interrupt at 2000 Hz
    T4CONbits.TCKPS = 3;    // Timer4 prescalar N = 8
    PR4 = 4999;             // Frequency = 2000 Hz (T = (PR4+1)*N*12.5ns)
    TMR4 = 0;               // Timer4 initial count 0;
    T4CONbits.ON = 1;       // Turn on Timer4
    IPC4bits.T4IP = 6;      // Priority
    IFS0bits.T4IF = 0;      // Clear interrupt flag
    IEC0bits.T4IE = 1;      // Enable interrupt
	
	setMODE(IDLE);
}

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
	reset_controller_error();
    __builtin_enable_interrupts();                          // Reenable interrupts
}

void get_position_gains(void)   // provide position control gains
{
    char buffer[100];
    sprintf(buffer, "%f\r\n",Kp);   // Extract gains to buffer 
    NU32_WriteUART3(buffer);        // Send gains to client
    sprintf(buffer, "%f\r\n",Ki);
    NU32_WriteUART3(buffer);
    sprintf(buffer, "%f\r\n",Kd);
    NU32_WriteUART3(buffer);
}

void set_force_gains(void)
{
	char buffer[100];
    float Fptemp, Fitemp, Fdtemp;
    NU32_ReadUART3(buffer,100);                              // Store gains in buffer
    sscanf(buffer, "%f %f %f",&Fptemp, &Fitemp, &Fdtemp);   // Extract gains to temporary variables
    __builtin_disable_interrupts();                         // Disable interrupts briefly
    Fp = Fptemp;                                            // Set gains
    Fi = Fitemp;
    Fd = Fdtemp;
	reset_controller_error();
    __builtin_enable_interrupts();                          // Reenable interrupts
}

void get_force_gains(void)
{
	char buffer[100];
    sprintf(buffer, "%f\r\n",Fp);   // Extract gains to buffer 
    NU32_WriteUART3(buffer);        // Send gains to client
    sprintf(buffer, "%f\r\n",Fi);
    NU32_WriteUART3(buffer);
    sprintf(buffer, "%f\r\n",Fd);
    NU32_WriteUART3(buffer);
}

void get_pos(void)            // Get desired position from client
{
    char buffer [100]; int pos_temp;
    NU32_ReadUART3(buffer,100);			// Read desired angle from client
    sscanf(buffer,"%d",&pos_temp);    	// Extract angle from buffer
    __builtin_disable_interrupts();     // Disable interrupts quickly
    desired_pos = pos_temp;         	// Set desired position  
    __builtin_enable_interrupts();      // Reenable interrupts
}

void reset_pos(void)
{
	__builtin_disable_interrupts();
	desired_pos = 0;
	__builtin_enable_interrupts();
}

void load_position_trajectory(void)      // Load trajectory for tracking
{
    int i, n, data;
    char buffer[100];
    setN_client();      // Recieve number of samples from client
    n = getN();         // Determine number of samples
    
    for (i = 0; i < n; i++)
    {
        NU32_ReadUART3(buffer,100);         // Read reference position from client
        sscanf(buffer,"%d",&data);         	// Store position in data
        write_reference_position(data, i);	// Write data to reference position array
    }
}

void load_force_trajectory(void)      // Load trajectory for tracking
{
    int i, n;
	short data;
    char buffer[100];
    setN_client();      // Recieve number of samples from client
    n = getN();         // Determine number of samples
   	
    for (i = 0; i < n; i++)
    {
        NU32_ReadUART3(buffer,100);         // Read reference position from client
        sscanf(buffer,"%d",&data);         	// Store force in data
        write_reference_Fz(data, i);		// Write data to reference position array
	}
}

void reset_controller_error(void)
{
	P.Enew = 0;
	P.Eold = 0;
	P.Eint = 0;
	P.Edot = 0;
	F.Enew = 0;
	F.Eold = 0;
	F.Eint = 0;
	F.Edot = 0;
}

float position_controller(int reference, int actual)  // Calculate control effort using PID position feedback
{
	static float u;
	
    P.Enew = reference - actual;              // Calculate error
    P.Eint = P.Eint + P.Enew;                     // Calculate intergral error
    P.Edot = P.Enew - P.Eold;                     // Calculate derivative error
    P.Eold = P.Enew;                            // Update old error
    
    u = Kp*P.Enew + Ki*P.Eint + Kd*P.Edot;        // Calculate effort
        
    if (u > 10)                           // Set max/min current
    {
        u = 10;
    }
    else if (u < -1)
    {
        u = -1;
    }
        
	setCurrent(u);     // Update DAC to set new current value
	return u;
}

float force_controller(short reference, short actual) // Calculate control effort using feedforward model based on motor constant and PID force feedback
{
	static float u; 
	static float Km = 0.022656; 	 // Motor constant in A/count
	
	F.Enew = reference - actual;	// Calculate error
	F.Eint = F.Eint + F.Enew;			// Calculate integral error
	F.Edot = F.Enew - F.Eold;			// Calculate derivative error
	F.Eold = F.Enew;				// Update old error
	
	u = Km*reference + Fp*F.Enew + Fi*F.Eint + Fd*F.Edot;	// Calculate effort
	
	
	if (u > 6)			// Set max/min current
	{
		u = 6;
	}
	else if (u < -2)
	{
		u = -2;
	}
	
	setCurrent(u);	// Update DAC to set new current value
	return (u);
}

void __ISR(_TIMER_4_VECTOR, IPL6SRS) Controller(void)  // 2 kHz position interrupt
{
    static int actual_pos, i = 0;
	static float u;
	static short Fz, Tx, Ty;
	static int decctr = 0;	// counts to store data one every DECIMATION

    switch (getMODE())
    {
        case POSITION_HOLD:  // Hold desired position
        {
            actual_pos = encoder_position();              	// Read position from encoder
            position_controller(desired_pos, actual_pos);    	// Calculate control
            break;
        }
		case POSITION_TRACK: // Track position trajectory
        {
            if (i == getN())    // Done tracking when index equals number of samples
            { 
				i = 0;                  // Reset index
				//setCurrent(0);			// Reset current
                setMODE(POSITION_HOLD);			// Idle motor	
            }
            else
            {
                desired_pos = get_reference_position(i);    	// Get desired position
                actual_pos = encoder_position();          		// Read actual position
                u = position_controller(desired_pos, actual_pos);	// Calculate effort
				
				decctr++;
				if (decctr == DECIMATION) {
					Fz = force_read(GET_FZ);				// Read actual force
					Tx = force_read(GET_TX);
					Ty = force_read(GET_TY);
					buffer_write(actual_pos,u, Fz, Tx, Ty);		// Write data to buffer	
					decctr = 0;	// reset DECIMATION counter
				}
				
                i++;                                          	// Increment index
            }
            break;
        }
		case FORCE_TRACK:
		{
			if (i == getN())	// Done tracking when index equals number of samples	
			{
				i = 0;			// Reset index
				setCurrent(0);	// Reset current
				setMODE(IDLE);	// Idle motor
			}
			else
			{
				desired_force = get_reference_Fz(i);		// Get desired force
				Fz = force_read(GET_FZ);					// Read actual force
				u = force_controller(desired_force, Fz);	// Calculate effort
				
				decctr++;
				if (decctr == DECIMATION) {
					actual_pos = encoder_position();			// Read actual position	
					Tx = force_read(GET_TX);
					Ty = force_read(GET_TY);
					buffer_write(actual_pos, u, Fz, Tx, Ty);	// Write data to buffer
					decctr = 0;
				}	
			
			i++;										// Increment index				
			}
			break;
		}
    } 
 
    IFS0bits.T4IF = 0;      // Clear interrupt flag
}





