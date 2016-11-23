function [height, F, index] = find_ground(position,force)
% Finds the distance from the initial foot position to ground contact.
% Works best for slow intrusions. Varify results with plot
% Takes as inputs:
%   position: an array containing position data for a single intrusion
%   force: an array containing force data for the same intrusion
% Returns:
%   height: the distance from the initial position to ground contact
%   F:  the force at calculated ground contact
%   index: the index in both arrays representing ground contact

% tune these for particular intrusion
d = 200;                
z = 3.5;

avg = mean(force(1:d)); % Find avg and std of first x data points   
stddev = std(force(1:d));
index = find(force(d:end) > (avg + z*stddev),1);  % ground is z stddev away from the average value
height = position(index);
F = force(index);

%% Verify results with a plot
% figure;
% hold on;
% plot(position,force);
% plot(height,F,'-og')
% title('Force vs. depth')
% xlabel('Depth (mm)')
% ylabel('Force (N)')
% hold off;