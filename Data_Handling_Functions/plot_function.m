
for j = 1:6
    for i = 1:10
        temp_pos(:,i) = offset_experimental_data.trials(i).intrusion(j).actual_position;
        temp_force(:,i) = offset_experimental_data.trials(i).intrusion(j).force;
    end
    avg_pos(:,j) = mean(temp_pos,2);
    avg_force(:,j) = mean(temp_force,2);
end


std_off( find( mod( 1:length(mean_trial1), 200 ) > 0 ) ) = NaN

for j = 1:6
for i = 1:10
heights(i,j) = find_ground(experimental_data.trials(i).intrusion(j).actual_position,experimental_data.trials(i).intrusion(j).force);
end
end

height_vec = reshape(heights,[],1);
for i = 1:6, heights_coordinates((i*10-9):(i*10),2) = i; end

scatter(heights_coordinates(:,2),heights_coordinates(:,1))
title('Distance to Ground vs. Intrusion Number')
xlabel('Intrusion')
ylabel('Distance to Ground')
