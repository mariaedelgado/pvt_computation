function [covariance, bias] = compute_pvt_statistics(receiver_position, reference_position)

%--------------------------------------------------------------------------
% Compute statistics of the results of the receiver position. Covariance
% and bias of the x-y components are going to be computed as well as
% plotted.
% 
% Inputs:       receiver_position: array of the computed position of our
%               receiver in ECEF (x,y,z) for each epoch.
%
% Output:       - covariance
%               - bias
%--------------------------------------------------------------------------

covariance = cov(receiver_position);

xy_computed = sqrt(power(receiver_position.x_ecef(:), 2) + ...
                   power(receiver_position.y_ecef(:),2));
xy_reference = sqrt(power(reference_position(1), 2) + ...
                    power(reference_position(2),2));
bias_per_epoch = xy_computed - xy_reference;
bias = mean(bias_per_epoch);

end

