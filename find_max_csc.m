function v = find_max_csc(R, Yaw, car, v_max)
rho = 1.225;    g = 9.8;    mu0 = 1.0;  C_y = 0;
m0 = car.m0;        A0 = car.A0;        m_dist = car.m_dist;
l_car = car.l_car;  b_car = car.b_car;  h_cg = car.h_cg;
tire_id = car.tire_id;
[C_D, C_L, AB] = AdvAeroFunction(Yaw, 10, 10, car.aero_map); % AeroFunction(Yaw, car.aero_map);
v0 = 0;
v = sqrt(mu0 * m0 * g ./ ...
        (sqrt(  (m0./abs(R)+0.5*rho*C_y*A0).^2+(0.5*rho*C_D*A0).^2 ) ...
            - 0.5*mu0*rho*C_L*A0) );

if ~isreal(v)
    v = 40;
else
    
while abs( (v-v0)/v) >=  0.02
    v0 = v;
    acc_Y = v0^2/R;
    F_Z = ... [front left, front right, rear left, rear right]
        m0*g * [0.5*(1-m_dist), 0.5*(1-m_dist), 0.5*m_dist, 0.5*m_dist] + ...
        0.5*rho*A0*v0.^2*C_L * ...
            [0.5*(1-AB), 0.5*(1-AB), 0.5*AB, 0.5*AB] + ...
        acc_Y*m0*h_cg/b_car/2 * ...
            [-0.5*(1-m_dist), 0.5*(1-m_dist), -0.5*m_dist, 0.5*m_dist];
    F_Z (F_Z<0) = 0;
    frh = ( F_Z(1)+F_Z(2) )/(24.3*2); rrh = ( F_Z(3)+F_Z(4) )/(22.6*2);
    [C_D, C_L, AB] = AdvAeroFunction(Yaw, frh, rrh, car.aero_map);
        
    mu = TireFunction(F_Z, tire_id);
    F_grip = F_Z.*mu;
    v = min([   sqrt(   sum(F_grip(3:4))/( m0*m_dist     )*abs(R) ), ...
                sqrt(   sum(F_grip(1:2))/( m0*(1-m_dist) )*abs(R) )
            ]);
    v = 0.8 * v + 0.2 * v0;
    if v>v_max; v = v_max; end
end

end



