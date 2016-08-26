function grbl_moveY(mySerial,position)

command = sprintf('g0y%d',position);
fprintf(mySerial,'%s\n',command);
fgets(mySerial);

end