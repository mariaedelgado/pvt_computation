function [xs_corrected, ys_corrected, zs_corrected] = apply_sagnac_effect_correction(xs, ys, zs, reference_ecef)

% Constants definition
c = 299792458;  % m/s
we = 7.2921151467e-5; % angular speed of Earth rotation [rad/s]

% Following equation 5.11 from ESA book:
% Compute the rotation angle to be applied
sat_pos = [xs, ys, zs];
dt = norm(sat_pos - reference_ecef)/c;
rotation_angle = we*dt;

% Apply transformation matrix
R3 = [cos(rotation_angle)   sin(rotation_angle) 0;
      -sin(rotation_angle)  cos(rotation_angle) 0;
               0                    0           1];

pos_corrected = R3*[xs; ys; zs];
xs_corrected = pos_corrected(1);
ys_corrected = pos_corrected(2);
zs_corrected = pos_corrected(3);

end

