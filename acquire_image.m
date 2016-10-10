function [mean_height,std_heights] = acquire_image(filename)
%% configure webcam
cam = webcam('Logitech');

%% take snapshot
img = snapshot(cam);
clear('cam');

%% convert picture to grayscale
img_gray = rgb2gray(img(80:end,:,:));
imwrite(img_gray,filename,'bmp');

%% find bed height
numRows = size(img_gray,1);
numColumns = 640;
xmin = 50;        % minimum column number to prevent scanning of calibration ruler

model = @(b,x)b(1)+ b(2)*tanh((x-b(3))/b(4));   % hyperbolic tangent function
beta0 = [130 -75 180 2];                        % estimate coefficients 
z = (1:numRows)';                               % predictor variable

for i = xmin:(numColumns)
    y = double(img_gray(:,i));                  % response variable
    mdl = fitnlm(z,y,model,beta0);              % fit nonlinear regression model
    heights(i-xmin+1) = mdl.Coefficients{3,'Estimate'}; % extract estimate for bed height
end

%% convert bed height to cm
heights = (579-heights).*(1/52);

%% plot bed heights
% figure;
% plot(xmin:numColumns,heights);
% xlabel('Column Number (pixels)');
% ylabel('Bed Height (cm)');
% title('Bed Height vs Column Number');

%% return mean and standard deviation
mean_height = mean(heights);
std_heights = std(heights);

end