function grbl_startup(mySerial)
% clears serial buffer and homes xy table

fgets(mySerial);   % Clear startup text in serial input
fgets(mySerial);
fgets(mySerial);

end




