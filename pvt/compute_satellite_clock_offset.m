function [satellite_clock_offset] = compute_satellite_clock_offset(epoch, ephemeris)

gps_ref_epoch = datetime(1980,1,6,0,0,0);
delta_time = epoch - gps_ref_epoch; delta_time.Format = 's';

t_rx_sec = seconds(rem(delta_time,seconds(7*86400)));

satellite_clock_offset = ephemeris.SVClockBias + ...
                         ephemeris.SVClockDrift*(t_rx_sec - ephemeris.Toe) + ...
                         ephemeris.SVClockDriftRate*power(t_rx_sec - ephemeris.Toe, 2);
end

