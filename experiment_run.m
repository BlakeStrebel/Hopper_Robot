function experiment_run()

% NU32 board serial port
NU32_port = 'COM5';

% GRBL board serial port
XY_port = 'COM4';

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% configure ports
XY_Serial = serial(XY_port, 'BaudRate', 115200);
NU32_Serial = serial(NU32_port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',60); 

fprintf('Opening port %s....\n',NU32_port);

% opens serial connection
fopen(NU32_Serial);

% closes serial port when function exits
clean = onCleanup(@()fclose(NU32_Serial));

fprintf(NU32_Serial,'%c\n',selection);  % send the command to the PIC32
fprintf(NU32_Serial,'%c\n',selection);  % send the command to the PIC32
fprintf(NU32_Serial,'%c\n',selection);  % send the command to the PIC32
fprintf(NU32_Serial,'%c\n',selection);  % send the command to the PIC32







done = false;

while ~done
   
    
    
    
    
    
end
    
