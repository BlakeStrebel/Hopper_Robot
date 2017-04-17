function repeat_for_structs(list)
% Loops through a list of structs and performs a desired task. Adjust for 
% specific purpose. Typically used for ploting data from several averaged
% structs at once.
% Inputs:
%   list: A cell list of struct names
% Example list: 
%   list = {avg_max,avg_s0,avg_s5,avg_s10,avg_s15,avg_s20,avg_s25,avg_s30,avg_s40,avg_s50,avg_s60,avg_s75,avg_s100};


i = 1;
for structs = list
   % Modify this region %
   figure; 
   plot(structs{1}.pos(:,1),structs{1}.force(:,1));
   i = i + 1;
end


% title('Force vs Position')
% xlabel('Position (mm)')
% ylabel('Force (N)')

hold off;
