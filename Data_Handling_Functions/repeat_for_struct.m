function repeat_for_struct(data)
% Loops through all intusions in a given struct and performs
% operations. Adjust for desired purpose. Typically used for ploting many
% intrusions at once
% Inputs:
%   Data: experimental_data struct

figure; hold on;

for j = 1:size(data.trials(1).intrusion,2)
    for i = 1:size(data.trials,2)
        temp_pos = data.trials(i).intrusion(j).actual_position;
        temp_force = data.trials(i).intrusion(j).Fz;
        % Modify this region
        if j == 1
            plot(temp_pos(10:end),temp_force(10:end),'b');
        elseif j == 2
            plot(temp_pos(10:end),temp_force(10:end),'r');
        else
            plot(temp_pos(10:end),temp_force(10:end),'g');
        end
    end
end


xlabel('position (mm)')
ylabel('force (N)')
hold off;
