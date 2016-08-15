#ifndef LINMOT_H
#define LINMOT_H

/*

Linmot linear motor:
	Stator: PS01-23x160H-HP-R
	Slider: PL01-12x420/380-HP (L: 420mm; D: 12mm)
	Stroke Length:
	Force Constant: 12.5 N/A

Motor is driven by Linmot B1100-GP-HC driver.
	Supply Voltage: 60VDC (nominal motor voltage is 72VDC)
	Logic Voltage: 24VDC

Drive is configured in current control mode. Current is set by PIC32 via +/-10V differential input.
PIC32 utalizes PID position feedback control using encoder feeback. External digital to analog converter
converts PIC32 data to voltage. Voltage is then amplified using non-inverting op-amp and fed into motor drive.

Drive uses several I/O pins for control and status monitering. Transistor amps and voltage regulators are used
to shift PIC32 logic levels (3.3-5V) to drive logic levels (24V).

I/O:
PIC32 <-> Drive								Function:
B0 -> Switch on (X14.14)					Switch motor on/off
B1 -> Home (X14.2)							Home motor
B2 -> Error Acknowledge (X14.15)			Acknowlege motor error
B3 -> Special Mode (X14.3)					Put drive in special mode (current control)
B4 -> Go To Initial Position (X14.16)		Go to initial position
E0 <- In Target Position (X14.5)		    Motor is in target position (HOMED)
E1 <- Warning (X14.18)						Warning
E2 <- Error (X14.6)							Error
E3 <- Special Motion Active (X14.19)		Special motion active

*/

void io_init(void);				// Initialize motor driver I/O		
void setCurrent(float voltage);	// Update dac to set motor current
void status(void);				// Print motor status
void motor_on(void);			// Turn on motor
void motor_home(void);			// Home motor
void motor_off(void);			// Turn off motor
void error_ack(void);			// Acknowledge motor error



#endif 