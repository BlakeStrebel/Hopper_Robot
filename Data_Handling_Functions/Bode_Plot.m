function Bode_Plot(figlist)

j = 1;
for i = figlist
   open(i{1})
   D=get(gca,'Children'); %get the handle of the line object
   XData=get(D,'XData'); %get the x data
   YData=get(D,'YData'); %get the y data
   A = YData{2};
   
   B=abs(fft(A));
   n = str2num(strtok(i{1},'.'));
  
   Amplitudes(j) = B(n+1)/500
   Frequencies(j) = n
   j = j + 1;
end

figure;
scatter(Frequencies, Amplitudes,'filled');
xlabel('Frequency (Hz)'); ylabel('A/A0')