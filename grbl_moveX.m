function grbl_moveX(mySerial,position)

command = sprintf('g0x%d',position);
fprintf(mySerial,'%s\n',command);
fgets(mySerial);

end