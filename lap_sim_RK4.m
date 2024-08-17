function [v, acc_X, acc_Y] = lap_sim_RK4(car, v0, gear0, ...
    acc_X0, acc_Y0, R, Yaw, brake_flag, h)
    m0 = car.m0;        A0 = car.A0;        m_dist = car.m_dist;
    l_car = car.l_car;  b_car = car.b_car;  h_cg = car.h_cg;
    tire_id = car.tire_id;
    p_train = car.powertrain;   engine = car.engine;
    rpm0 = find_rpm(v0, gear0, p_train);
    if brake_flag == 1; 
        h = -abs(h); 
    end
    % k1
    acc_X1 = calculate_acc(m0, A0, m_dist, l_car, b_car, h_cg, tire_id, ...
        Yaw, car.aero_map, brake_flag, v0, rpm0, acc_X0, acc_Y0, engine);
    k1 = acc_X1/v0; v1 = v0 + k1*h/2; rpm1 = find_rpm(v1, gear0, p_train);
    % k2
    acc_X2 = calculate_acc(m0, A0, m_dist, l_car, b_car, h_cg, tire_id, ...
        Yaw, car.aero_map, brake_flag, v1, rpm1, ...
        acc_X1, v1^2/abs(R), engine);
    k2 = acc_X2/v1; v2 = v0 + k2*h/2; rpm2 = find_rpm(v2, gear0, p_train);
    % k3
    acc_X3 = calculate_acc(m0, A0, m_dist, l_car, b_car, h_cg, tire_id, ...
        Yaw, car.aero_map, brake_flag, v2, rpm2, ...
        acc_X2, v2^2/abs(R), engine);
    k3 = acc_X3/v2; v3 = v0 + k3*h; rpm3 = find_rpm(v3, gear0, p_train);
    % k4
    acc_X4 = calculate_acc(m0, A0, m_dist, l_car, b_car, h_cg, tire_id, ...
        Yaw, car.aero_map, brake_flag, v3, rpm3, ...
        acc_X3, v3^2/abs(R), engine);
    k4 = acc_X4/v3;
    k = (k1 + 2*k2 + 2*k3 + k4)/6;
    acc_X = (acc_X1 + 2*acc_X2 + 2*acc_X3 + acc_X4)/6; % ???
    v = v0 + k*h;
    acc_Y = v^2/R;
    
    
    
function acc_X = calculate_acc(m0, A0, m_dist, l_car, b_car, h_cg, ...
    tire_id, Yaw, aero_map, brake_flag, v0, rpm0, acc_X, acc_Y, engine)
    rho = 1.225;    g = 9.8;
    grip_req_lat = abs(acc_Y)*m0*[1-m_dist, m_dist];
%     [CD, CL, AB] = AeroFunction(Yaw, aero_map);
    frh = 10; rrh = 10;
    for i = 1:3
    [CD, CL, AB] = AdvAeroFunction(Yaw, frh, rrh, aero_map);
    F_Z = ... [front left, front right, rear left, rear right]
        m0*g * [0.5*(1-m_dist), 0.5*(1-m_dist), 0.5*m_dist, 0.5*m_dist] + ...
        0.5*rho*A0*v0.^2*CL * ...
            [0.5*(1-AB), 0.5*(1-AB), 0.5*AB, 0.5*AB] + ...
        acc_X*m0*h_cg/l_car * [-0.5, -0.5, 0.5, 0.5] +...
        acc_Y*m0*h_cg/b_car/2 * ...
            [-0.5*(1-m_dist), 0.5*(1-m_dist), -0.5*m_dist, 0.5*m_dist];
    F_Z( F_Z < 0 ) = 0;
    frh = ( F_Z(1)+F_Z(2) )/(24.3*2); rrh = ( F_Z(3)+F_Z(4) )/(22.6*2);
    end
    
    mu = TireFunction(F_Z, tire_id);
    F_grip = F_Z.*mu;   grip_avl = [sum(F_grip(1:2)), sum(F_grip(3:4))];
    if brake_flag == 0
        if grip_avl(2) > grip_req_lat(2) && grip_avl(1) > grip_req_lat(1)
            F_X = sqrt(grip_avl(2)^2 - grip_req_lat(2)^2) - ...
                0.5*rho*A0*v0.^2*CD;
            p = EngineFunction(rpm0, engine);
            acc_X = min([F_X, p/v0 - 0.5*rho*A0*v0.^2*CD]) / m0;
        else
            F_X = 0; % -0.5*rho*A0*v0.^2*CD; ???
            acc_X = F_X / m0;
        end
    else
        F_X = - 0.5*rho*A0*v0.^2*CD;
        if  grip_avl(2)^2 > grip_req_lat(2)^2
            F_X = F_X - sqrt( grip_avl(2)^2 - grip_req_lat(2)^2 );
        end
        if  grip_avl(1)^2 > grip_req_lat(1)^2
            F_X = F_X - sqrt( grip_avl(1)^2 - grip_req_lat(1)^2 );
        end
        acc_X = F_X / m0;
    end