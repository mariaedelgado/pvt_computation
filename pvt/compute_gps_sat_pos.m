function [x, y, z, Ek] = compute_gps_sat_pos(ephemeris, week, gps_sow)

%--------------------------------------------------------------------------
% Compute the position for a given satellite at a given epoch using the
% broadcast ephemeris.
% 
% Inputs:       - ephemeris: row of a data_nav object with the parameters
%                 to compute the position coordinates.
%               - epoch: datetime in which the position is to be computed
%
% Output:       - [x, y, z]: ECEF coordinates of the satellite at epoch.
%               - Ek: eccentric anomaly. We return it to use it in the
%                 clock offset correction.
%--------------------------------------------------------------------------

% Constants
G = 6.67384e-11; %Gravitational constant [m3 kg-1 s-2]
M = 5.972e+24; %Earth mass [kg]
w_e = 7.2921151467e-5; %Angular speed of Earth rotation [rad/s]

% 1. Compute the tk from the ephemeris reference epoch toe (expressed in
% GPS seconds of the week. We must convert first our input epoch to GPS
% seconds of the week.

% gps_ref_epoch = datetime(1980,1,6,0,0,0);
% delta_time = epoch - gps_ref_epoch; delta_time.Format = 's';
% 
% week_number = floor(seconds(delta_time)/(7*86400));
% gps_seconds = seconds(rem(delta_time,seconds(7*86400)));

if week ~= ephemeris.GPSWeek
    return;
end

tk = gps_sow - ephemeris.Toe;

if tk > 302400
    tk = tk - 604800;
elseif tk < -302400
    tk = tk + 604800;
end

% 2. Compute the mean anomaly for tk.
a = power(ephemeris.sqrtA,2);
Mk = ephemeris.M0 + ...
    ((sqrt(G*M)/sqrt(power(a,3))) + ephemeris.Delta_n)*tk; 

% 3. Solve (iteratively) the Kepler equation using Newton's method. It uses
% the derivative of the proposed equation.
E0  = Mk;
E = E0 - (E0 - ephemeris.Eccentricity*sin(E0)- Mk)/(1 - ephemeris.Eccentricity*cos(E0));
while (abs(E-E0) > 10^(-7))
	E0 = E;
	E = E0 - (E0 - ephemeris.Eccentricity*sin(E0) - Mk)/(1 - ephemeris.Eccentricity*cos(E0));
end

Ek = E;

% 4. Compute true anomaly:
numerator_arctan = sqrt(1 - power(ephemeris.Eccentricity, 2))*sin(Ek);
denominator_arctan = cos(Ek) - ephemeris.Eccentricity;
vk = atan2(numerator_arctan, denominator_arctan);

% 5. Compute the argument of latitude
angle_radians = 2*(ephemeris.omega + vk);

uk = ephemeris.omega + vk + ...
     ephemeris.Cuc*cos(angle_radians) + ...
     ephemeris.Cus*sin(angle_radians);

% 6. Compute the radial distance considering the corrections
rk = a*(1 - ephemeris.Eccentricity*cos(Ek)) + ...
     ephemeris.Crc*cos(angle_radians) + ...
     ephemeris.Crs*sin(angle_radians);

% 7. Compute the inclination of the orbital plane
ik = ephemeris.i0 + ephemeris.IDOT*tk + ...
     ephemeris.Cic*cos(angle_radians) + ...
     ephemeris.Cis*sin(angle_radians);

% 8. Compute the longitude of the ascending node with respect to Greenwich
lon_k = ephemeris.OMEGA0 + ...
        (ephemeris.OMEGA_DOT - w_e)*tk - ...
        w_e*ephemeris.Toe;
   
% 9. Compute the coordinates in the TRS frame (rotate uk, ik and lon_k)
R1_ik = [1     0         0;
         0  cos(-ik)  sin(-ik);
         0 -sin(-ik)  cos(-ik)]; % function of -ik

R3_lonk = [ cos(-lon_k) sin(-lon_k) 0;
           -sin(-lon_k) cos(-lon_k) 0;
                0            0      1]; % function of -lon_k
R3_uk = [ cos(-uk) sin(-uk) 0;
         -sin(-uk) cos(-uk) 0;
             0        0     1]; % function of -uk

xyz = R3_lonk*R1_ik*R3_uk*[rk; 0; 0];
x = xyz(1,1);
y = xyz(2,1);
z = xyz(3,1);

end

