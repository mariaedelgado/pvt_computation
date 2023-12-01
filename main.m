% Add paths and define observables and navigation input files
addpath('data\')
addpath('plots\')
obs_file = "TLSE00FRA_R_20232700000_01D_30S_GO.rnx";
nav_file = "BRDC00IGS_R_20232692330_25H_GN.rnx";
approx_receiver_pos = [43.5607, 1.4809, 208.8147]; % from RINEX OBS

% Process the RINEX files
[data_obs, data_nav] = process_rinex(obs_file, nav_file);

% Compute the receiver position using the Iterative Least Squares Estimator
[receiver_position] = compute_receiver_position(data_obs, data_nav, []);
