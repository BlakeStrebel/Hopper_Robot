function fluidize_bed(mySerial,frequency, time)
% turns on blower to specified frequency for specified length of time
% acceleration/deceleration rates are configured on drive

fprintf('fluidizing bed ...\n');

% set frequency
selection = 'C'; 
fprintf(mySerial,'%c\n',selection);
fprintf(mySerial,'%f\n',frequency);
fprintf('Setting blower frequency to %f Hz\n',frequency);

% turn on blower
selection = 'A';    
fprintf(mySerial,'%c\n',selection);

% wait for bed to fluidize
pause(time);

% turn off blower
selection = 'B';
fprintf(mySerial,'%c\n',selection);

end