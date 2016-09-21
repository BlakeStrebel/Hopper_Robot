function data = read_plot_matrix_force(mySerial,graph,ref)

nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
data = zeros(nsamples,4);               % two values per sample:  ref and actual

for i=1:nsamples

    data(i,1:3) = fscanf(mySerial,'%d %f %d'); % read in data from PIC32; position (um); current (amps); force (counts)

end

for i =1:nsamples
    data(i,1) = data(i,1)/1000;                     % convert um -> mm
    data(i,2) = data(i,2)*12.5;                  % convert A -> N
    data(i,3) = data(i,3)*145/512;          % convert counts -> N
    data(i,4) = ref(i)*145/512;
    times(i) = (i-1)*0.5;                       % 0.5 ms between samples
end

if nsamples > 1						        
    if graph == 1
    figure

    stairs(times,data(:,1:4));            % plot the reference and actual
    % compute the average error
    score = mean(abs(data(:,4)-data(:,3)));
    title(sprintf('Avg error: %5.2f N',score))
    ylabel('Position (mm)')
    xlabel('Time (ms)')
    legend('position','motor current (N)','ATI force (N)', 'ref force (N)')
    
%     figure
%     plot(data(:,2),data(:,3));
%     title('Current vs Position');
%     xlabel('Position (mm)');
%     ylabel('Current (A)');
    end
else
    fprintf('Only 1 sample received\n')
    disp(data);
end

end