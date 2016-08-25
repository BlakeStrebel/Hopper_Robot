function data = read_plot_matrix_blower(mySerial)

  nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
  data = zeros(nsamples,2);               % two values per sample:  ref and actual

  for i=1:nsamples
    data(i,:) = fscanf(mySerial,'%f %f'); % read in data from PIC32; assume floats, in Hz
    times(i) = (i-1)*0.05;                % 0.05 s between samples   
  end
  if nsamples > 1						        
    figure
    stairs(times,data(:,1:2));            % plot the reference and actual
  else
    fprintf('Only 1 sample received\n')
    disp(data);
  end
  % compute the average error
  score = mean(abs(data(:,1)-data(:,2)));
  
  title(sprintf('Avg error: %5.1f Hz',score))
  ylabel('Frequency (Hz)')
  xlabel('Time (s)')
  legend('reference','actual')
  
end
