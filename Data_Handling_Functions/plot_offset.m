function [position_offset, force_offset] = plot_offset(position, force)

[initial_height,~,index] = find_ground2(position,force);

position_offset = position(index-200:end)-initial_height;
force_offset = force(index-200:end);

figure;
plot(position_offset,force_offset);
title('Force vs position')
xlabel('Depth (mm)')
ylabel('Force (N)')




