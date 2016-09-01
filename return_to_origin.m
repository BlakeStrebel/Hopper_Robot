function return_to_origin(mySerial)
% Returns linear motor to origin without homing

selection = 'o';
fprintf(mySerial,'%c\n',selection);             
fscanf(mySerial,'%d');           % Clear buffer


end