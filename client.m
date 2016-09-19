function client()
%   provides a menu for interfacing with hopper robot system

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

% closes serial port when function exits
clean1 = onCleanup(@()fclose(NU32_Serial));
clean2 = onCleanup(@()fclose(XY_Serial));

% globals
STATUS = {'SWITCH_ON', 'HOME', 'ERROR_ACK', 'SPECIAL_MODE', 'GO_INITAL_POS', 'IN_TARG_POS', 'WARNING', 'ERROR', 'SPECIAL_MOTION'}; 
MODES = {'IDLE';'HOLD';'TRACK';'LOOP';'HOMING'};

has_quit = false;

% menu loop
while ~has_quit
    %fprintf('PIC32 MOTOR DRIVER INTERFACE\n\n');
    % display the menu options
    %fprintf(['     a: Read encoder (counts)                 b: Read encoder (um)\n' ...
    %         '     c: Set position gains                    d: Get position gains\n' ...
    %         '     e: Acknowledge motor error               f: Motor off\n' ...
    %         '     g: Motor on                              h: Motor home\n' ...
    %         '     i: Load step position trajectory         j: Load cubic position trajectory\n' ...
    %         '     k: Load linear position trajectory       l: Execute position trajectory\n' ...                   
    %         '                   n: Go to position \n' ...
    %         '     o: Go home\n' ...
    %         '     q: Quit client                           r: Get mode\n' ...    
    %         '     s: Get state\n' ...
    %         '     t: Set motor current\n' ...              u: Load current trajectory\n' ...
    %         '     v: Execute current trajectory\n' ...
    %         '     A: Blower on                             B: Blower off\n' ...
    %         '     C: Set frequency                         D: Read frequency\n' ...
    %         '     1: GRBL\n' ...
    %         '     : ]);
    
    % read the user's choice
    selection = input('\nENTER COMMAND: ', 's');
    
    % check where to send the selection
    if strcmp(selection,'1')
      % don't send command to PIC32  
    else
        fprintf(NU32_Serial,'%c\n',selection);  % send the command to the PIC32
    end
    
    % take the appropriate action
    switch selection
        
        case 'a'
            counts = fscanf(NU32_Serial,'%d');                      % Get position in counts from PIC32
            fprintf('The motor position is %d counts.\n',counts);
        case 'b'                        
            position = fscanf(NU32_Serial,'%d');                    % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);
        case 'c'
            Kp = input('Enter your desired Kp position gain (A/mm): ');     % Get Kp (A/mm)
            Ki = input('Enter your desired Ki position gain (A/(mm*s): ');  % Get Ki (A/(mm*s))
            Kd = input('Enter your desired Kd position gain (A/(mm/s): ');  % Get Kd (A/(mm/s))
            fprintf(NU32_Serial, '%f %f %f\n',[Kp/1000,Ki/1000,Kd/1000]);   % Convert mm -> um and send gains to PIC32
            fprintf('Sending Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',Kp,Ki,Kd);
        case 'd'
            Kp = fscanf(NU32_Serial, '%f');    % Get Kp (A/um)
            Ki = fscanf(NU32_Serial, '%f');    % Get Ki (A/(um*s))
            Kd = fscanf(NU32_Serial, '%f');    % Get Kd (A/um/s))
            fprintf('The position controller is using Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',[Kp*1000,Ki*1000,Kd*1000]);    % Convert um -> mm and print gains
        case 'e'
            fprintf('Acknowledging error ...\n');
            for i = 1:9
                n = fscanf(NU32_Serial, '%d');      % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);
            end
        case 'f'
            fprintf('MOTOR OFF\n');             
            for i = 1:9
                n = fscanf(NU32_Serial, '%d');      % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);
            end
        case 'g'
            fprintf('Turning on motor ...\n');
            for i = 1:9
                n = fscanf(NU32_Serial, '%d');      % Get motor status 
                fprintf('%s = %d\n', STATUS{i},n);
            end
        case 'h'
            fprintf('Homing ...\n');            
            position = fscanf(NU32_Serial,'%d');                    % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);
        case 'i'
            
            ref = genRef_position(trajectory,mode);    % Generate step trajectory
            ref = ref*1000;                            % Convert trajectory to um
          
            fprintf(NU32_Serial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            
            for i = 1:size(ref,2)                   % Send trajectory to PIC32
               fprintf(NU32_Serial,'%f\n',ref(i)); 
            end
        case 'l'
            read_plot_matrix_position(NU32_Serial,1,ref); % Execute trajectory and plot results
        case 'n'
            pos = input('Enter the desired position in mm: ');  % Get position (mm)
            fprintf(NU32_Serial,'%d\n',pos*1000);               % Convert mm -> um and send position to PIC32       
            
            position = fscanf(NU32_Serial,'%d');                    % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);
        case 'o'            
            position = fscanf(NU32_Serial,'%d');                    % Get position in um from PIC32
            position = position/1000;                               % Convert position to mm
            fprintf('The motor position is %.2f mm.\n',position);
        case 'q'
            has_quit = true;    % exit client
        case 'r'
            mode = fscanf(NU32_Serial,'%d');    % Get mode from PIC32
            fprintf('The PIC32 controller mode is currently %s.\n',MODES{mode+1});
        case 's'
            for i = 1:9
                n = fscanf(NU32_Serial, '%d');  % Get state from PIC32
                fprintf('%s = %d\n', STATUS{i},n);
            end
        case 't'
            Fp = input('Enter your desired Fp position gain (A/N): ');     % Get Fp (A/N)
            Fi = input('Enter your desired Fi position gain (A/(N*s): ');  % Get Fi (A/(N*s))
            Fd = input('Enter your desired Fd position gain (A/(N/s): ');  % Get Fd (A/(N/s))
            fprintf(NU32_Serial, '%f %f %f\n',[Fp*512/145,Fi*512/145,Fd*512/145]);   % Convert N -> counts and send gains to PIC32
        case 'u'
            Fp = fscanf(NU32_Serial, '%f');    % Get Fp (A/counts)
            Fi = fscanf(NU32_Serial, '%f');    % Get Fi (A/(counts*s))
            Fd = fscanf(NU32_Serial, '%f');    % Get Fd (A/counts/s))
        case 'v'
            mode = input('Enter mode (''linear'', ''cubic'', or ''step''): ');
            trajectory = input('Enter trajectory, in sec and N [time1, force1; time2, force2; ...]: ');
            
            ref = genRef_position(trajectory,mode);   % Generate trajectory
            ref = ref*512/145;                        % Convert N -> counts
                        
            fprintf(NU32_Serial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            
            for i = 1:size(ref,2)                       % Send trajectory to PIC32
               fprintf(NU32_Serial,'%f\n',ref(i)); 
            end
        case 'w'
            read_plot_matrix_force(NU32_Serial,1,ref); % Execute trajectory and plot results
        case 'A'
            fprintf('Blower on\n');
        case 'B'
            fprintf('Blower off\n');
        case 'C'
            frequency = input('Enter desired blower frequency in Hz: ');
            fprintf(NU32_Serial,'%f\n',frequency);
            fprintf('Setting blower frequency to %f Hz\n',frequency);
        case '1'
            fgets(XY_Serial);   % Clear startup text in serial input
            buffer = fgets(XY_Serial);
            fprintf('%s',buffer);
            buffer = fgets(XY_Serial);
            fprintf('%s',buffer);
            
            is_grbl = true; % Continue sending commands until 'x'
            
            while is_grbl
                command = input('grbl command: ','s');  % Get command from user
                if command == 'x'
                    is_grbl = false;
                    fclose(XY_Serial);
                    fopen(NU32_Serial);
                else
                    fprintf(XY_Serial,'%s\n',command);  % Send command to grbl
                    buffer = fgets(XY_Serial);          % Read the echo from the grbl to verify correct communication
                    fprintf('%s',buffer);
                end   
            end    
            
        otherwise
            fprintf('Invalid Selection %c\n', selection);
    end
end


end
