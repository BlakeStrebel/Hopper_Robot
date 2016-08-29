function return_to_origin(mySerial)
% Returns linear motor to origin without homing

selection = 'b';
fprintf(mySerial,'%c\n',selection); % +
position = fscanf(mySerial,'%d');   % Get position in um from PIC32
position = position/1000;           % Convert position to mm
            

