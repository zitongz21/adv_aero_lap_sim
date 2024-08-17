function results = lap_sim(track, car)
% track_def = xlsread('fsae_endurance_china_2016.xlsx');
% track_def = xlsread('\tracks\fsae_germany_optimumG.xlsx');
% track_def = xlsread('\tracks\fsae_lincoln_optimumG.xlsx');
track_def = xlsread(track);
track_def(:,3) = -track_def(:,3) .* track_def(:,1);
track_def = track_def(:,2:3);
n_track = size(track_def,1);
% track_def = [track_def; track_def;];
% track_def = [100,0;];
dS = 0.1; % track = [0,0,0,track_def(1,2)]; x, y, a, R
X = 0; Y = 0; S = 0; A_orient = 0; R = track_def(1,2);
for id_section = 1:size(track_def,1)
    L = track_def(id_section,1);     r = track_def(id_section,2);
    n = round(L/dS);        dx = L/n;
    if r==0; phi_corner = 0; else phi_corner = L/r; end
    da = phi_corner/n;
    
    for j = 1:n
        a = A_orient(end) + da;
        X = [X; X(end)+cos(a)*dx];   Y = [Y; Y(end)+sin(a)*dx];
        S = [S; S(end)+dx];          
        A_orient = [A_orient; a];    R = [R; r];
    end
end
R(R==0) = Inf;
n = size(S,1);
V = 1*ones(n,1);            RPM = 6500*ones(n,1);         GEAR = ones(n,1);
Acc_X = zeros(n,1);         Acc_Y = V.^2./R;
grip_req_x = zeros(n,1);    grip_req_y = zeros(n,1);
grip_avl = zeros(n,1);

Yaw = car.l_car./R/pi*180 / car.yaw_scale; % aSteer = car_wb./R/pi*180;
Yaw(Yaw>25) = 25; Yaw(Yaw<-25) = -25;

% driveline
% GEAR = [33/12; 32/16; 30/18; 26/18; 30/23; 29/24;];
% primary_drive = 76/36;
% final_drive = 38/11;
% diff_drive = 1;
% r = 0.228;

% RPM(1) = find_rpm(V(1), GEAR(1)); 
rpm_lim = car.rpm_lim; 
C_D_straight = AdvAeroFunction(0, 10, 10, car.aero_map);
rho = 1.225;
v_max = ( EngineFunction(rpm_lim, car.engine) ...
    *2/rho/car.A0/C_D_straight )^(1/3);
RPM(1) = 6500;

i = 2;tic;
while i <= size(S,1)
    [V(i), Acc_X(i), Acc_Y(i)] = lap_sim_RK4(car, ...
        V(i-1), GEAR(i-1), Acc_X(i-1), Acc_Y(i-1), R(i-1), Yaw(i-1), 0, dS);

    rpm = find_rpm(V(i), GEAR(i-1), car.powertrain);
    if rpm > rpm_lim
        if GEAR(i-1)<6; 
            GEAR(i) = GEAR(i-1)+1;
        else
            GEAR(i) = GEAR(i-1);    % top-gear
        end
        RPM(i) = find_rpm(V(i), GEAR(i), car.powertrain);
    else
        GEAR(i) = GEAR(i-1);
        RPM(i) = rpm;
    end
    if RPM(i) > rpm_lim
        V(i) = v_max; RPM(i) = rpm_lim;
    end
    if isinf(R(i)); % if is straight-line
        v_csc = v_max;
    else
        v_csc = find_max_csc(R(i), Yaw(i), car, v_max);
        % find maximum constant speed cornering speed
    end
    

    
    if V(i) - v_csc > 0.5; % if speed too high for cornering
            
        V(i) = v_csc; Acc_X(i) = 0; Acc_Y(i) = V(i)^2/R(i);
        rpm_temp = find_rpm(v_csc, 1:6, car.powertrain);
        if max(rpm_temp) < 6500
            [RPM(i), GEAR(i)] = max(rpm_temp);
        else
            rpm = max(rpm_temp(rpm_temp <= rpm_lim));
            if isempty(rpm)
                RPM(i) = rpm_lim;
                GEAR(i) = 6;
            else
                RPM(i) = rpm;
                GEAR(i)= find(rpm_temp==rpm);
            end
        end
        j = i; disp(['S=' num2str(S(j)), ', int. backward']);
        while V(j-1) - V(j) > 0.5
            % backward integrate to calculate braking
            [V(j-1), Acc_X(j-1), Acc_Y(j-1)] = lap_sim_RK4(car, ...
                V(j), GEAR(j), Acc_X(j), Acc_Y(j), R(j), Yaw(j), 1, dS);
            rpm = find_rpm(V(j-1), GEAR(j), car.powertrain);
            if rpm > rpm_lim
                if GEAR(j) < 6; GEAR(j-1) = GEAR(j)+1;
                else GEAR(j-1) = GEAR(j); end
                    RPM(j-1) = find_rpm(V(j-1), GEAR(j-1), car.powertrain);
            else
                GEAR(j-1) = GEAR(j);
                RPM(j-1) = rpm;
            end
            j = j - 1;
            if V(j) > v_max; V(j) = v_max;  end
        end
        if j == 1;
            disp('wtf?!');
        end
    end
    if V(i) > v_max;    V(i) = v_max;   end
    disp(['S=' num2str(S(i)), ', int. forward']);
    i = i + 1;
