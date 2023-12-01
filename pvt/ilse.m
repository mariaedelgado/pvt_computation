function [position, dop] = ilse(ephemeris, pseudoranges, epoch)
%--------------------------------------------------------------------------
% Output:   - ephemeris
%           - position [x y z cdt] in ECEF
%           - dop [gdop, hdop, vdop]
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

while true

    % Iterate through the list of satellites
    for s = 1 : number_of_sats

        ephemeris_s = ephemeris(s,:);

        % Obtain transmission time at the satellite and compute its
        % position at that epoch
        sat_clock_offset = compute_satellite_clock_offset(epoch, ephemeris_s);
        [wn, gps_sow_tx] = compute_satellite_transmission_time(epoch, pseudoranges(s), sat_clock_offset);
        [xs, ys, zs, E] = compute_gps_sat_pos(ephemeris_s, wn, gps_sow_tx);

        % Compute the bias introduced by the satellite clock, including the
        % relativity correction
        relativity_correction = -2*(sqrt(G*sqrt(ephemeris_s.sqrtA))/power(c,2))*ephemeris_s.Eccentricity*sin(E);
        clock_offset_correction = c*(sat_clock_offset + relativity_correction);

        % Compute h(x0) matrix
        h(s) = sqrt(power(x0(1) - xs, 2) + ...   % (x0-xs)^2
               power(x0(2) - ys, 2) + ...        % (y0-ys)^2
               power(x0(3) - zs, 2)) + ...       % (z0-zs)^2
               x0(4) - clock_offset_correction;  % c*dt_receiver - c*dt_satellite;
 
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

gdop = H_inv(1,1) + H_inv(2,2) + H_inv(3,3);
hdop = H_inv(1,1) + H_inv(2,2);
vdop = H_inv(3,3);
dop = [gdop, hdop, vdop];

end

