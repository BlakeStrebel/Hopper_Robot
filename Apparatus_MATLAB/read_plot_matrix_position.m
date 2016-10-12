function data = read_plot_matrix_position(mySerial,graph,ref)
% Reads in data from PIC32 during position trajectory execution
% data(:,1) = reference position
% data(:,2) = actual position
% data(:,3) = current
% data(:,4) = force

nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
data = zeros(nsamples,4);               

for i=1:nsamples
    data(i,2:4) = fscanf(mySerial,'%d %f %d'); % read in data from PIC32; position (um), current(amps), force(counts) 
end

data(:,1) = ref;
data(:,1:2) = data(:,1:2)/1000;  % convert um to mm
data(:,4) = data(:,4)*145/512; % convert counts to N

if nsamples > 1						        
    if graph == 1
    figure
    stairs(times,data(:,2:4));            % plot the reference and actual
    % compute the average error
    score = mean(abs(data(:,1)-data(:,2)));
    title(sprintf('Avg error: %5.1f mm',score))
    ylabel('Position (mm)')
    xlabel('Time (ms)')
    legend('position','motor force (N)','ATI force (N)')
    
    figure
    hold on;
    plot(data(:,2),data(:,4));
    plot(data(:,2),data(:,3));
    title('Force vs Depth');
    xlabel('Depth (mm)');
    ylabel('Force (A)');
    legend('Force sensor','Motor current');
    end
else
    fprintf('Only 1 sample received\n')
    disp(data);
end

end
