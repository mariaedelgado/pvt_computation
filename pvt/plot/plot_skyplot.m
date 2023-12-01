function plot_skyplot(receiver_pos, satellite_pos_list)

%--------------------------------------------------------------------------
% 
% Inputs:       - receiver_pos: coordinates of our receiver in [x,y,z] format.
%               - satellite_pos_list: datetime structure containing the x,
%                 y, z positions of each satellites per each epoch.
%-------------------------------------------------------------------------

% Define arrays to store the position in azimuth, elevation
satellite_list = unique(satellite_pos_list.SatelliteID);
epoch_list = unique(satellite_pos_list.Time);

% Define skyplot figure
sp = skyplot([], [], MaskElevation=5);
satellite_names = compose('G%02d', satellite_list);

for t = 1 : length(epoch_list)

    index_t = find(satellite_pos_list.Time == epoch_list(t));
    timetable_t = satellite_pos_list(index_t,:);
 
    [az, el, vis] = lookangles(receiver_pos, ...
                               [timetable_t.x_ecef ...
                                timetable_t.y_ecef ...
                                timetable_t.z_ecef], ...
                                10);
   
    set(sp, AzimuthData = az(vis), ElevationData = el(vis), ...
        LabelData = satellite_names(vis));
    drawnow limitrate

end
        

end

