function [data_obs, data_nav] = process_rinex(observation_file, navigation_file)

%--------------------------------------------------------------------------
% Parse the RINEX OBS file and return a timetable with the columns of
% interest for the analysis and later processing of the data (Time,
% SatelliteID, C1C, D1C, L1C, S1C).
% 
% Inputs:       - observation_file: filepath to the RINEX observation file.
%
% Outputs:      - data_obs: timetable containing only the data of interest
%                 the observation file.
%--------------------------------------------------------------------------

% Read and clean the observables data
data_obs_raw = rinexread(observation_file);
data_obs = data_obs_raw.GPS(:, [1 4 8 12 18]);

% Read the navigation data
data_nav_raw = rinexread(navigation_file);
data_nav = data_nav_raw.GPS;

end

