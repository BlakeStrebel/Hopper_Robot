function grbl_moveX(mySerial,position)
% sends grbl a command to move xy table in x direction

command = sprintf('g0x%d',position);
fprintf(mySerial,'%s\n',command);
fgets(mySerial);

end