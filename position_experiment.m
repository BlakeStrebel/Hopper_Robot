function position_experiment()
% Runs experiment with fixed kinematics and records data

numTrials = 10;
trial = 1;

%% Configure serial communications

NU32_port = 'COM5'; % NU32 board serial port
XY_port = 'COM4';   % GRBL board serial port

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% configure ports
XY_Serial = serial(XY_port, 'BaudRate', 115200,'Timeout',30);
NU32_Serial = serial(NU32_port, 'BaudRate', 403200, 'FlowControl', 'hardware','Timeout',30); 

fprintf('Opening ports %s and %s....\n',NU32_port,XY_port);

% opens serial connection
fopen(NU32_Serial);
fopen(XY_Serial);

clean = onCleanup(@() cleanup(NU32_Serial,XY_Serial,fileID)); % close serial ports and turn off motors

%% experiment %%

for trials = 1:numTrials
    %% Configure data file
    
    filename = sprintf('trial%d.txt',trial);
    fileID = fopen(filename,'w');
    fprintf(fileID,'%s\r\n',datetime('today'));
    fprintf(fileID,'foot radius: 1"');
    fprintf(fileID,'blower deceleration time = 20s\r\n');
    
    %% Setup apparatus
    
    % startup the linear motor
    linmot_startup(NU32_Serial);
    
    % startup the xy table
    grbl_startup(XY_Serial);
    pause(3);
    
    % fluidize the bed
    frequency = 56;
    fluidize_bed(NU32_Serial,frequency, 10);
    pause(10);
    
    % determine bed height
    img_name = sprintf('trial%d',trial);
    height = acquire_image(img_name);
    fprintf(fileID,'bed height = %f',height);
    
    % generate linear motor trajectory
    mode = 'linear';                % 'linear','cubic', or 'step' trajectory
    trajectory = [0,0;1,50;2,0];    % [t1,p1;t2,p2;t3,p3]
    fprintf(fileID,'mode = %s\r\n',mode);
    fprintf(fileID,'trajectory: [');fprintf(fileID,'%.3f, %.3f;',trajectory);fprintf(fileID,'%c]\r\n',8);
    
    fprintf('Generating trajectory ...\n');
    fprintf(NU32_Serial,'%c\n','i');            % tell PIC to load position trajectory
    ref = genRef_position(trajectory,mode);     % generate trajectory
    ref = ref * 1000;                           % convert trajectory to um
    fprintf(NU32_Serial,'%d\n',size(ref,2));    % send number of samples to PIC32
    for i = 1:size(ref,2)
        fprintf(NU32_Serial,'%f\n',ref(i));  % send trajectory to PIC32
    end

    %% Perform intrusions and record data
    fprintf(fileID,'ref pos(mm), act pos(mm), current(A), force(counts), table X(mm), table Y(mm)\r\n\r\n');
    intrude = 'l';       % execute trajectory
    
    posy = -1298;   % y coordinate
    posx = -399;    % x coordinate
    distance = 299; % movement distance
    stepsx = 2;     % number of steps in x direction
    stepsy = 5;     % number of steps in y direction
   
    fprintf('Plunging motor ...\n');
    for i = 1:stepsx
        for j = 1:stepsy
            % Perform trial
            fprintf(NU32_Serial,'%c\n',intrude);                    % tell PIC32 to intrude
            data = read_plot_matrix_position(NU32_Serial,0,ref);    % read data back from PIC32
            return_to_origin(NU32_Serial);                          % return motor to origin
            
            % Write data to text file
            fprintf(fileID,'\r\ntrial%d\r\n',i+j);
            for ii = 1:size(data,1)
                fprintf(fileID,'%f %f\r\n',data(ii,3),data(ii,2));
            end
            
            % Move table
            if j ~= stepsy
                if mod(i,2) == 1
                    posy = posy + distance; % move position forward
                else
                    posy = posy - distance; % move position backward
                end
                grbl_moveY(XY_Serial,posy); % move table to target position
                pause(3);                 % wait
            end
        end
        
        if i ~= stepsx
            posx = posx + distance;     % move position forward
            grbl_moveX(XY_Serial,posx); % move table to target position
            pause(4);                % wait
        end
    end
    
    fprintf('Trial complete\n');

end

end