track = {   '\tracks\fsae_germany_optimumG.xlsx', ...
            '\tracks\fsae_austria_optimumG.xlsx', ...
            '\tracks\fsae_lincoln_optimumG.xlsx', ...
            '\tracks\fsae_michigan_optimumG.xlsx'   };

car.m0 = 280;                   % mass, kg
car.A0 = 1;                     % frontal area
car.h_cg = 0.335;               % CG height, m
car.tire_id = 3;                % tire compound ID
car.l_car = 1.55;               % wheelbase
car.b_car = 1.2;                % track
car.m_dist = 0.52;              % mass distribution (rear percentage)
car.yaw_scale = 0.8;            % scaling factor for yaw angle

% aero map: Yaw, C_L, C_D
aero_map_const = ...
    [0,3.6,1.5; 5,3.6,1.5; 10,3.6,1.5; 20,3.6,1.5; 25,3.6,1.5;];
aero_map_linear_1 = [0:5:25; 3.2-1.2/25*(0:5:25); 1.2+0.4/25*(0:5:25)];
aero_map_linear_1 = aero_map_linear_1';
aero_map_linear_2 = [0:5:25; 3.4-1.6/25*(0:5:25); 1.3+0.5/25*(0:5:25)];
aero_map_linear_2 = aero_map_linear_2';

aero_scale = 0.7:0.05:1.3;

for i = 12:13
    for j = 1:13
        car.aero_map = aero_map_const .* ...
            ( [1;1;1;1;1;] * [1, aero_scale(i), aero_scale(j)] );
        austria(i,j) = lap_sim('\tracks\fsae_austria_optimumG.xlsx', car);
        germany(i,j) = lap_sim('\tracks\fsae_germany_optimumG.xlsx', car);
        lincoln(i,j) = lap_sim('\tracks\fsae_lincoln_optimumG.xlsx', car);
        michigan(i,j)= lap_sim('\tracks\fsae_michigan_optimumG.xlsx',car);
        disp(j);
    end
end
% 
for i = 1:13
    for j = 1:13
        lap_time{1}(i,j) = austria(i,j).lap_time;
        lap_time{2}(i,j) = germany(i,j).lap_time;
        lap_time{3}(i,j) = lincoln(i,j).lap_time;
        lap_time{4}(i,j) = michigan(i,j).lap_time;
    end
end

figure('Color', [1,1,1]);
for i = 1:4
    subplot(2,2,i)
    contourf([1;1;1;1]*aero_scale(3:5)*1.2, ...
        aero_scale(1:4)'*[1,1,1]*3.2, lap_time{i}(1:4,3:5)); 
    colormap jet; h = colorbar;
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 14);
end