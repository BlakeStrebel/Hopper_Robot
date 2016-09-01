function data = read_plot_matrix_current(mySerial,plot)

  nsamples = fscanf(mySerial,'%d');       % first get the number of samples being sent
  data = zeros(nsamples,2);               % two values per sample:  ref and actual

  for i=1:nsamples
    data(i,:) = fscanf(mySerial,'%f %d');  % read in data from PIC32; current->float (A) position->int (um)
    data(i,2) = data(i,2)/1000;            % convert um -> mm
    times(i) = (i-1)*0.5;                  % 0.5 ms between samples
  end
  if nsamples > 1						        
    if plot == 1
        figure;
        stairs(times,data(:,1:2));            % plot the reference and actual
        max_depth = max(data(:,2));
        title(sprintf('Max depth: %.2f mm',max_depth))
        ylabel('Position (mm)')
        xlabel('Time (ms)')
        legend('current','position')
    end
  else
    fprintf('Only 1 sample received\n')
    disp(data);
  end
  

  
end
