function [position, P_enu] = ilse(ephemeris, pseudoranges, epoch, reference_ecef)
%--------------------------------------------------------------------------
% Output:   - position: receiver position in ECEF frame (x, y, z)
%           - P_enu: covariance matrix
%--------------------------------------------------------------------------

% Parameter and vector definition
c = 299792458;  % m/s
G = 6.67384e-11; %Gravitational constant [m3 kg-1 s-2]

% Definition of arrays
number_of_sats = length(pseudoranges);
position = zeros(4, 1);   % [x y z cdt]
x0 = zeros(4, 1);  % [x y z cdt] with initial conditions set to 0

dx = zeros(4, 1); 
dz = zeros(4, 1);     % dz = z - h(x0)
h = zeros(number_of_sats, 1);
H = zeros(number_of_sats, 4);

dop = zeros(1,3);

% Convert reference position to LLA for some of the computations
reference_lla = ecef2lla(reference_ecef);

while true

    % Iterate through the list of satellites
    for s = 1 : number_of_sats

        ephemeris_s = ephemeris(s,:);

        % Obtain transmission time at the satellite and compute its
        % position at that epoch
        sat_clock_offset = compute_satellite_clock_offset(epoch, ephemeris_s);
        [wn, gps_sow_tx] = compute_satellite_transmission_time(epoch, pseudoranges(s), sat_clock_offset);
        [xs, ys, zs, E] = compute_gps_sat_pos(ephemeris_s, wn, gps_sow_tx);
        [xs, ys, zs] = apply_sagnac_effect_correction(xs, ys, zs, reference_ecef);

        % Compute the bias introduced by the satellite clock, including the
        % relativity correction
        relativity_correction = -2*(sqrt(G*sqrt(ephemeris_s.sqrtA))/power(c,2))*ephemeris_s.Eccentricity*sin(E);
        clock_offset_correction = c*(sat_clock_offset + relativity_correction);

        % Compute ionospheric delay. We compute the correction at the true
        % position of the receiver for simplicity.
        sat_pos = ecef2lla([xs, ys, zs]);
        wgs84 = wgs84Ellipsoid;
        [azimuth, elevation, slant] = geodetic2aer(reference_lla(1), reference_lla(2), reference_lla(3), ...
                                                   sat_pos(1), sat_pos(2), sat_pos(3), ...
                                                   wgs84);
        iono_delay_m = compute_iono_delay(epoch, reference_lla(1), reference_lla(2), elevation, azimuth);
     
        % Compute h(x0) matrix
        h(s) = sqrt(power(x0(1) - xs, 2) + ...   % (x0-xs)^2
               power(x0(2) - ys, 2) + ...        % (y0-ys)^2
               power(x0(3) - zs, 2)) + ...       % (z0-zs)^2
               x0(4) - clock_offset_correction + ... % c*dt_receiver - c*dt_satellite;
               iono_delay_m;                     % ionospheric delay in meters
 
        % Compute Jacobian matrix
        H(s,:) = [(x0(1) - xs)/pseudoranges(s), ...
                  (x0(2) - ys)/pseudoranges(s), ...
                  (x0(3) - zs)/pseudoranges(s), ...
                  1];
    end

    % Compute dz = z - h(x0). The resulting matrix will have size = length(satellite_list)
    dz = pseudoranges - h;
    
    % Compute (H_T*H)^-1*H_T and finally, obtain the estimated dx = (H_T*H)^-1 * H_T
    H_T = transpose(H);
    H_inv = inv(H_T*H);
    dx = H_inv*H_T*dz;
    
    % Update x0
    x0 = x0 + dx;

    % If dx is converging, go out of the loop
    if norm(dx) < 10-8
        break;
    end

end

position = x0;

% Additionally, we know that P_ecef = inv(H_T*H) describes the covariance
% in the ECEF frame. We convert it to the ENU frame to obtain it in the 
% geodetic frame for statistical means.

P_ecef = H_inv(1:3,1:3);    % We keep the upper part to get a 3x3 matrix
R_ecef_enu = [-sin(reference_lla(1)) -sin(reference_lla(2))*cos(reference_lla(1)) cos(reference_lla(2))*cos(reference_lla(1));
               cos(reference_lla(1)) -sin(reference_lla(2))*sin(reference_lla(1)) cos(reference_lla(2))*sin(reference_lla(1));
                    0                          cos(reference_lla(2))                        sin(reference_lla(2))];
P_enu = transpose(R_ecef_enu)*P_ecef*R_ecef_enu;

end

