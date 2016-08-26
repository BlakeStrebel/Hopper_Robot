function linmot_startup(mySerial)


selection = 'g'; % turn on the motor
fprintf(mySerial,'%c\n',selection);

fprintf('Turning on linear motor ...\n');  % Turn on motor
for i = 1:9
    n = fscanf(mySerial, '%d');         % Get motor status 
    %fprintf('%s = %d\n', STATUS{i},n);  % Print motor status
end


selection = 'h'; % home the motor
fprintf(mySerial,'%c\n',selection);

fprintf('Homing linear motor ...\n');            % Home motor
position = fscanf(mySerial,'%d');                    % Get position in um from PIC32
position = position/1000;                               % Convert position to mm
%fprintf('The motor position is %.2f mm.\n',position);   % Print position


end