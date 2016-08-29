function cleanup(NU32_Serial,XY_Serial)
% sends NU32 command to unpower linear motor and blower then closes serial
% ports

selection = 'q'; % quit
fprintf(NU32_Serial,'%c\n',selection);

fclose(NU32_Serial);
fclose(XY_Serial);

end