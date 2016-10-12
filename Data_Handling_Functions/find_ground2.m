function [height, F, index] = find_ground2(position,force)

avg = mean(force(1:100));
stddev = std(force(1:100));
index = find(force(100:end) > (avg + 3.5*stddev),1);
height = position(index+100);
F = force(index+100);

%% Verify results with a plot
figure;
hold on;
plot(position,force);
plot(height,F,'-og')
title('Force vs. depth')
xlabel('Depth (mm)')
ylabel('Force (N)')
hold off;