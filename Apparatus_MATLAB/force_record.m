function force_record(mySerial)

figure;
hold on;
axis([0 1100 -100 60]);
title('Force vs Sample')
xlabel('Sample')
ylabel('Force (counts)');

done = 0;
counter = 1;
while(~done)
    force(counter) = fscanf(mySerial,'%d');
    cla;
    plot(force);
    drawnow;
    counter = counter + 1;
    if (counter == 100000)
        done = 1;
    end
end


end