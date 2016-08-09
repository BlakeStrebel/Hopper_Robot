function client()
%   provides a menu for accessing PIC32 motor control functions

port = 'COM5';

% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

fprintf('Opening port %s....\n',port);

% settings for opening the serial port. baud rate 230400, hardware flow control
% wait up to 120 seconds for data before timing out
mySerial = serial(port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',120); 
% opens serial connection
fopen(mySerial);
% closes serial port when function exits
clean = onCleanup(@()fclose(mySerial));                                 

has_quit = false;
% menu loop
while ~has_quit
    fprintf('PIC32 MOTOR DRIVER INTERFACE\n\n');
    % display the menu options
    %fprintf(['     a: Read encoder (counts)                 b: Read encoder (mm)\n' ...
    %         '     c: Reset encoder                         \n' ...   
    %         '     q: Quit client                           r: Get mode\n' ...    
    %         '     s: Get state                          \n']);
    
    % read the user's choice
    selection = input('\nENTER COMMAND: ', 's');
     
    % send the command to the PIC32
    fprintf(mySerial,'%c\n',selection);
    
    % take the appropriate action
    switch selection
        
        case 'a'
            counts = fscanf(mySerial,'%d');
            fprintf('The motor position is %d counts.\n',counts);
        case 'b'                        
            position = fscanf(mySerial,'%f');
            fprintf('The motor position is %.2f mm.\n',position); 
        case 'c' 
            fprintf('Zero reset\n');
        case 'i'
            Kp = input('Enter your desired Kp position gain: ');
            Ki = input('Enter your desired Ki position gain: ');
            Kd = input('Enter your desired Kd position gain: ');
            fprintf(mySerial, '%f %f %f\n',[Kp,Ki,Kd]);
            fprintf('Sending Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',Kp,Ki,Kd);
        case 'j'
            Kp = fscanf(mySerial, '%f');
            Ki = fscanf(mySerial, '%f');
            Kd = fscanf(mySerial, '%f');
            fprintf('The position controller is using Kp = %3.2f, Ki = %3.2f, and Kd = %3.2f.\n',[Kp,Ki,Kd]);
        case 'k'
            fprintf('Starting motor ...\n');
        case 'l'
            pos = input('Enter the desired position in mm: ');
            fprintf(mySerial,'%f\n',pos);
            fprintf('Motor moving to %f mm.\n',pos);
        case 'm'
            trajectory = input('Enter step trajectory, in sec and degrees [time1, ang1; time2, ang2; ...]:\n');
            
            if trajectory(end,1) > 10   % Check that time is less than 10 seconds
                fprintf('Error: maximum trajectory time is 10 seconds.\n')
            else
                ref = genRef(trajectory,'step');    % Generate step trajectory
            end
            
            fprintf(mySerial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            
            for i = 1:size(ref,2)                   % Send trajectory to PIC32
               fprintf(mySerial,'%f\n',ref(i)); 
            end
        case 'n'
            trajectory = input('Enter cubic trajectory, in sec and mm [time1, pos1; time2, pos2; ...]:\n');
            
            if trajectory(end,1) > 10 % Check that time is less than 10 seconds
                fprintf('Error: maximum trajectory time is 10 seconds.\n')
            else
                ref = genRef(trajectory,'cubic');   % Generate cubic trajectory
            end
            
            fprintf(mySerial,'%d\n',size(ref,2));   % Send number of samples to PIC32
            for i = 1:size(ref,2)                   % Send trajectory to PIC32
               fprintf(mySerial,'%f\n',ref(i)); 
            end 
        case 'o'
            read_plot_matrix(mySerial); 
        case 'q'
            has_quit = true;    % exit client
        case 'r'
            modes = {'IDLE';'HOLD';'TRACK'};
            mode = fscanf(mySerial,'%d');
            fprintf('The PIC32 controller mode is currently %s.\n',modes{mode+1});
        case 's'
            state = {'SWITCH_ON', 'HOME', 'ERROR_ACK', 'SPECIAL_MODE', 'GO_INITAL_POS', 'IN_TARG_POS', 'WARNING', 'ERROR', 'SPECIAL_MOTION'};
            for i = 1:9
                n = fscanf(mySerial, '%d');
                fprintf('%s = %d\n', state{i},n);
            end
        case 'x'
            fprintf('Motor off\n')
        case 'y' % test dac
            n = input('Enter desired voltage: ');
            fprintf(mySerial,'%f\n',n);
        case 'z'                            % example operation
            n = input('Enter number: ');    % get the number to send
            fprintf(mySerial,'%d\n',n);     % send the number
            n = fscanf(mySerial,'%d');      % get the incremented number back
            fprintf('Read: %d\n',n);        % print it to the screen
        otherwise
            fprintf('Invalid Selection %c\n', selection);
    end
end

end
