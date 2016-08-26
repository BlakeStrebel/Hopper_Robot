function fluidize_bed(mySerial,frequency)

fprintf('fluidizing bed ...\n');

% Set frequency
selection = 'C'; 
fprintf(mySerial,'%c\n',selection);

fprintf(mySerial,'%f\n',frequency);
fprintf('Setting blower frequency to %f Hz\n',frequency);

% Turn on blower
selection = 'A';    
fprintf(mySerial,'%c\n',selection);

% Wait for bed to fluidize
pause(8);

% Turn off blower
selection = 'B';
fprintf(mySerial,'%c\n',selection);

end