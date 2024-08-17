function rpm = find_rpm(v, gear, powertrain)
%     GEAR = [33/12; 32/16; 30/18; 26/18; 30/23; 29/24;];
    gear_ratio = powertrain.gear_ratio;
    primary_drive = powertrain.primary_drive;
    final_drive = powertrain.final_drive;
    r_wheel = powertrain.r_wheel;
    
    rpm = v*60/(2*pi*r_wheel)*final_drive*primary_drive.*gear_ratio(gear);
    if numel(rpm) > 1
        rpm(rpm<=6000) = 6000;
    else
        rpm(rpm<=6000) = 6000;
    end
    
%     gear_ratio = [18.00; 14.75; 12.25; 10.25; 9.00; 7.90; 7.00;];
%     r = 0.35;