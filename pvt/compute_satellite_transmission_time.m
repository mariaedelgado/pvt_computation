function [week_number, gps_sow_tx] = compute_satellite_transmission_time(epoch, pseudorange, sat_clock_offset)
%--------------------------------------------------------------------------
% 
%--------------------------------------------------------------------------

% Constant definitions
c = 299792458;  % m/s

gps_ref_epoch = datetime(1980,1,6,0,0,0);
delta_time = epoch - gps_ref_epoch; delta_time.Format = 's';

week_number = floor(seconds(delta_time)/(7*86400));
t_rx_sec = seconds(rem(delta_time,seconds(7*86400)));

gps_sow_tx = t_rx_sec - pseudorange/c - sat_clock_offset;

end

