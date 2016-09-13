function data = read_plot_matrix_position(mySerial,graph,ref)

nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
data = zeros(nsamples,3);               % two values per sample:  ref and actual

for i=1:nsamples
    data(i,1) = ref(i);
    data(i,2:3) = fscanf(mySerial,'%d %f'); % read in data from PIC32; assume ints, in um
    data(i,1:2) = data(i,1:2)/1000;          % convert um -> mm
    times(i) = (i-1)*0.5;                    % 0.5 ms between samples
end
if nsamples > 1						        
    if graph == 1
    figure
    data(:,3) = data(:,3)*100;
    stairs(times,data(:,1:2));            % plot the reference and actual
    % compute the average error
    score = mean(abs(data(:,1)-data(:,2)));
    title(sprintf('Avg error: %5.1f mm',score))
    ylabel('Position (mm)')
    xlabel('Time (ms)')
    legend('reference','actual')
    
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
