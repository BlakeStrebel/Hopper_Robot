function grbl_moveY(mySerial,position)
% sends grbl a command to move xy table in y direction

command = sprintf('g0y%d',position);
fprintf(mySerial,'%s\n',command);
fgets(mySerial);

end