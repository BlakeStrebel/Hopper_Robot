function client()
%   provides a menu for accessing PIC32 motor control functions

port = 'COM5';
STATUS = {'SWITCH_ON', 'HOME', 'ERROR_ACK', 'SPECIAL_MODE', 'GO_INITAL_POS', 'IN_TARG_POS', 'WARNING', 'ERROR', 'SPECIAL_MOTION'};
MODES = {'IDLE';'HOLD';'TRACK';'LOOP';'HOMING'};
fileID = 'none';

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

fprintf('Opening port %s....\n',port);

% settings for opening the serial port. baud rate 230400, hardware flow control
% wait up to 60 seconds for data before timing out
mySerial = serial(port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',60); 
% opens serial connection
fopen(mySerial);
% closes serial port when function exits
clean = onCleanup(@()fclose(mySerial));                                 

has_quit = false;

% menu loop
while ~has_quit
    %fprintf('PIC32 MOTOR DRIVER INTERFACE\n\n');
    % display the menu options
    %fprintf(['     a: Read encoder (counts)                 b: Read encoder (um)\n' ...
    %         '     c: Set position gains                    d: Get position gains\n' ...
    %         '     e: Acknowledge motor error               f: Motor off\n' ...
    %         '     g: Motor on                              h: Motor home\n' ...
    %         '     i: Load step trajectory                  j: Load cubic trajectory\n' ...
    %         '     k: Execute trajectory                    l: Loop trajectory\n' ...
    %         '     m: Go to position                        n: Set motor current\n' ...
    %         '     q: Quit client                           r: Get mode\n' ...    
    %         '     s: Get state\n' ...
    %         '     x: Start data collection                 y: Stop data collection\n']);
    
    % read the user's choice
    selection = input('\nENTER COMMAND: ', 's');
       
    % send the command to the PIC32
    fprintf(mySerial,'%c\n',selection);
    
    % take the appropriate action
    switch selection
        
        case 'a'
            counts = fscanf(mySerial,'%d');                         % Get position in counts from PIC32
            fprintf('The motor position is %d counts.\n',counts);   % Print position
        case 'b'                        
            position = fscanf(mySerial,'%d');                       % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);   % Print position
        case 'c'
            Kp = input('Enter your desired Kp position gain (A/mm): ');     % Get Kp (A/mm)
            Ki = input('Enter your desired Ki position gain (A/(mm*s): ');  % Get Ki (A/(mm*s))
            Kd = input('Enter your desired Kd position gain (A/(mm/s): ');  % Get Kd (A/(mm/s))
            fprintf(mySerial, '%f %f %f\n',[Kp/1000,Ki/1000,Kd/1000]);      % Convert mm -> um and send gains to PIC32
            fprintf('Sending Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',Kp,Ki,Kd);
        case 'd'
            Kp = fscanf(mySerial, '%f');    % Get Kp (A/um)
            Ki = fscanf(mySerial, '%f');    % Get Ki (A/(um*s))
            Kd = fscanf(mySerial, '%f');    % Get Kd (A/um/s))
            fprintf('The position controller is using Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',[Kp*1000,Ki*1000,Kd*1000]);    % Convert um -> mm and print gains
        case 'e'
            fprintf('Acknowledging error ...\n');
            for i = 1:9
                n = fscanf(mySerial, '%d');         % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);  % Print motor status
            end
        case 'f'
            fprintf('MOTOR OFF\n');             % Turn off motor
            for i = 1:9
                n = fscanf(mySerial, '%d');         % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);  % Print motor status
            end
        case 'g'
            fprintf('Turning on motor ...\n');  % Turn on motor
            for i = 1:9
                n = fscanf(mySerial, '%d');         % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);  % Print motor status
            end
        case 'h'
            fprintf('Homing ...\n');            % Home motor
            position = fscanf(mySerial,'%d');                       % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);   % Print position
        case 'i'
            trajectory = input('Enter step trajectory, in sec and mm [time1, ang1; time2, ang2; ...]:\n');
            
            if trajectory(end,1) > 10   % Check that time is less than 10 seconds
                fprintf('Error: maximum trajectory time is 10 seconds.\n')
            else
                ref = genRef(trajectory,'step');    % Generate step trajectory
                ref = ref*1000;                      % Convert trajectory to um
            end
            
            fprintf(mySerial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            
            for i = 1:size(ref,2)                   % Send trajectory to PIC32
               fprintf(mySerial,'%f\n',ref(i)); 
            end
        case 'j'
            trajectory = input('Enter cubic trajectory, in sec and mm [time1, pos1; time2, pos2; ...]:\n');
            
            if trajectory(end,1) > 10 % Check that time is less than 10 seconds
                fprintf('Error: maximum trajectory time is 10 seconds.\n')
            else
                ref = genRef(trajectory,'cubic');   % Generate cubic trajectory
                ref = ref*1000;                      % Convert trajectory to um
            end
            
            fprintf(mySerial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            for i = 1:size(ref,2)                   % Send trajectory to PIC32
               fprintf(mySerial,'%f\n',ref(i)); 
            end 
        case 'k'
            read_plot_matrix(mySerial,fileID); % Execute trajectory and plot results
        case 'l'
            fprintf('Looping trajectory ...\n') % Loop trajectory
        case 'm'
            pos = input('Enter the desired position in mm: ');  % Get position (mm)
            fprintf(mySerial,'%d\n',pos*1000);                  % Convert mm -> um and send position to PIC32       
            fprintf('Motor moving to %f mm.\n',pos);
            position = fscanf(mySerial,'%d');                       % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);   % Print position
        case 'q'
            has_quit = true;    % exit client
        case 'r'
            
            mode = fscanf(mySerial,'%d');
            fprintf('The PIC32 controller mode is currently %s.\n',MODES{mode+1});
        case 's'
            for i = 1:9
                n = fscanf(mySerial, '%d');
                fprintf('%s = %d\n', STATUS{i},n);
            end
        case 'x'
            file_name = input('Enter file name for data collection (type_trial_velocity_depth.txt): ');       % Get filename
            fileID = fopen(file_name,'w');                                                              % Open file for writing
        case 'y'
            fclose(fileID);
            fileID = 'none';
        otherwise
            fprintf('Invalid Selection %c\n', selection);
    end
end

if ~(strcmp(fileID,'none'))
    fclose(fileID);
end

end
