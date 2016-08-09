function data = read_plot_matrix(mySerial)

  nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
  data = zeros(nsamples,3);               % two values per sample:  ref and actual
  for i=1:nsamples
    data(i,:) = fscanf(mySerial,'%f %f %f'); % read in data from PIC32; assume floats, in mm
    times(i) = (i-1)*0.5;                % 0.5 ms between samples
  end
  if nsamples > 1						        
    figure
    stairs(times,data(:,1:3));            % plot the reference and actual
  else
    fprintf('Only 1 sample received\n')
    disp(data);
  end
  % compute the average error
  score = mean(abs(data(:,1)-data(:,2)));
  fprintf('\nAverage error: %5.1f mm\n',score)
  title(sprintf('Average error: %5.1f mm',score))
  ylabel('Position (mm)')
  xlabel('Time (ms)')
  legend('reference','actual','current (A/100)')
end
