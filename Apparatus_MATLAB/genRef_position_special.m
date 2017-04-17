function ref = genRef_position_special(v,z,zend)
% genRef_position_special generates a special position trajectory which
% contains a region of constant acceleraion and a region of zero
% acceleration. This function is useful to generate trajectories with
% improved tracking.
% inputs:
%   v - desired velocity in mm
%   z - distance to accelerate to desired velocity
%   zend - final distance
%   show - 1 to plot trajectory
% outputs:
%   Refererence trajectory usable for control. See genRef_position for more
%   information

MOTOR_SERVO_RATE = 2000;    % 2000 Hz motion control loop
dt = 1/MOTOR_SERVO_RATE;    % time per control cycle

% calculations
a = v^2/(2*z);
tswitch = sqrt(z*2/a);
tend = tswitch + (zend-z)/v;

% generate trajectory
i = 1;
for t = 0:dt:tend
    if t < tswitch
        ref(i) = (1/2)*a*t^2; % accelerating region 
    else
        ref(i) = z + v*(t-tswitch);    % linear region
    end
    i = i+1;
end
    
% plot trajectory

str = sprintf('%d samples at %7.2f Hz taking %5.3f sec',length(ref),MOTOR_SERVO_RATE,tend);

figure;
plot(0:dt:tend,ref)
title(str);
xlabel('Time (s)')
ylabel('Posititon (mm)')

end