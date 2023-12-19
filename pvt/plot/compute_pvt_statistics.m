function compute_pvt_statistics(receiver_position, reference_position)

%--------------------------------------------------------------------------
% Compute statistics of the results of the receiver position. Covariance
% and bias of the x-y components are going to be computed as well as
% plotted.
% 
% Inputs:       receiver_position: array of the computed position of our
%               reference position in ECEF (x,y,z) for each epoch.
%
% Output:       - covariance
%               - bias
%--------------------------------------------------------------------------

% Convert coordinates from ECEF to ENU. We will take the reference of ENU
% coordinate frame as the reference receiver position.
lla_ref = ecef2lla(reference_position);

wgs84 = wgs84Ellipsoid('meter');
[e, n, u] = ecef2enu(receiver_position.x_ecef(:), ...
               receiver_position.y_ecef(:), ...
               receiver_position.z_ecef(:), ...
               lla_ref(1), ...
               lla_ref(2), ...
               lla_ref(3), ...
               wgs84);

[e_ref, n_ref, u_ref] = ecef2enu(reference_position(1), ...
                   reference_position(2), ...
                   reference_position(3), ...
                   lla_ref(1), ...
                   lla_ref(2), ...
                   lla_ref(3), ...
                   wgs84);

%% Bias computation
mean_3d = mean([e,n,u]);
mean_en = mean_3d(:,1:2);
mean_u = mean_3d(:,3);

bias = mean_3d - [e_ref, n_ref, u_ref];

%% Covariance
pvt = [receiver_position.x_ecef(:), receiver_position.y_ecef(:), receiver_position.z_ecef(:)];
covariance_3d = cov(pvt);
cov_en = covariance_3d(1:2,1:2);
cov_u = covariance_3d(3,3);

%% Plot
% Plot of variance and covariance for East-North components
figure();
scatter(e, n, "blue");
xlabel("East (m)");
ylabel("North (m)");
hold on;
scatter(e_ref, n_ref,"red")
hold on;
ellipsoid(mean_en', cov_en,"r");

% Plot of variance and covariance for Up component
figure();
histogram(u, 100);
xline(u_ref, "color", "r");
xline(mean_u - sqrt(cov_u), "color", "r");
xline(mean_u + sqrt(cov_u), "color", "r");
xlabel("Up (m)");
ylabel("Number of samples in bin");

end

