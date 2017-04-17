function depth_map = perform_scan(yi, distance, step_size, XY_Serial, cam, cameraParameters)

% move to starting position
grbl_moveY(XY_Serial,yi);
pause(8);

%% Perform scan
y = yi;
for i = 1:((distance)/step_size)
    filename = sprintf('img%d.png',i);
    img = snapshot(cam);
    img = undistortImage(img,cameraParameters);
    imwrite(img,filename);
    depth_map(i,:) = find_lazer(img);
    y = y+step_size;
    grbl_moveY(XY_Serial,y);
    pause(.2);
end


end