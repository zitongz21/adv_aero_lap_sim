car.m0 = 280;                       % mass, kg
car.A0 = 1;                         % frontal area
car.h_cg = 0.335;                   % CG height, m
car.tire_id = 3;                    % tire compound ID
car.l_car = 1.55;                   % wheelbase
car.b_car = 1.2;                    % track
car.m_dist = 0.54;                  % mass distribution (rear percentage)
car.yaw_scale = 0.75;               % scaling factor for yaw angle
% aero_map
car.aero_map.C_L_beta =  0.00;      
car.aero_map.C_D_beta =  0.00;
car.aero_map.RH_aero_map = ...      % ride-height aero-map
    [0, 0, 2.983, 1.5213];
% powertrain
car.rpm_lim = 12700;
car.engine = 'gsx_r600';
car.powertrain.gear_ratio = ...     % powertrain, gear ratio
    [2.7850; 2.0520; 1.7140; 1.5000; 1.3480; 1.2080];
car.powertrain.final_drive = 38/11;
car.powertrain.primary_drive = 76/36;
car.powertrain.r_wheel = 0.228;     % powertrain, r_wheel


car_simplified = car;
car_simplified.h_cg = 0;
car_simplified.m_dist = 0.5;

fsg_simplified = lap_sim('\tracks\fsae_germany_optimumG.xlsx', ...
    car_simplified);
fsg_load_transfer = lap_sim('\tracks\fsae_germany_optimumG.xlsx', car);

figure('Color', [1,1,1]);
ax1 = subplot(2,1,1);
plot(data_ol(:,3), data_ol(:,1)); hold on;
plot(fsg_simplified.S, fsg_simplified.V*3.6, 'LineWidth', 1.5);
xlim(ax1, [0,1500]); ylim(ax1, [0,120]);
set(ax1, 'XTick', 0:100:1500, 'FontName', 'Times New Roman', ...
    'FontSize', 12);
xlabel(ax1, 'sLap (m)', 'FontSize', 16);
ylabel(ax1, 'V (km/h)', 'FontSize', 16);
box(ax1,'on'); grid(ax1,'on');
legend({'OptimumLap', 'h_{CG} = 0 (m), 50:50'}, 'FontSize', 16, ...
    'location', 'southeast');

ax2 = subplot(2,1,2);
plot(data_ol(:,3), data_ol(:,1)); hold on;
plot(fsg_load_transfer.S, fsg_load_transfer.V*3.6, 'LineWidth', 1.5);
xlim(ax2, [0,1500]); ylim(ax2, [0,120]);
set(ax2, 'XTick', 0:100:1500, 'FontName', 'Times New Roman', ...
    'FontSize', 12);
xlabel(ax2, 'sLap (m)', 'FontSize', 16);
ylabel(ax2, 'V (km/h)', 'FontSize', 16);
box(ax2,'on'); grid(ax2,'on');
legend({'OptimumLap', 'h_{CG} = 0.335 (m), 46:54'}, 'FontSize', 16, ...
    'location', 'southeast');