function avg_data = average_intrusions(data)
% Averages all trials for a given intusion position within a data struct
% Inputs:
%   data: experimental_data struct
% Returns:
%   avg_data: Struct containing averaged position and force data

for j = 1:size(data.trials(1).intrusion,2)
    for i = 1:size(data.trials,2)
        temp_pos(:,i) = data.trials(i).intrusion(j).actual_position;
        temp_force(:,i) = data.trials(i).intrusion(j).Fz; 
    end
    avg_data.pos(:,j) = mean(temp_pos,2);
    avg_data.force(:,j) = mean(temp_force,2);
end