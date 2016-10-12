function offset_experimental_data = offset_struct(experimental_data)

num_intrusions = 21;
num_trials = 10;

% Offset everything
for j = 1:num_intrusions
    for i = 1:num_trials
        [offset_experimental_data.trials(i).intrusion(j).actual_position,offset_experimental_data.trials(i).intrusion(j).force] = offset(experimental_data.trials(i).intrusion(j).actual_position,experimental_data.trials(i).intrusion(j).force);
        sizes(i,j) = size(offset_experimental_data.trials(i).intrusion(j).actual_position,1);   
    end
end

min_size = min(min(sizes));

for j = 1:num_intrusions
    for i = 1:num_trials
        offset_experimental_data.trials(i).intrusion(j).actual_position = offset_experimental_data.trials(i).intrusion(j).actual_position(1:min_size);
        offset_experimental_data.trials(i).intrusion(j).force = offset_experimental_data.trials(i).intrusion(j).force(1:min_size);
    end
end
 