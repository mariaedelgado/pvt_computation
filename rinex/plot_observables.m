function plot_observables(data_obs, type_of_measurement)

%--------------------------------------------------------------------------
% Plot the selected type of measurement from the observables data for GPS
% only (at the moment).
% 
% Input Variable
%   data_obs:               timetable with data obtained from the RINEX OBS
%   type_of_measurement:    string with observation time descriptor (e.g.
%                           C1C, D1C, L1C,...) as defined in rinexread.
%
%--------------------------------------------------------------------------

n_max_svid_gps = 32;
svid_names = [];
iter = 1;

for n = 1

    timetable_svid_n = data_obs(:,1)==n;
    if (height(timetable_svid_n) == 0)
        continue;
    end

    table_svid_n = timetable2table(timetable_svid_n, 'ConvertRowTimes',false);
    index_svid_n = table2array(table_svid_n);

    data_svid_n = data_obs(index_svid_n, :);
    svid_names{iter} = sprintf('G%02d', data_svid_n.SatelliteID(1:1));

    plot(data_svid_n, 'Time', type_of_measurement, 'LineWidth', 0.5);
    hold on;

    iter = iter + 1;

end

title('Plot of observation ', type_of_measurement);
legend(svid_names);
xlabel('Time');
if (type_of_measurement(1) == 'C')
    ylabel('Meters');
elseif (type_of_measurement(1) == 'D')
    ylabel('Hz');
elseif (type_of_measurement(1) == 'L')
    ylabel('Full cycles');
end

hold off;

end

