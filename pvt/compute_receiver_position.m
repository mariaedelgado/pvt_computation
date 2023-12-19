function [receiver_position] = compute_receiver_position(data_obs, data_nav, epoch_list, reference_ecef)
%--------------------------------------------------------------------------
% Compute the position of the satellites in the given time interval. The
% algorithm for its computation has been extracted from the book GNSS Data
% Processinf Volume I: Fundamentals and Algorithms section 3.3.1.
% 
% Inputs:       - data_obs: timetable containing the pseudoranges.
%               - data_nav: timetable containing the parameters to compute
%               the satellite positions at a given time.                   
%               - epoch_list: if given, list of epochs to be computed
%               - reference_lla: reference receiver position in LLA
%
% Output:       - receiver_position (x, y, z, cdt)
%--------------------------------------------------------------------------

% Obtain the list of epochs and satellites present throughout the
% observables file

if isempty(epoch_list)
    epoch_list = unique(data_obs.Time);
end

% Iterate each epoch and compute the position of our receiver
for t = 1 : length(epoch_list)
    
    % Obtain all the captured pseudoranges in epoch t. We will obtain a
    % matrix of size {n_vis_sats_at_t x 1}
    index_obs = find(data_obs.Time == epoch_list(t));
    pseudoranges = data_obs.C1C(index_obs);

    % Obtain the ephemeris to be used for each satellite at this epoch
    satellite_pos_t = zeros(length(index_obs), 3);
 
    for s = 1 : length(index_obs)
        svid = data_obs.SatelliteID(index_obs(s));
        index_nav = find(data_nav.SatelliteID == svid & ...
                     data_nav.Time <= epoch_list(t));

        if isempty(index_nav)
            continue;
        end

        ephemeris(s,:) = data_nav(index_nav(end),:);
    end

    % Apply the Iterative Least Squares estimator to obtain the position of
    % our receiver at epoch t
    [pos(t,:), P_enu] = ilse(ephemeris, pseudoranges, epoch_list(t), reference_ecef);

    % Obtain GDOP, HDOP, VDOP from the covariance matrix
    dop(t,1) = P_enu(1,1) + P_enu(2,2) + P_enu(3,3);
    dop(t,2) = P_enu(1,1) + P_enu(2,2);
    dop(t,3) = P_enu(3,3);
end

% Define output timetable
receiver_position = timetable(epoch_list, pos(:,1), pos(:,2), pos(:,3), ...
                    dop(:,1), dop(:,2), dop(:, 3), ...  
                    VariableNames = ["x_ecef", "y_ecef", "z_ecef", "dop", "hvop", "vdop"]);

end

