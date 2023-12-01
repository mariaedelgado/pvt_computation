function plot_pvt(receiver_position, reference_position)

%--------------------------------------------------------------------------
% Plot the resulting PVT and compare to reference position given in the
% RINEX file.
% 
% Inputs:       receiver_position: array of the computed position of our
%               receiver in ECEF (x,y,z) for each epoch.
%--------------------------------------------------------------------------

lla_computed = ecef2lla([receiver_position.x_ecef(:), receiver_position.y_ecef(:), receiver_position.z_ecef(:)]);
lla_reference = ecef2lla([reference_position(1), reference_position(2), reference_position(3)]);

figure;
geoplot(lla_computed(:,1), lla_computed(:,2), Marker="o");
hold on;
geoplot(lla_reference(1), lla_reference(2), Marker="o", Color="red");
hold off;

end

