function offset_data = offset_struct(data)

% Offset everything
for j = 1:size(data.trials(1).intrusion,2)
    for i = 1:size(data.trials,2)
        [offset_data.trials(i).intrusion(j).actual_position,offset_data.trials(i).intrusion(j).Fz] = offset(data.trials(i).intrusion(j).actual_position,data.trials(i).intrusion(j).Fz);
        sizes(i,j) = size(offset_data.trials(i).intrusion(j).actual_position,1);   
    end
end

min_size = min(min(sizes));

for j = 1:size(data.trials(1).intrusion,2)
    for i = 1:size(data.trials,2)
        offset_data.trials(i).intrusion(j).actual_position = offset_data.trials(i).intrusion(j).actual_position(1:min_size);
        offset_data.trials(i).intrusion(j).Fz = offset_data.trials(i).intrusion(j).Fz(1:min_size);
        offset_data.trials(i).intrusion(j).Tx = data.trials(i).intrusion(j).Tx(1:min_size);
        offset_data.trials(i).intrusion(j).Ty = data.trials(i).intrusion(j).Ty(1:min_size);
        offset_data.trials(i).intrusion(j).T = ((offset_data.trials(i).intrusion(j).Tx).^2 +  (offset_data.trials(i).intrusion(j).Ty).^2).^(1/2);
    end
end
 