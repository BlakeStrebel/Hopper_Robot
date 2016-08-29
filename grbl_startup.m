function grbl_startup(mySerial)
% clears serial buffer and homes xy table

fprintf('Homing table ...\n');

fgets(mySerial);   % Clear startup text in serial input
fgets(mySerial);
fgets(mySerial);

command = '$H';
fprintf(mySerial,'%s\n',command);
fgets(mySerial);


