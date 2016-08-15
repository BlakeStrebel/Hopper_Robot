function data = read_plot_matrix(mySerial,fileID)

  nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
  data = zeros(nsamples,3);               % two values per sample:  ref and actual
  sum = 0;
  n = 20;
  for i=1:nsamples
    data(i,:) = fscanf(mySerial,'%d %d %f'); % read in data from PIC32; assume ints, in um
    data(i,1:2) = data(i,1:2)/1000;          % convert um -> mm
    times(i) = (i-1)*0.5;                    % 0.5 ms between samples
 
    sum = sum + data(i,3);
    if mod(i,n) == 0
        average = sum/n;
        data((i-n+1):i,3) = average;
        sum = 0;
    end
    
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
  max_current = max(data(:,3))/100;
  max_force = max(data(:,3))/100*12.5;
  
  if (~strcmp('none',fileID))
      fprintf(fileID,'%f\r\n',max_force);
  end
  
  fprintf('Max Average current: %.2f\n',max_current)
  fprintf('Max Average force: %.2f\n',max_force)
  title(sprintf('Avg error: %5.1f mm Max current: %.2f A',score,max(data(:,3))/100))
  ylabel('Position (mm)')
  xlabel('Time (ms)')
  legend('reference','actual','current (100 = 1A)')
  
end
