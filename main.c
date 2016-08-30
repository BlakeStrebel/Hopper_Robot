#include<stdio.h>
#include "NU32.h"       // config bits, constants, funcs for startup and UART
#include "encoder.h"	
#include "utilities.h"
#include "linmot.h"
#include "linmot_dac.h"
#include "blower_dac.h"
#include "blower.h"
#include "positioncontrol.h"


#define BUF_SIZE 200

int main()
{
    char buffer[BUF_SIZE];
    NU32_Startup(); // cache on, min flash wait, interrupts on, LED/button init, UART init
    NU32_LED1 = 1; NU32_LED2 = 1;  // turn off LEDs
   
    __builtin_disable_interrupts();     // Initialize modules
	encoder_init();
	io_init();
	linmot_dac_init();
	blower_dac_init();
	positioncontrol_setup();
	blowercontrol_setup();
    __builtin_enable_interrupts();
    
    while(1)
    {
        NU32_ReadUART3(buffer,BUF_SIZE); // Expect next character to be a menu command
        NU32_LED2 = 1;                   // Clear the error LED
        switch (buffer[0]) {
			case 'a':	// Read encoder (counts)
            {
                encoder_counts(); // dsPIC bug correction
				sprintf(buffer,"%d\r\n",encoder_counts());
				NU32_WriteUART3(buffer); // send encoder count to client
				break;
			}
			case 'b':	// Read encoder (um)
			{
				encoder_position(); // dsPIC bug correction
				sprintf(buffer,"%d\r\n",encoder_position());
				NU32_WriteUART3(buffer);
				break;
			}
			case 'c':   // Set position gains
            {
                set_position_gains();
                break;
            }
            case 'd':   // Get position gains
            {
                get_position_gains();
                break;
            }
			case 'e':	// Acknowledge motor error
			{
				error_ack();
				break;
			}
			case 'f':	// Switch off motor
			{
				motor_off();
				status();
				break;
			}
			case 'g':	// Switch on motor	
			{
				motor_on();
				status(); 	// print status
				break;
			}
			case 'h':	// Home motor
			{
				motor_home();
				break;
			}
			case 'i':   // Load step trajectory
            {
                load_position_trajectory();
                break;
            }
			case 'j':   // Load cubic trajectory
            {
                load_position_trajectory();
                break;
            }
			case 'k':   // Load linear trajectory
            {
                load_position_trajectory();
                break;
            }
			case 'l':   // Execute position trajectory
            {
                setMODE(TRACK);
				while (getMODE() == TRACK){;}	// wait until tracking is complete
				send_position_data();   		// Send position data to client
                break;
            }
			case 'm':	// Loop trajectory
			{
				setMODE(LOOP);
				break;
			}
			case 'n':   // Go to position (um)
            {
                get_pos();    	// Get desired position from client
                setMODE(HOLD);  // Set PIC32 to hold specified position
				_CP0_SET_COUNT(0);
				while (_CP0_GET_COUNT() < 40000000){;}			// Delay
				encoder_position(); 							// Spi bug correction		
				sprintf(buffer,"%d\r\n",encoder_position());	
				NU32_WriteUART3(buffer);						// Write position to client	
                break;
            }
			case 'o':	// go home
			{
				encoder_position(); // dsPIC bug correction
				sprintf(buffer,"%d\r\n",encoder_position());
				NU32_WriteUART3(buffer);	// Send client current position
				load_position_trajectory();	// Load trajectory to return to home
				setMODE(TRACK);				// Track trajectory
				while (getMODE() == TRACK){;}
				sprintf(buffer,"%d\r\n",1);
				NU32_WriteUART3(buffer);	// Send client confirmation echo
				break;
			}
			case 'q':   // Quit
            {
				motor_off();
				blower_off();
                setMODE(IDLE);
                break;
            }
			case 'r':   // Get mode
            {   
                sprintf(buffer,"%d\r\n",getMODE()); // Store mode in buffer
                NU32_WriteUART3(buffer);            // Send mode to client
                break;
            }
			case 's':	// Get state
			{
				status();
				break;
			}
			case 't':	// Set motor current (A)
			{
				float n;
				NU32_ReadUART3(buffer,BUF_SIZE);
				setMODE(CURRENT_SET);
				sscanf(buffer,"%f",&n);
				setCurrent(n);
				break;
			}
			case 'u':	// Load current trajectory
			{
				load_current_trajectory();
				break;
			}
			case 'v':	// Execute current trajectory
			{
				setMODE(CURRENT_TRACK);
				while (getMODE() == CURRENT_TRACK) {;}
				send_current_data();
				break;
			}
			case 'A': // Blower on
			{
				blower_on();
				break;
			}
			case 'B':	// Blower off
			{
				blower_off();
				break;
			}
			case 'C':	// Set blower frequency	
			{
				float frequency;
				NU32_ReadUART3(buffer,BUF_SIZE);
				sscanf(buffer,"%f",&frequency);
				setFrequency(frequency);
				break;
			}
			case 'D':	// Read blower frequency
			{
				sprintf(buffer,"%f\r\n",frequency_read());
				NU32_WriteUART3(buffer); // send frequency to client
				break;
			}
			
        }
    }
	
    return 0;
}

