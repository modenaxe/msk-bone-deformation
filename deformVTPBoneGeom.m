% by default it consider the torsion zero at the origin of the segment and 
% the torsion increases along the specified axis
% TO DO: define the possibility of choose a point where the deformation
% starts
function deformVTPBoneGeom(vtp_file, aTorsionAxisString, aTorsionGrad,deformed_vtp_suffix)

%%%%%%%%  SCRIPT %%%%%%%%%%%%%%%%%%
% clear;clc
% % initializing
% vtp_file = 'femur.vtp';
% LengthPoints = [0, 0.42];
% TorsionPointsDeg = [0, 100];% degrees
% direction = 2; %y
% defines a torsion gradient
% TorsionPoints = TorsionPointsDeg/180*pi;
% aTorsionGrad = diff(TorsionPoints)/diff(LengthPoints);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% converting the axis in the index used later
aTorsionAxis = getAxisIndex(aTorsionAxisString);

% reads the original vtp file
[ normals, points] = readVTPfile_v2(vtp_file);

% Deforms points and normals
for n = 1:size(points,1)
    tors = aTorsionGrad*abs(points(n,aTorsionAxis));
    % Matrix of torsion around the defined axis
    M = [cos(tors) 0 sin(tors); 0 1 0; -sin(tors) 0 cos(tors)];
    % New points and axis
    new_points(n,:) = (M*points(n,:)')';
    new_normals(n,:) = (M*normals(n,:)')';
end

% writes the deformed geometry
updateVTPGeometry_v2(vtp_file,new_normals,new_points,deformed_vtp_suffix)

% informs the user of the new geometry
[vtp_path,name,ext] = fileparts(vtp_file);
display(['Deformed ',name,ext,' geometry!']);
display(['Collect geometry at ',vtp_path]);
