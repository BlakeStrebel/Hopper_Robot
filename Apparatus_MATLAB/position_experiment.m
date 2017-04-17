function position_experiment()
% Runs position control experiment and records data

%% Experimental Parameters

filename = 'data.mat';   % filename for saving data
numTrials = 3;         % number of times each intrusion is performed
DECIMATION = 2;         % sample rate = control rate / DECIMATION (needs to match value on PIC32)

% Linear motor trajectory

trajectory = [0,0;.5,50/2;1,50];    % [t1,p1;t2,p2;t3,p3]
mode = 'linear';                  % 'linear','cubic', or 'step' trajectory

% XY table behavior
% Dimensions are about 340 x 1275
step_sizex = 0;%76;                   % step distance between intrusions
step_sizey = 64;
initial_posy = 200;                 % XY table moves to this position after homing
initial_posx = 160-round(step_sizex/2);    % Limit switches tend to get hit if these values are zero
stepsx = 1;                         % number of intrusions in each direction
stepsy = 10;%floor(1000/step_sizey);%3;

%% Prevent user from overwriting data
if (exist(filename,'file'))
   warning = sprintf('The file %s already exists, continuing will overwrite previous data.\n<Enter> to continue; <CTRL-c> to quit',filename);
    input(warning);  
end

%% Configure serial communications

NU32_port = 'COM5'; % NU32 board serial port
XY_port = 'COM4';   % GRBL board serial port

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% configure ports
XY_Serial = serial(XY_port, 'BaudRate', 115200,'Timeout',20);
NU32_Serial = serial(NU32_port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',30); 

fprintf('Opening ports %s and %s....\n',NU32_port,XY_port);

% opens serial connection
fopen(NU32_Serial);
fopen(XY_Serial);

clean1 = onCleanup(@() cleanup(NU32_Serial,XY_Serial)); % close serial ports and turn off motors

%% Configure data structure for data collection

% Store metadata info in metadata struct
experimental_data.metadata.date = datetime();
experimental_data.metadata.foot_diameter = 50.8; % mm
experimental_data.metadata.deceleration_time = 10; % s
experimental_data.metadata.control_frequency = 2000; % Hz
experimental_data.metadata.sampling_frequency = 1000; % Hz
experimental_data.metadata.step_sizex = step_sizex; % mm 
experimental_data.metadata.step_sizey = step_sizey; % mm
experimental_data.metadata.stepsx = stepsx; % mm 
experimental_data.metadata.stepsy = stepsy; % mm
experimental_data.metadata.initial_posx = initial_posx; % mm 
experimental_data.metadata.initial_posy = initial_posy; % mm

%% Setup apparatus for experiment

% startup the linear motor
linmot_startup(NU32_Serial);

% startup the xy table
grbl_startup(XY_Serial);

% generate linear motor trajectory
fprintf('Loading trajectory ...\n');

fprintf(NU32_Serial,'%c\n','i');            % tell PIC to load position trajectory
ref = genRef_position(trajectory,mode);     % generate trajectory
% ref = genRef_position_special(1500,30,125);
ref = ref * 1000;                           % convert trajectory to um
fprintf(NU32_Serial,'%d\n',size(ref,2));    % send number of samples to PIC32
for i = 1:size(ref,2)
    fprintf(NU32_Serial,'%f\n',ref(i));  % send trajectory to PIC32
end

%% experiment %%

for trial = 1:numTrials
    
    save(filename,'experimental_data'); % save file after every trial
    
    %% Setup apparatus for trial
    return_to_origin(NU32_Serial);  % return motor to origin
    grbl_home(XY_Serial);           % return table to home
    
    % fluidize the bed
    frequency = 56;
   
    time = 7;
    fluidize_bed(NU32_Serial,frequency,time);
    pause(8);
    
    % move table to initial position
    posy = initial_posy;   % y coordinate
    posx = initial_posx;    % x coordinate
    grbl_moveX(XY_Serial,posx);
    grbl_moveY(XY_Serial,posy);
    
%     % determine bed height
%     fprintf('Determining bed height\n');
%     img_name = sprintf('trial%d.bmp',trial);
%     bedheight = acquire_image(img_name);
%     experimental_data.trials(trial).bedheight = bedheight;
    pause(12);
    
    %% Perform intrusions and record data
    
    intrude = 'l';       % execute trajectory
    intrusion = 1;       % counter
    
    fprintf('Plunging motor ...\n');
    for i = 1:stepsy 
        for j = 1:stepsx 
            
            % Perform intrusion
            fprintf(NU32_Serial,'%c\n',intrude);                                      % tell PIC32 to intrude
            data = read_plot_matrix_position(NU32_Serial,0,ref(1:DECIMATION:end));    % read data back from PIC32
            return_to_origin(NU32_Serial);                                            % return motor to origin
            
            % Store data
            experimental_data.trials(trial).intrusion(intrusion).sample_number = 1:size(data,1);
            experimental_data.trials(trial).intrusion(intrusion).reference_position = data(:,1);
            experimental_data.trials(trial).intrusion(intrusion).actual_position = data(:,2);
            experimental_data.trials(trial).intrusion(intrusion).motor_current = data(:,3);
            experimental_data.trials(trial).intrusion(intrusion).Fz = data(:,4);
            experimental_data.trials(trial).intrusion(intrusion).Tx = data(:,5);
            experimental_data.trials(trial).intrusion(intrusion).Ty = data(:,6);
            experimental_data.trials(trial).intrusion(intrusion).x_pos = posx;
            experimental_data.trials(trial).intrusion(intrusion).y_pos = posy;
            
            intrusion = intrusion + 1; % increment intrusion number
            
            % Move table
            if j < stepsx
                posx = posx + step_sizex;
            else
                posx = posx - step_sizex;
            end
            grbl_moveX(XY_Serial,posx); % move table to target position
            pause(2);                   % wait
        end
        
        if i ~= stepsy
            posy = posy + step_sizey;    % move position forward
            grbl_moveY(XY_Serial,posy); % move table to target position
            pause(2);                   % wait
        end
    end
    
    fprintf('Trial %d complete\n',trial);

end

save(filename,'experimental_data');

end