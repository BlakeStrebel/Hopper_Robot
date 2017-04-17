function scan_experiment(yi,distance,step_size)

%% Experimental Parameters
intrusion_file = 'data.mat';   % filename for saving data
scan_file = 'scan.mat';
DECIMATION = 2;         % sample rate = control rate / DECIMATION (needs to match value on PIC32)

% Linear motor trajectory
depth = 100;
trajectory = [0,0;.5,depth/2;1,depth;1.5,depth;3,-55];    % [t1,p1;t2,p2;t3,p3]
mode = 'linear';                  % 'linear','cubic', or 'step' trajectory

% XY table behavior
% Dimensions are about 340 x 1275
initial_posy = 600;  % XY table moves to this position after homing
initial_posx = 150;  % Limit switches tend to get hit if these values are zero

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

%% Configure webcam
cam = webcam;
load('C:\Users\Blake\Documents\Experimental_Data\Jumping Robot\Blake_Strebel\Data\Camera_Calibration\cameracalibrationSession.mat');
cameraParameters = calibrationSession.CameraParameters;

%% Configure data structure for data collection

% Store metadata info in metadata struct
experimental_data.metadata.date = datetime();
experimental_data.metadata.foot_radius = 44.45; % mm
experimental_data.metadata.deceleration_time = 10; % s
experimental_data.metadata.control_frequency = 2000; % Hz
experimental_data.metadata.sampling_frequency = 1000; % Hz

%% experiment

% startup the linear motor
linmot_startup(NU32_Serial);

% send to motor starting position
fprintf(NU32_Serial,'%c\n','i');            % tell PIC to load position trajectory
ref = genRef_position([0,0;.5,-55/2;1,-55],'linear');     % generate trajectory
ref = ref * 1000;                           % convert trajectory to um
fprintf(NU32_Serial,'%d\n',size(ref,2));    % send number of samples to PIC32
for i = 1:size(ref,2)
    fprintf(NU32_Serial,'%f\n',ref(i));  % send trajectory to PIC32
end
fprintf(NU32_Serial,'%c\n','l');                                      % tell PIC32 to intrude
read_plot_matrix_position(NU32_Serial,0,ref(1:DECIMATION:end));    % read data back from PIC32

% startup the xy table
grbl_startup(XY_Serial);
grbl_home(XY_Serial);           % return table to home

% fluidize the bed
frequency = 56;
time = 7;
fluidize_bed(NU32_Serial,frequency,time);
pause(8);

%% perform prescan
posx = initial_posx;    % x coordinate
grbl_moveX(XY_Serial,posx);
fprintf('Performing prescan ... \n');
depths.prescan = perform_scan(yi, distance, step_size, XY_Serial, cam, cameraParameters);

% generate linear motor trajectory
fprintf('Loading trajectory ...\n');
fprintf(NU32_Serial,'%c\n','i');            % tell PIC to load position trajectory
ref = genRef_position(trajectory,mode);     % generate trajectory
ref = ref * 1000;                           % convert trajectory to um
fprintf(NU32_Serial,'%d\n',size(ref,2));    % send number of samples to PIC32
for i = 1:size(ref,2)
    fprintf(NU32_Serial,'%f\n',ref(i));  % send trajectory to PIC32
end
    
%% Prepare for intrusion
return_to_origin(NU32_Serial);  % return motor to origin
            
% move table to initial position
posy = initial_posy;   % y coordinate
posx = initial_posx;    % x coordinate
grbl_moveX(XY_Serial,posx);
grbl_moveY(XY_Serial,posy);
pause(8);
    
%% Perform intrusion and record data  
intrude = 'l';       % execute trajectory
intrusion = 1;       % counter
trial = 1;

%% Pause
%input('Position object, <Enter> when ready');

% Perform intrusion
fprintf('Plunging motor ...\n');
fprintf(NU32_Serial,'%c\n',intrude);                                      % tell PIC32 to intrude
data = read_plot_matrix_position(NU32_Serial,0,ref(1:DECIMATION:end));    % read data back from PIC32

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
    
%% Perform postscan
fprintf('Performing postscan ... \n');
depths.postscan = perform_scan(yi, distance, step_size, XY_Serial, cam, cameraParameters);

save(intrusion_file,'experimental_data');
save(scan_file,'depths');

end