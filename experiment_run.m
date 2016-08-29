function experiment_run(trajectory,mode)
% fluidizes bed and runs specified linear motor trajectory at evenly spaced
% intervals

%%

% NU32 board serial port
NU32_port = 'COM5';

% GRBL board serial port
XY_port = 'COM4';

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% configure ports
XY_Serial = serial(XY_port, 'BaudRate', 115200,'Timeout',30);
NU32_Serial = serial(NU32_port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',30); 

fprintf('Opening ports %s and %s....\n',NU32_port,XY_port);

% opens serial connection
fopen(NU32_Serial);
fopen(XY_Serial);

clean = onCleanup(@() cleanup(NU32_Serial,XY_Serial)); % close serial ports and turn off motors

%%

% fluidize the bed
frequency = 55;
fluidize_bed(NU32_Serial,frequency, 8); 

% startup the linear motor
linmot_startup(NU32_Serial);

% startup the xy table
grbl_startup(XY_Serial);
pause(3);

%%

% generate linear motor trajectory

fprintf('Generating trajectory ...\n');

if strcmp(mode,'position')
    selection = 'j';    % cubic position trajectory
    plunge = 'l';       
elseif strcmp(mode,'current')
    selection = 'u';    % linear current trajectory
    plunge = 'v';
else
    fprintf('invalid mode\n');
end

fprintf(NU32_Serial,'%c\n',selection);

ref = genRef_position(trajectory,'cubic');   % Generate cubic trajectory
ref = ref*1000;                              % Convert trajectory to um             
fprintf(NU32_Serial,'%d\n',size(ref,2));     % Send number of samples to PIC32
for i = 1:size(ref,2)                        % Send trajectory to PIC32
       fprintf(NU32_Serial,'%f\n',ref(i)); 
end

fprintf('Plunging motor ...\n');

posy = -1298;   % y coordinate
posx = -399;    % x coordinate
distance = 99;  % movement distance
for i = 1:5
   for j = 1:13
        % plunge
        fprintf(NU32_Serial,'%c\n',plunge);
        read_plot_matrix_position(NU32_Serial);
        
        % move in the y direction
        if mod(i,2) == 1
            posy = posy + distance;
        else
            posy = posy - distance;
        end
        grbl_moveY(XY_Serial,posy);   
        pause(1.75);
        
        if j == 13
            selection = 'l';
            fprintf(NU32_Serial,'%c\n',selection);
            read_plot_matrix_position(NU32_Serial);
        end
   end
   % move in the x direction
   if i ~= 5
        posx = posx + distance;
        grbl_moveX(XY_Serial,posx);
        pause(2);
   end
end

pause(3);
fprintf('Test complete\n');
end
    