end
toc;

results.lap_time = sum(dS./V); %[sum(dS./V(1:floor(n/2))), sum(dS./V(ceil(n/2):end))];
results.S = S;
results.V = V;
results.RPM = RPM;
results.GEAR = GEAR;
results.X = X;
results.Y = Y;
results.Yaw = Yaw;
results.Acc_X = Acc_X;
results.Acc_Y = Acc_Y;
disp(results.lap_time);



% h = scatter(X, Y);

% data_ol = xlsread('\sim_data\optimum_lap_fsg_endu_2012.csv');
% s_ol = data_ol(:,3); v_ol = data_ol(:,1);

% plot(S, V*3.6); hold on;
% plot(s_ol, v_ol)
% V_max_csc = sqrt(mu * m0 * g ./ ...
%                 (sqrt(  (m0./abs(R)+0.5*rho*C_y*A0).^2+(0.5*rho*C_D*A0).^2 ...
%                      ) - 0.5*mu*rho*C_L*A0) );
% % V_max_lift = ( mu * m * g ./ (m./abs(R) - 0.5*mu*rho*C_L*Area) ).^0.5;
% 
% n_grid = size(R,1);
% straight_entry = find(diff(abs([-1; R]))< 0 & R==0);
% straight_exit  = find(diff(abs([R;   1]))> 0 & R==0);
% corner_exit = straight_entry - 1; corner_exit(corner_exit==0) = n_grid;
% corner_entry = straight_exit + 1; corner_entry(corner_entry>n_grid) = 1;
% Acc_x = zeros(size(R)); Acc_y = zeros(size(R));
% Acc_y(R~=0) = V_max_csc(R~=0).^2 ./ R(R~=0);
% 
% V = V_max_csc;
% V(straight_entry) = V(corner_exit); % V(straight_exit) - V(corner_entry)
% V(1) = 0.1;
% 
% for I_straight = 1:size(straight_entry, 1)
%     for j = straight_entry(I_straight):straight_exit(I_straight)-1
%         Acc_y(j) = 0;
%         Acc_x(j) = min([...
%             ( P_max*1000/V(j) - 0.5*rho*C_D*A0*V(j)^2 ) / m0, ...
%             mu * ( m0*g        + 0.5*rho*C_L*A0*V(j)^2 ) / m0]);
%         dt(j)=( -2*V(j) + sqrt(4*V(j)^2+8*Acc_x(j)*(S(j+1)-S(j))) ) / ...
%             (2*Acc_x(j));
%         V(j+1) = V(j) + Acc_x(j) * dt(j);
%     end
% end
% 
% % figure('Color', [1,1,1]);
% % subplot(1,2,1); scatter3(X, Y, V);
% % subplot(1,2,2); scatter(S, V);
% 
% brake_sect = find(diff(V)<-0.5 & V(1:end-1) > 10);
% for I_brake = 1:size(brake_sect, 1);
%     delta_v = 0.2; j = brake_sect(I_brake)+1;
%     while delta_v > 0.1
%         grip = mu * (m0*g + 0.5*rho*C_L*A0*V(j)^2);
%         if R(j) == 0; Acc_y(j) = 0;
%         else Acc_y(j) = V(j)^2 / R(j); end
%         grip_avl_x = sqrt(grip.^2 - (m0*Acc_y(j)).^2);
%         Acc_x(j) = (-grip_avl_x-0.5*rho*C_D*A0*V(j)^2) / m0;
%         dt(j) = ( -2*V(j) + sqrt(4*V(j)^2+8*Acc_x(j)*(S(j+1)-S(j))) ) / ...
%             (2*Acc_x(j));
%         V(j-1) = V(j) - Acc_x(j) * dt(j);
%         delta_v = V(j-2) - V(j-1); j = j - 1;
%     end
% end
% 
% % figure(); scatter(S, V);
% 
% acc_sect = find(diff(V) > 0.5 & V(1:end-1) > 5);
% for I_acc = 1:size(acc_sect, 1);
%     delta_v = 0.2; j = acc_sect(I_acc);
%     while delta_v > 0.1
%         grip = mu * (m0*g + 0.5*rho*C_L*A0*V(j)^2);
%         if R(j) == 0; Acc_y(j) = 0;
%         else Acc_y(j) = V(j)^2 / R(j); end
%         grip_avl_x = sqrt(grip.^2 - (m0*Acc_y(j)).^2);
%         if ~isreal(grip_avl_x)
%             disp('!');
%         end
%         Acc_x(j) = (grip_avl_x-0.5*rho*C_D*A0*V(j)^2) / m0;
%         dt(j) = ( -2*V(j) + sqrt(4*V(j)^2+8*Acc_x(j)*(S(j+1)-S(j))) ) / ...
%             (2*Acc_x(j));
%         V(j+1) = V(j) + Acc_x(j) * dt(j);
%         if j+2<=size(V,1); delta_v = V(j+2) - V(j+1); j = j + 1;
%         else delta_v = 0; end
%     end
% %     figure(); scatter(S, V);
% end
% 
% disp(sum(dx./V));
% figure('Color', [1,1,1]);
% subplot(1,2,1); scatter3(X, Y, V);
% subplot(1,2,2); plot(S, V);
% 
% V_max = ( mu * m0 * g ./ (m0./R - 0.5*mu*rho*C_L*A0) ).^0.5;
% % G_avl = 
% % G_req = 