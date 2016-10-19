function offset_experimental_data = offset_struct(experimental_data,num_intrusions,num_trials)

% Offset everything
for j = 1:num_intrusions
    for i = 1:num_trials
        [offset_experimental_data.trials(i).intrusion(j).actual_position,offset_experimental_data.trials(i).intrusion(j).Fz] = offset(experimental_data.trials(i).intrusion(j).actual_position,experimental_data.trials(i).intrusion(j).Fz);
        sizes(i,j) = size(offset_experimental_data.trials(i).intrusion(j).actual_position,1);   
    end
end

min_size = min(min(sizes));

for j = 1:num_intrusions
    for i = 1:num_trials
        offset_experimental_data.trials(i).intrusion(j).actual_position = offset_experimental_data.trials(i).intrusion(j).actual_position(1:min_size);
        offset_experimental_data.trials(i).intrusion(j).fz = offset_experimental_data.trials(i).intrusion(j).Fz(1:min_size);
    end
end
 