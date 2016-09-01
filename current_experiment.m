function current_experiment()

%%
fileID = fopen('c_.5_.5.txt','w');
fprintf(fileID,'8/31/2016\r\n');
fprintf(fileID,'mode = square step current\r\n');
fprintf(fileID,'linear trajectory: [0,.25;.25,0;.5,.5;1.5,.5]\r\n');
fprintf(fileID,'blower deceleration time = 20s\r\n');
fprintf(fileID,'Control loop: 2000Hz\r\n');

fprintf(fileID,'\r\ncurrent(A)  position(mm)\r\n\r\n');

trajectory = [0,0;.5,.5;1,1];
mode = 'linear';

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
fluidize_bed(NU32_Serial,frequency, 15);
pause(10);

% startup the linear motor
linmot_startup(NU32_Serial);

% startup the xy table
grbl_startup(XY_Serial);
pause(3);

%%

% generate linear motor trajectory

fprintf('Generating trajectory ...\n');

selection = 'u';
plunge = 'v';       

fprintf(NU32_Serial,'%c\n',selection);

ref = genRef_current(trajectory,mode);   % Generate trajectory            
fprintf(NU32_Serial,'%d\n',size(ref,2));     % Send number of samples to PIC32
for i = 1:size(ref,2)                        % Send trajectory to PIC32
       fprintf(NU32_Serial,'%f\n',ref(i)); 
end


for i=1:size(ref,2)
    times(i) = (i-1)*0.5;                  % 0.5 ms between samples
end

fprintf('Plunging motor ...\n');

posy = -1298;   % y coordinate
posx = -399;    % x coordinate
distance = 199;  % movement distance

for i = 1:3
   for j = 1:7
        % plunge
        fprintf(NU32_Serial,'%c\n',plunge);
        data = read_plot_matrix_current(NU32_Serial,0);
        if j == 1 && i == 1
            figure;
            hold on;
            title('Depth vs. Time');
            ylabel('Position (mm)')
            xlabel('Time (ms)')
        end
        plot(times,data(:,2));
        
        fprintf(fileID,'\r\n');
        for ii = 1:size(data,1)
            fprintf(fileID,'%f %f\r\n',data(ii,1),data(ii,2));
        end
        return_to_origin(NU32_Serial);
        
        % move in the y direction
        if j ~=7
            if mod(i,2) == 1
                posy = posy + distance;
            else
                posy = posy - distance;
            end
            grbl_moveY(XY_Serial,posy);   
            pause(2.5);
        end
   end
   % move in the x direction
   if i ~= 3
        posx = posx + distance;
        grbl_moveX(XY_Serial,posx);
        pause(3.25);
   end
end

hold off;

pause(3);
fprintf('Test complete\n');
end