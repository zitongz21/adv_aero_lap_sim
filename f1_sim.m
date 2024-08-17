% https://www.f1technical.net/forum/viewtopic.php?t=25999

car.m0 = 650;                       % mass, kg
car.A0 = 1;                         % frontal area
car.h_cg = 0.35;                    % CG height, m
car.tire_id = 5;                    % tire compound ID, const. 1.50;
car.l_car = 3.58;                   % wheelbase
car.b_car = 1.6;                    % track
car.m_dist = 0.56;                  % mass distribution (rear percentage)
car.yaw_scale = 0.8;                % scaling factor for yaw angle
% aero_map
car.aero_map.C_L_beta = -0.02;      
car.aero_map.C_D_beta =  0.02;
car.aero_map.RH_aero_map = ...      % ride-height aero-map
    [0, 0, 4.8, 1.6];

car.engine = 'f1_2012_generic';     % engine specification
car.powertrain.gear_ratio = ...     % powertrain, gear ratio
    [18.00; 14.75; 12.25; 10.25; 9.00; 7.90; 7.00;];
car.powertrain.final_drive = 1;     % powertrain, final_drive
car.powertrain.primary_drive = 1;   % powertrain, primary_drive
car.powertrain.r_wheel = 0.35;      % powertrain, primary_drive

f1_spa_linear = lap_sim('\tracks\f1_spa.xlsx', car);

car_const = car;
car_const.aero_map.C_L_beta = 0.0;      
car_const.aero_map.C_D_beta = 0.0;
f1_spa_const = lap_sim('\tracks\f1_spa.xlsx', car_const);

