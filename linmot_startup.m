function linmot_startup(mySerial)
% Turns on linear motor and performs homing sequence

selection = 'g'; % turn on the motor
fprintf(mySerial,'%c\n',selection);

fprintf('Turning on linear motor ...\n');  % turn on motor

for i = 1:9
    fscanf(mySerial, '%d'); % NU32 sends motor status after startup, clear buffer
end

selection = 'h'; % home the motor
fprintf(mySerial,'%c\n',selection);

fprintf('Homing linear motor ...\n');

fscanf(mySerial,'%d'); % NU32 sends motor position after homing, clear buffer


end