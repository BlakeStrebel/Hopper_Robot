list = {avg_max_offset,avg_s170_offset,avg_s125_offset,avg_s100_offset,avg_s75_offset,avg_s50_offset,avg_s25_offset,avg_s0_offset};

figure;
hold on;

i = 1;
for structs = list
   if i == 1
       plot(structs{1}.pos(:,1),structs{1}.torque(:,1));
   else
       plot(structs{1}.pos(:,6),structs{1}.torque(:,6));
   end
   
   i = i + 1;
end


title('Torque vs Position')
 legend('max','170','125','100','75','50','25','0')
xlabel('Position (mm)')
ylabel('Torque (N*m)')

hold off;
