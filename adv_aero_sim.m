% advanced_aero_sim
car.m0 = 280;                   % mass, kg
car.A0 = 1;                     % frontal area
car.h_cg = 0.335;               % CG height, m
car.tire_id = 3;                % tire compound ID
car.l_car = 1.55;               % wheelbase
car.b_car = 1.2;                % track
car.m_dist = 0.52;              % mass distribution (rear percentage)
car.yaw_scale = 0.75;           % scaling factor for yaw angle
car.aero_map.C_L_beta = -0.02;
car.aero_map.C_D_beta =  0.03;
car.aero_map.RH_aero_map = [...
    25	20	2.585 1.50; ...
    25	10	2.442 1.50; ... 
    20	20	3.355 1.50; ...
    15	20	2.870 1.50; ...
    15	15	2.754 1.50; ...
    10	20	3.422 1.50; ...
    25	15	2.594 1.50; ...
    20	15	2.776 1.50; ...
    20	10	2.680 1.50; ...
    15	10	3.451 1.50; ...
    10	10	3.600 1.50; ...
    ];

% powertrain
car.rpm_lim = 12700;
car.engine = 'gsx_r600';
car.powertrain.gear_ratio = ...     % powertrain, gear ratio
    [2.7850; 2.0520; 1.7140; 1.5000; 1.3480; 1.2080];
car.powertrain.final_drive = 38/11;
car.powertrain.primary_drive = 76/36;
car.powertrain.r_wheel = 0.228;     % powertrain, r_wheel

adv_aero_germany = lap_sim('\tracks\fsae_germany_optimumG.xlsx',car);

car_601 = car;  car_601.engine = 'gsx_r601';
adv_aero_germany_601 = lap_sim('\tracks\fsae_germany_optimumG.xlsx',car_601);


car_no_ge = car; 
car_no_ge.aero_map.RH_aero_map = [0,0,3.60,1.50];
no_ge_germany = lap_sim('\tracks\fsae_germany_optimumG.xlsx',car_no_ge);

car_const_aero = car_no_ge;
car_const_aero.aero_map.C_L_beta = 0;
car_const_aero.aero_map.C_D_beta = 0;
const_aero_germany = lap_sim('\tracks\fsae_germany_optimumG.xlsx',...
    car_const_aero);

figure('Color', [1,1,1]);
subplot(2,1,1);
plot(const_aero_germany.S, const_aero_germany.V, 'LineWidth', 0.8);
hold on; grid on;
plot(no_ge_germany.S, no_ge_germany.V, 'LineWidth', 1.2);
set(gca, 'XTick', 0:100:1500)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('sLap (m)', 'FontSize', 16); ylabel('vCar (km/h)', 'FontSize', 16)
legend({'$C_{L/D} = \mathrm{const}$', '$C_{L/D} = f(\beta)$'}, ...
    'FontSize', 14, 'interpreter', 'latex');

subplot(2,1,2);
plot(adv_aero_germany.S, adv_aero_germany.V, 'LineWidth', 1.2);
hold on; grid on;
plot(no_ge_germany.S, no_ge_germany.V, 'LineWidth', 0.8);
set(gca, 'XTick', 0:100:1500)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('sLap (m)', 'FontSize', 16); ylabel('vCar (km/h)', 'FontSize', 16)
legend({'$C_{L/D} = f(\beta, h)$', '$C_{L/D} = f(\beta)$'}, ...
    'FontSize', 14, 'interpreter', 'latex');