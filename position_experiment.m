function position_experiment()

%%
trajectory = [0,0;1,50;2,0];
mode = 'linear';
filename = sprintf('p_%s_%.3f_%.3f.txt',mode,max(trajectory(:,1)),max(trajectory(:,2)));

fileID = fopen(filename,'w');
fprintf(fileID,'%s\r\n',datetime('today'));
fprintf(fileID,'mode = %s\r\n',mode);
fprintf(fileID,'trajectory: [');fprintf(fileID,'%.3f, %.3f;',trajectory);fprintf(fileID,'%c]\r\n',8);
fprintf(fileID,'foot radius: 1"');
fprintf(fileID,'blower deceleration time = 20s\r\n');
fprintf(fileID,'Control loop: 2000Hz\r\n');
fprintf(fileID,'\r\ncurrent(A)  position(mm)\r\n\r\n');

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

clean = onCleanup(@() cleanup(NU32_Serial,XY_Serial,fileID)); % close serial ports and turn off motors

%%

% fluidize the bed
frequency = 56;
fluidize_bed(NU32_Serial,frequency, 10);
pause(8);

% startup the linear motor
linmot_startup(NU32_Serial);

% startup the xy table
grbl_startup(XY_Serial);
pause(3);

%%

% generate linear motor trajectory

fprintf('Generating trajectory ...\n');

selection = 'k';    % load trajectory
plunge = 'l';       % execute trajectory

fprintf(NU32_Serial,'%c\n',selection);

ref = genRef_position(trajectory,mode);       % Generate trajectory
ref = ref * 1000;                             % Convert trajectory to um
fprintf(NU32_Serial,'%d\n',size(ref,2));     % Send number of samples to PIC32
for i = 1:size(ref,2)                        
       fprintf(NU32_Serial,'%f\n',ref(i));   % Send trajectory to PIC32
       times(i) = (i-1)*0.5;   % 0.5 ms between samples
end

fprintf('Plunging motor ...\n');
          
% figure;            
% hold on;
% title('Depth vs. Time');
% ylabel('Position (mm)')
% xlabel('Time (ms)')

posy = -1298;   % y coordinate
posx = -399;    % x coordinate
distance = 299; % movement distance
stepsx = 2;     % number of steps in x direction
stepsy = 5;     % number of steps in y direction

for i = 1:stepsx
   for j = 1:stepsy
        fprintf(NU32_Serial,'%c\n',plunge);              % tell PIC32 to plunge
        data = read_plot_matrix_position(NU32_Serial,1); % read data back from PIC32
        %plot(times,data(:,2));                           % plot data
        
        fprintf(fileID,'\r\ntrial%d\r\n',i+j); 
        for ii = 1:size(data,1)         
            fprintf(fileID,'%f %f\r\n',data(ii,3),data(ii,2));  % write data to text file
        end
        
        return_to_origin(NU32_Serial);  % return motor to origin
        
        if j ~= stepsy
            if mod(i,2) == 1
                posy = posy + distance; % move position forward
            else
                posy = posy - distance; % move position backward
            end
            grbl_moveY(XY_Serial,posy); % move table to target position  
            pause(2.5);                 % wait 
        end
        
   end
   
   if i ~= stepsx
        posx = posx + distance;     % move position forward
        grbl_moveX(XY_Serial,posx); % move table to target position
        pause(3.25);                % wait
   end
end

fprintf('Test complete\n');
hold off;
pause(3);

end