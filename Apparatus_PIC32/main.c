#include<stdio.h>
#include "NU32.h"       // config bits, constants, funcs for startup and UART
#include "encoder.h"	
#include "utilities.h"
#include "linmot.h"
#include "linmot_dac.h"
#include "blower_dac.h"
#include "blower.h"
#include "positioncontrol.h"
#include "force_sensor.h"


#define BUF_SIZE 200

int main()
{
    char buffer[BUF_SIZE];
    NU32_Startup(); // cache on, min flash wait, interrupts on, LED/button init, UART init
    NU32_LED1 = 1; NU32_LED2 = 1;  // turn off LEDs
	
	__builtin_disable_interrupts();
	encoder_init();				// Setup SPI3 for encoder communication 
	io_init();					// Setup linear motor I/O pins
	linmot_dac_init();			// Setup CS pin for SPI3 communication
	blower_dac_init();			// Setup CS pin for SPI4 communication
	positioncontrol_setup();	// Setup control loop interrupt
	force_sensor_init();		// Setup SPI4 for ADC communication	
	blowercontrol_setup();		// Setup blower on/off pin
	reset_controller_error();	// Set controller error to zero
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
			case 'i':   // Load trajectory
            {
                load_position_trajectory();
                break;
            }
			case 'l':   // Execute position trajectory
            {
				reset_controller_error();	// Set controller error to zero
                setMODE(POSITION_TRACK);	// Begin tracking
				send_data();				// Send data to client as it becomes available
                break;
            }
			case 'n':   // Go to position (um)
            {
                get_pos();    	// Get desired position from client
                setMODE(POSITION_HOLD);  // Set PIC32 to hold specified position
				_CP0_SET_COUNT(0);
				while (_CP0_GET_COUNT() < 40000000){;}			// Delay
				encoder_position(); 							// Spi bug correction		
				sprintf(buffer,"%d\r\n",encoder_position());	
				NU32_WriteUART3(buffer);						// Write position to client	
                break;
            }
			case 'o':	// go home
			{
				go_home();
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
			case 't':	// Set force gains
			{
				set_force_gains();
				break;
			}
			case 'u':	// Get force gains
			{
				get_force_gains();
				break;
			}
			case 'v':	// Load force trajectory
			{
				load_force_trajectory();
				break;
			}
			case 'w':	// Execute force trajectory
			{
				reset_controller_error();	// Set controller error to zero
				setMODE(FORCE_TRACK);	// Begin tracking
				send_data();			// Send data to client as it becomes available
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
			case 'F':
			{
				sprintf(buffer,"%hi %hi %hi\r\n", force_read(GET_FZ), force_read(GET_TX), force_read(GET_TY));
				NU32_WriteUART3(buffer);
				break;
			}
        }
    }
	
    return 0;
}

