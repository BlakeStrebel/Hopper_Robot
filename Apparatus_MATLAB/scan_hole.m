function Depths = scan_hole(x,yi,distance,step_size)
%% Configure webcam
cam = webcam;

%% Setup xy table
XY_port = 'COM4';   % GRBL board serial port

% Open serial connection
if ~isempty(instrfind)  
    fclose(instrfind);
    delete(instrfind);
end

XY_Serial = serial(XY_port, 'BaudRate', 115200,'Timeout',20);
fopen(XY_Serial);
clean = onCleanup(@() fclose(XY_Serial));

% move to starting position
grbl_startup(XY_Serial);
grbl_home(XY_Serial);
grbl_moveX(XY_Serial,x);
grbl_moveY(XY_Serial,yi);
pause(8);

prompt = sprintf('y = %d, do you want to ajdust this position? (''y'' for yes, enter for no):\n',yi);
check = input(prompt);
while strcmp(check,'y')
   yi = input('new position: ');
   grbl_moveY(XY_Serial,yi);
   check = input('Keep adjusting? (y for yes, enter for no)');
end
pause(5);

%% Perform scan
y = yi;
for i = 1:((distance)/step_size)
    
    filename = sprintf('img%d.png',i);
    img = snapshot(cam);
    imwrite(img,filename,'png');
    Depths(i,:) = find_lazer(img);
    y = y+step_size;
    grbl_moveY(XY_Serial,y);
    pause(.1);

end

%image_data.depth_matrix = depth_matrix;