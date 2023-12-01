function plot_cn0(data_obs, satellite_list, epoch_list)

%--------------------------------------------------------------------------
% Plots the CN0 for a given observation file, compared to the pseudorange
% results. It will automatically plot all epochs and all the satellites if
% no list is given at the input.
%
% Inputs:       - data_obs: observables data retrieved by reading the
%                 observables file with rinexread.
%               - satellite_list: list of the satellites to be plotted ([1,
%                 2, 3, 4]
%               - epoch_list: list of the epochs to be plotted (in datetime
%                 format).
%
% Output:       Plot
%--------------------------------------------------------------------------

% If no input satellite list, the method will plot all the satellites in
% the file
if isempty(satellite_list)
    satellite_list = unique(data_obs.SatelliteID);
end

% If no input epoch list, the method will plot all the epochs in the file
if isempty(epoch_list)
    epoch_list = unique(data_obs.Time);
end

number_of_satellites = length(satellite_list);
number_of_epochs = length(epoch_list);

figure;

for s = 1 : number_of_satellites
    
    % Define the vectors in which we will store C1C and CN0 for the
    % satellite with the length of the total number of epochs.
    c1c_vector = NaN(number_of_epochs, 1);
    cn0_vector = NaN(number_of_epochs, 1);

    % Retrieve the indexes where satellite 's' appears in the observables.
    % From it, we obtain the C1C and CN0 in the epochs in which the
    % satellite is available.
    index_list = find(data_obs.SatelliteID == satellite_list(s));

    epochs_s = data_obs.Time(index_list);
    c1c_values_s = data_obs.C1C(index_list);
    cn0_values_s = data_obs.S1C(index_list);

    % Iterate the number of epochs in which the satellite is present and
    % add the values in the index corresponding to the epoch in epoch_list.
    for e = 1 : length(epochs_s)
        pos_epoch_list = find(epoch_list == epochs_s(e));
        c1c_vector(pos_epoch_list) = c1c_values_s(e);
        cn0_vector(pos_epoch_list) = cn0_values_s(e);
    end

    % Plot
    subplot(2,1,1);
    plot(epoch_list, c1c_vector/1000);
    title('C1C');
    xlabel('Epoch');
    ylabel('Pseudorange (km)');
    hold on;

    subplot(2,1,2);
    plot(epoch_list, cn0_vector);
    title('CN0');
    xlabel('Epoch');
    ylabel('dbHz');
    hold on;

end

% Generate legend
satellite_names = compose('G%02d', satellite_list);
subplot(2,1,1);
legend(satellite_names);
subplot(2,1,2);
legend(satellite_names);

hold off;

end

