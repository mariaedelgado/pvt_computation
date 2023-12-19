% Add paths and define observables and navigation input files
addpath('data\')
addpath('pvt\')
addpath('rinex\')
obs_file = "TLSE00FRA_R_20232700000_01D_30S_GO.rnx";
nav_file = "BRDC00IGS_R_20232692330_25H_GN.rnx";
reference_position_lla = [43.5607, 1.4809, 208.8147]; % from RINEX OBS
reference_position_ecef = lla2ecef(reference_position_lla);

% Process the RINEX files
[data_obs, data_nav] = process_rinex(obs_file, nav_file);

% Compute the receiver position using the Iterative Least Squares Estimator
epoch_list = unique(data_obs.Time);
[receiver_position] = compute_receiver_position(data_obs, data_nav, epoch_list(1:200), reference_position_ecef);
