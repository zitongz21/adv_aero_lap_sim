function [C_D, C_L, AB] = AdvAeroFunction(yaw, frh, rrh, aero_map)
%     C_L = 2.8; C_D = 1.5;
%     AB = 0.50; C_y = 0;
%     C_L = interp1(aero_map(:,1), aero_map(:,2), abs(yaw));
%     C_D = interp1(aero_map(:,1), aero_map(:,3), abs(yaw));
    C_L_scale = 1 + abs(yaw) * aero_map.C_L_beta;
    C_D_scale = 1 + abs(yaw) * aero_map.C_D_beta;
    RH_aero_map = aero_map.RH_aero_map;
    if size(RH_aero_map,1) == 1
        C_L = C_L_scale * RH_aero_map(1,3);
        C_D = C_D_scale * RH_aero_map(1,4);
    else
        if frh < min(RH_aero_map(:,1)); frh = min(RH_aero_map(:,1)); end
        if frh > max(RH_aero_map(:,1)); frh = max(RH_aero_map(:,1)); end
        if rrh < min(RH_aero_map(:,2)); rrh = min(RH_aero_map(:,2)); end
        if rrh > max(RH_aero_map(:,2)); rrh = max(RH_aero_map(:,2)); end
        C_L = C_L_scale * griddata(RH_aero_map(:,1), RH_aero_map(:,2), ...
            RH_aero_map(:,3), frh, rrh);
        C_D = C_D_scale * griddata(RH_aero_map(:,1), RH_aero_map(:,2), ...
            RH_aero_map(:,4), frh, rrh);
    end
    AB = 0.56;
end