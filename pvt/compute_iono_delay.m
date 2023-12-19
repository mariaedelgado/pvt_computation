function [iono_delay_m] = compute_iono_delay(epoch, lat, lon, elevation, azimuth)

% Constants definition
c = 299792458;  % m/s
Re = 6378000; % Earth radius in m
h = 350000; % Height for GPS satellites

% Following equations of the Klobuchar model for the iono from sections
% 5.4.1.2.1 of ESA book:

% 1. Calculate the Earth-centered angle
earth_centered_angle = pi/2 - elevation - asin((Re*cos(elevation))/(Re + h));
% earth_centered_angle = 0.0137/(rad2sc(elevation)+0.11) - 0.022; % ????

% 2. Compute the latitude of the IPP
lat_IPP = asin(sin(lat)*cos(earth_centered_angle) + ...
          cos(lat)*sin(earth_centered_angle)*cos(azimuth));

% 3. Compute the longitude of the IPP
lon_IPP = lon + (sin(azimuth)/(cos(lat_IPP)));

% 4. Find the geomagnetic latitude of the IPP. We define [lat_P, lon_P] as
% the coordinated of the geomagnetic pole
lat_P = 78.3; % degrees
lon_P = 291.0; % degrees
geomagnetic_lat_IPP = asin(sin(lat_IPP)*sin(lat_P) + ...
                      cos(lat_IPP)*cos(lat_P)*cos(lon_IPP - lon_P));

% 5. Find the local time at the IPP
gps_ref_epoch = datetime(1980,1,6,0,0,0);
t_gps = epoch - gps_ref_epoch; t_gps.Format = 's';
t = 43200*lon_IPP/pi + t_gps;

if t >= 86400
    t = t - 86400;
elseif t < 86400
    t = t + 86400;
end

% 6. Compute the amplitude of the ionospheric delay
% From the navigation data:
% GPSA   2.5146E-08  2.2352E-08 -1.1921E-07 -1.1921E-07       IONOSPHERIC CORR    
% GPSB   1.3312E+05  0.0000E+00 -2.6214E+05  2.6214E+05       IONOSPHERIC CORR    
an = [2.5146E-08, 2.2352E-08, -1.1921E-07, -1.1921E-07];
Ai = 0;

for n = 1 : 4
    Ai = Ai + an(n)*power(geomagnetic_lat_IPP/pi, n); % s
end

if Ai < 0
    Ai = 0;
end

% 7. Compute the period of the ionospheric delay
bn = [1.3312E+05, 0.0000E+00, -2.6214E+05, 2.6214E+05];
Pi = 0;

for n = 1 : 4
    Pi = Pi + bn(n)*power(geomagnetic_lat_IPP/pi, n); % s
end

if Pi < 72000
    Pi = 72000;
end

% 8. Compute the phase of the ionospheric delay
Xi = (2*pi*(t - 50400))/(Pi); % rad

% 9. Compute the slant factor (ionospheric mapping function)
F = power(1 - power((Re*cos(elevation))/(Re + h), 2) , -0.5);

% 10. Compute the ionospheric time delay, given in seconds referred to GPS
% L1 frequency
if abs(Xi) < pi/2
    I1 = (5E-9 + Ai*cos(Xi)) * F;
elseif abs(Xi) >= pi/2
    I1 = 5E-9 * F;

iono_delay_m = I1*c;
end



