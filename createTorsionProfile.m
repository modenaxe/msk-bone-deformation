function [torsion_angle_func_rad, torsion_doc_string] = createTorsionProfile(LengthProfilePoints, TorsionProfilePointsDeg, torsionAxis)

disp('--------------------------');
disp(' CREATING TORSION PROFILE ');
disp('--------------------------');

% get axis indices
[~, axis_ind] = getAxisRotMat(torsionAxis);

disp(['Axis of torsion: ', upper(torsionAxis)]);
disp('Profile (Tors Point, Coordinate)')

% pointProfile on axis of interest
axis_LengthProfilePoints = LengthProfilePoints(:, axis_ind)';

for np = 1:length(TorsionProfilePointsDeg)
    disp([num2str(TorsionProfilePointsDeg(np)), '   deg     |------> ' num2str(axis_LengthProfilePoints(np))]);
end

% create implicit function for calculating torsion at a certain quote
torsion_angle_func_rad = @(L)torsionProfile(L, axis_LengthProfilePoints, TorsionProfilePointsDeg);

% round degrees of torsion at joints
torsion_bounds_deg = round([torsion_angle_func_rad(axis_LengthProfilePoints(1)) torsion_angle_func_rad(axis_LengthProfilePoints(2))]*180/pi);

% strings to use for naming models
torsion_doc_string = ['Prox',num2str(torsion_bounds_deg(1)),'Dist',num2str(torsion_bounds_deg(2)),'Deg'];

end

