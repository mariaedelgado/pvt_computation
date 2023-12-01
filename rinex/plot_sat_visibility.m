function plot_sat_visibility(data_obs, epoch_list)

%--------------------------------------------------------------------------
% Plot of the satellites visibility in two different figures: the number of
% satellites in view at each epoch and the availability of each satellite
% during the given time interval.
% 
% Inputs:       - data_obs: observables data retrieved by reading the
%                 observables file with rinexread.
%               - epoch_list: list of the epochs to be plotted (in datetime
%                 format).
%
% Output:       Plot
%--------------------------------------------------------------------------

n_max_svid_gps = 32;

% If no input epoch list, the method will plot all the epochs in the file
if isempty(epoch_list)
    epoch_list = unique(data_obs.Time);
end

%% Plot 1: number of satellites per epoch
number_of_sats_per_epoch = histcounts(data_obs.Time(:, 1), [epoch_list; epoch_list(end)+1]);
average = mean(number_of_sats_per_epoch);
disp(average);

figure;
subplot(4,2,1:2);
plot(epoch_list, number_of_sats_per_epoch);
title('Number of satellites in view');
xlabel('Epoch');
ylabel('Number of satellites');

%% Plot 2: satellite visibility
for s = 1:n_max_svid_gps    

    index_list = find(data_obs.SatelliteID == s);

    subplot(4,2,[3 4 5 6 7 8]);
    scatter(data_obs.Time(index_list), data_obs.SatelliteID(index_list), 0.5);

    hold on;
end

satellite_list = [1:1:32];
satellite_names = compose('G%02d', satellite_list);
title('Satellite visibility');
xlabel('Epoch');
ylabel('PRN');
set(gca, 'YTick', 1:n_max_svid_gps, 'YTickLabel', satellite_names, 'FontSize', 8);
hold off;

end


