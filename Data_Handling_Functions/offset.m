function [position_offset, force_offset] = offset(position, force)

[initial_height,~,index] = find_ground2(position,force);

position_offset = position(index-200:end)-initial_height;
force_offset = force(index-200:end);




