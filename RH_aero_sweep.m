% % advanced_aero_sim
% car.m0 = 280;                   % mass, kg
% car.A0 = 1;                     % frontal area
% car.h_cg = 0.335;               % CG height, m
% car.tire_id = 3;                % tire compound ID
% car.l_car = 1.55;               % wheelbase
% car.b_car = 1.2;                % track
% car.m_dist = 0.52;              % mass distribution (rear percentage)
% car.yaw_scale = 0.75;           % scaling factor for yaw angle
% car.aero_map.C_L_beta = -0.02;
% car.aero_map.C_D_beta =  0.03;
% RH_aero_map = [...          % frh, rrh, C_L, C_D
%     25	20	2.585 1.50; ...
%     25	10	2.442 1.50; ... 
%     20	20	3.355 1.50; ...
%     15	20	2.870 1.50; ...
%     15	15	2.754 1.50; ...
%     10	20	3.422 1.50; ...
%     25	15	2.594 1.50; ...
%     20	15	2.776 1.50; ...
%     20	10	2.680 1.50; ...
%     15	10	3.451 1.50; ...
%     10	10	3.600 1.50; ...
%     ];
% 
% 
% 
% car.engine = 'f1_2012_generic';     % engine specification
% car.powertrain.gear_ratio = ...     % powertrain, gear ratio
%     [18.00; 14.75; 12.25; 10.25; 9.00; 7.90; 7.00;];
% car.powertrain.final_drive = 1;     % powertrain, final_drive
% car.powertrain.primary_drive = 1;   % powertrain, primary_drive
% car.powertrain.r_wheel = 0.35;      % powertrain, primary_drive
% 
% % powertrain
% car.rpm_lim = 12700;
% car.engine = 'gsx_r600';
% car.powertrain.gear_ratio = ...     % powertrain, gear ratio
%     [2.7850; 2.0520; 1.7140; 1.5000; 1.3480; 1.2080];
% car.powertrain.final_drive = 38/11;
% car.powertrain.primary_drive = 76/36;
% car.powertrain.r_wheel = 0.228;     % powertrain, r_wheel
% 
% d_frh = -8:4:8; d_rrh = -8:4:8;
% FRH = zeros(5); RRH = zeros(5); tLap = rand(5);
% for f = 1:5;for r = 1:5;FRH(f,r) = d_frh(f);RRH(f,r) = d_rrh(r);end;end;
% 
% [~, hC] = contourf(FRH, RRH, tLap); colormap jet;
% drawnow; tLap(:) = NaN;
% 
% for f = 1:5
%     for r = 1:5
%         rh_aero_map = RH_aero_map;
%         rh_aero_map(:,1) = rh_aero_map(:,1) + d_frh(f);
%         rh_aero_map(:,2) = rh_aero_map(:,2) + d_rrh(r);
%         car.aero_map.RH_aero_map = rh_aero_map;
%         rh_sweep_germany(f,r) = ...
%             lap_sim('\tracks\fsae_germany_optimumG.xlsx',car);
%         tLAP(f,r) = rh_sweep_germany(f,r).lap_time;
%         set(hC, 'ZData', tLap); drawnow;
%     end
% end
% 
% tLAP{4} = tLap;
% track_dir = {   '\tracks\fsae_austria_optimumG.xlsx', ...
%                 '\tracks\fsae_lincoln_optimumG.xlsx',...
%                 '\tracks\fsae_michigan_optimumG.xlsx'   };
% track_name = {'Austria', 'Lincoln', 'Michigan'};
% for t = 1:3
%     tLAP{t} = rand(5);
%     figure('Name', track_name{t}, 'Color', [1,1,1]);
%     [~, hContour{t}] = contourf(FRH, RRH, tLAP{t}); colormap jet;
%     axis equal; drawnow; tLAP{t}(:) = NaN;
%     title(track_name{t}, 'FontSize', 18, 'FontName', 'Times New Roman');
%     for f = 1:5
%     for r = 1:5
%         rh_aero_map = RH_aero_map;
%         rh_aero_map(:,1) = rh_aero_map(:,1) + d_frh(f);
%         rh_aero_map(:,2) = rh_aero_map(:,2) + d_rrh(r);
%         car.aero_map.RH_aero_map = rh_aero_map;
%         RH_sweep{t}(f,r) = lap_sim(track_dir{t},car);
%         tLAP{t}(f,r) = RH_sweep{t}(f,r).lap_time;
%         set(hContour{t}, 'ZData', tLAP{t}); drawnow;
%     end
%     end
% end
tLap_plot = tLAP;
tLap_plot{2} = tLAP{4};
tLap_plot{3} = tLAP{2};
tLap_plot{4} = tLAP{3};

title_str = {'Austria', 'Germany', 'Lincoln', 'Michigan'};
figure('Color', [1,1,1]);
for i = 1:4
    subplot(2,2,i)
    contourf(FRH, RRH, tLap_plot{i}); 
    colormap jet; h = colorbar;
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 14);
    xlabel('$\Delta h_{F,0}$ (mm)', 'FontSize', 16, 'interpreter','latex');
    ylabel('$\Delta h_{R,0}$ (mm)', 'FontSize', 16, 'interpreter','latex');
    title(title_str{i}, 'FontSize', 18);
    ylabel(h, 'Lap-time (s)', 'FontSize', 16);
end
