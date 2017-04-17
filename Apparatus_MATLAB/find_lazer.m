function [D] = find_lazer(img)
% Takes undistorted image and returns array containing image depth
% calibration details can be found in Data/Laser_Calibration


a = 200;
b = 375;
red = img(a:b,:,1);

[~,y] = size(red);

indices = zeros(1,640);


for i = 1:y
    [~,sortingIndices] = sort(red(:,i),'descend');
    indices(i) = mean(sortingIndices(1:3));
    indices(i) = indices(i) + a;
    D(i) = -0.001309*indices(i)^2 -0.004833*indices(i) + 144.6;
end

% %% verify laser detection
% figure;
% imshow(img);
% hold on;
% plot(1:y,indices,'red');

% for i = 1:y
%     I = im2double(red(:,i));
% %     I(I<.99) = 0;
%     indices(i) = sum(I.*[1:480]')/sum(I);
%     D(i) = -0.001309*indices(i)^2 -0.004833*indices(i) + 144.6;
% end
% 
% %% verify laser detection
% plot(1:y,indices,'blue');

