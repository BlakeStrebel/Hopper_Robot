function grbl_home(mySerial)
fprintf('Homing table ...\n');

command = '$H';
fprintf(mySerial,'%s\n',command);
fgets(mySerial);

pause(3);
end