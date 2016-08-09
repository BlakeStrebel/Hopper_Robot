#include<stdio.h>
#include "NU32.h"       // config bits, constants, funcs for startup and UART
#include "encoder.h"	
#include "utilities.h"
#include "linmot.h"
#include "dac.h"
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
	dac_init();
	positioncontrol_setup();
    __builtin_enable_interrupts();
    
    while(1)
    {
        NU32_ReadUART3(buffer,BUF_SIZE); // Expect next character to be a menu command
        NU32_LED2 = 1;                   // Clear the error LED
        switch (buffer[0]) {
			case 'a':	// Read encoder (counts)
            {
                int i = encoder_counts(); // SPI bug correction
				sprintf(buffer,"%d\r\n",encoder_counts());
				NU32_WriteUART3(buffer); // send encoder count to client
				break;
			}
			case 'b':	// Read encoder (mm)
			{
				encoder_position(); // spi bug correction
				sprintf(buffer,"%.2f\r\n",encoder_position());
				NU32_WriteUART3(buffer);
				break;
			}
			case 'c':	// Reset encoder
			{
				encoder_reset();    // reset encoder count to 32,768
                break;
			}
			case 'i':   // Set position gains
            {
                set_position_gains();
                break;
            }
            case 'j':   // Get position gains
            {
                get_position_gains();
                break;
            }
			case 'k':	// Motor startup
			{
				motor_startup();
				break;
			}
			case 'l':   // Go to position (mm)
            {
                get_pos();    	// Get desired position from client
                setMODE(HOLD);  // Set PIC32 to hold specified position
                break;
            }
			case 'm':   // Load step trajectory
            {
                load_trajectory();
                break;
            }
			case 'n':   // Load cubic trajectory
            {
                load_trajectory();
                break;
            }
			case 'o':   // Execute trajectory
            {
                setMODE(TRACK);
                break;
            }
			case 'p':	// Loop trajectory
			{
				setMODE(LOOP);
				break;
			}
			case 'q':   // Quit
            {
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
				state();
				break;
			}
			case 'x':	// Turn off motor
			{
				motor_off();
			}
			case 'y':	// Test dac
			{
				float n;
				NU32_ReadUART3(buffer,BUF_SIZE);
				sscanf(buffer,"%f",&n);
				setVoltage(n);
				break;
			}
        }
    }
	
    return 0;
}

