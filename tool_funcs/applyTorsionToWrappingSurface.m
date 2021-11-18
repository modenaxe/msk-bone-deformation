%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Axel Kousshou                                      %
%    Author:   Axel Kousshou,  2021                                       %
% ----------------------------------------------------------------------- %

function osimModel = applyTorsionToWrappingSurface(osimModel, aSegmentName, aTorsionAxisString, torsion_angle_func_rad)

import org.opensim.modeling.*

disp('------------------------------');
disp(' ADJUSTING WRAPPING SURFACES ');
disp('------------------------------');

% check if segment is included in the model
if osimModel.getBodySet().getIndex(aSegmentName)<0
    error('The specified segment is not included in the OpenSim model')
end

% converting the axis in the index used later
[RotMat, axis_ind] = getAxisRotMat(aTorsionAxisString);

% body of interest
cur_body = osimModel.getBodySet().get(aSegmentName);

% wrapping surfaces size
N_wrap_surfaces = cur_body.getWrapObjectSet.getSize();

% % state now required
% state = osimModel.initSystem();

ntm = 1;
processed_wrap_surfaces='';
% loop through the wrapping surfaces
for n_wrap_surfaces = 0:N_wrap_surfaces-1
    
    % current wrapping surfaces
    curr_wrap = cur_body.getWrapObject(cur_body.getWrapObjectSet.get(n_wrap_surfaces).getName);

    % keep track
    processed_wrap_surfaces=append(processed_wrap_surfaces,'  ',char(cur_body.getWrapObjectSet.get(n_wrap_surfaces).getName));
    ntm=ntm+1;
    
    % current wrapping translation
    wrapSurfLocVec3 =  curr_wrap.get_translation();
    wrapSurfLocCoords = [wrapSurfLocVec3.get(0),wrapSurfLocVec3.get(1),wrapSurfLocVec3.get(2)];
    
    % compute torsion metric for the wrap surfaces
    TorsRotMat = RotMat(torsion_angle_func_rad(wrapSurfLocCoords(axis_ind)));
    
    % compute new wrap surfaces coordinates
    new_wrapSurfLocCoords = (TorsRotMat*wrapSurfLocCoords')';

    % setting the wrap surfaces translation as Vec3
    new_wrapSurfLocCoords_v3 = Vec3(new_wrapSurfLocCoords(1), new_wrapSurfLocCoords(2), new_wrapSurfLocCoords(3));
    curr_wrap.set_translation(new_wrapSurfLocCoords_v3);
    
    % current wrapping rotation
    wrapSurfRotVec3 =  curr_wrap.get_xyz_body_rotation();
    wrapSurfRotCoords = [wrapSurfRotVec3.get(0),wrapSurfRotVec3.get(1),wrapSurfRotVec3.get(2)];

    jointRotMat = orientation2MatRot(wrapSurfRotCoords);
    newJointRotMat =  jointRotMat * TorsRotMat;
    new_Orientation  = computeXYZAngleSeq(newJointRotMat);
    new_wrapSurfRot = Vec3(new_Orientation(1), new_Orientation(2), new_Orientation(3));
    
    % setting the wrap surfaces rotation as Vec3
    curr_wrap.set_xyz_body_rotation(new_wrapSurfRot);
 
end

disp(['Processed ', num2str(ntm-1), ' wrapping surfaces:'])
disp(char(processed_wrap_surfaces))
end