function avg_data = average_intrusions(data)

for j = 1:size(data.trials(1).intrusion,2)
    for i = 1:size(data.trials,2)
        temp_pos(:,i) = data.trials(i).intrusion(j).actual_position;
        temp_force(:,i) = data.trials(i).intrusion(j).Fz;
        temp_torque(:,i) = data.trials(i).intrusion(j).T; 
    end
    avg_data.pos(:,j) = mean(temp_pos,2);
    avg_data.force(:,j) = mean(temp_force,2);
    avg_data.torque(:,j) = mean(temp_torque,2);
end