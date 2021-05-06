%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function osimModel = applyTorsionToJoints(osimModel, bone_to_deform, aStringAxis, torsion_angle_func_rad)

import org.opensim.modeling.*

% get rotation matrix as implicit function for given deformation
[aRotMatFunc, axis_ind] = getAxisRotMat(aStringAxis);

disp('------------------');
disp(' ADJUSTING JOINTS ');
disp('------------------');

%% rotate the proximal joint
% OpenSim 3.3
if getOpenSimVersion()<4.0
    proxJoint = osimModel.getBodySet.get(bone_to_deform).getJoint();
    
    % initialise orientation and location (in body of interest)
    orientation = Vec3(0);
    location    = Vec3(0);
    
    % extract proximal joint params
    proxJoint.getOrientation(orientation);
    proxJoint.getLocation(location);
else
    % OpenSim 4.x
    proxJoint = getBodyJoint(osimModel, bone_to_deform, 0);
    
    % extract proximal joint params
    location    = proxJoint.get_frames(1).get_translation();
    orientation = proxJoint.get_frames(1).get_orientation();
end

disp(['* ', char(proxJoint.getName()), ' (', char(proxJoint.getConcreteClassName()),')']);
disp(['  ', bone_to_deform, ' is CHILD.'])
disp(['    orientation in child   : ', sprintf('%.2f %.2f %.2f', [orientation.get(0), orientation.get(1), orientation.get(2)])]);
disp(['    location in child      : ', sprintf('%.2f %.2f %.2f', [location.get(0),    location.get(1),    location.get(2)])] )

% compute the torsion matrix for proximal joint
XYZ_location_vec =  [location.get(0), location.get(1), location.get(2)];

% NOTE: no need to check for CustomJoint here, as the child is not affected
% by the SpatialTransform, which moves the child wrt the parent.
tors_angle = torsion_angle_func_rad(XYZ_location_vec(axis_ind));
torsion_RotMat = aRotMatFunc(tors_angle);
disp(['    torsion of ', num2str(tors_angle*180/pi), ' deg applied.'])

% compute new location in child
new_Loc =  XYZ_location_vec * torsion_RotMat';
newLocation = Vec3(new_Loc(1), new_Loc(2), new_Loc(3));

% compute new orientation in child
XYZ_orient_vec = [orientation.get(0), orientation.get(1), orientation.get(2)];
jointRotMat = orientation2MatRot(XYZ_orient_vec);
newJointRotMat =  jointRotMat * torsion_RotMat;
new_Orientation  = computeXYZAngleSeq(newJointRotMat);
newOrientation = Vec3(new_Orientation(1), new_Orientation(2), new_Orientation(3));

% assign params
% OpenSim 3.3
if getOpenSimVersion()<4.0
    proxJoint.setOrientation(newOrientation);
    proxJoint.setLocation(newLocation)
else
    % OpenSim 4.x
    proxJoint.get_frames(1).set_orientation(newOrientation);
    proxJoint.get_frames(1).set_translation(newLocation);
end

%% update distal joints
jointNameSet = getDistalJointNames(osimModel, bone_to_deform);

% here the body is parent of the joint
for nj = 1:length(jointNameSet)
    
    % initialise
    orientation = Vec3(0);
    location    = Vec3(0);
    
    % get current joint
    cur_joint_name = jointNameSet{nj};
    curDistJoint = osimModel.getJointSet.get(cur_joint_name);
    
    % extract joint params
    if getOpenSimVersion()<4.0
        curDistJoint.getOrientationInParent(orientation);
        curDistJoint.getLocationInParent(location);
    else
        orientation = curDistJoint.get_frames(0).get_orientation();
        location    = curDistJoint.get_frames(0).get_translation();
    end
    
    disp(['* ', cur_joint_name, ' (', char(curDistJoint.getConcreteClassName()),')']);
    disp(['  ', bone_to_deform, ' is PARENT.'])
    disp(['    orientation in parent  : ', sprintf('%.2f %.2f %.2f', [orientation.get(0), orientation.get(1), orientation.get(2)])]);
    disp(['    location in parent     : ', sprintf('%.2f %.2f %.2f', [location.get(0),    location.get(1),    location.get(2)])] )
    
    % compute the torsion matrix
    XYZ_location_vec =  [location.get(0), location.get(1), location.get(2)];
    
    % take into account the spatialTransform
    jointOffset = [0 0 0];
    if strcmp(char(curDistJoint.getConcreteClassName()), 'CustomJoint')
        % offset from the spatial transform
        % this is in parent, which is the bone of interest
        jointOffset = computeSpatialTransformTranslations(osimModel, curDistJoint);
        disp(['    spatialTransf-transl   : ', sprintf('%.2f %.2f %.2f', jointOffset)]);
        disp(['    location in parent (initSystem) : ', sprintf('%.2f %.2f %.2f', jointOffset)]);
    end
    
    % if CustomJoint add the translation from the CustomJoint
    XYZ_location_torsion = XYZ_location_vec+jointOffset;
    
    % actually compute the matrix
    tors_angle = torsion_angle_func_rad(XYZ_location_torsion(axis_ind));
    torsion_RotMat = aRotMatFunc(tors_angle);
    disp(['    torsion of ', num2str(tors_angle*180/pi), ' deg applied.'])
    
    % compute new location in parent
    new_Loc =  XYZ_location_vec * torsion_RotMat';
    newLocationInParent = Vec3(new_Loc(1), new_Loc(2), new_Loc(3));
    
    % compute new orientation in parent
    XYZ_orient_vec = [orientation.get(0), orientation.get(1), orientation.get(2)];
    jointRotMat = orientation2MatRot(XYZ_orient_vec);
    newJointRotMat =  jointRotMat * torsion_RotMat;
    new_OrientationInPar  = computeXYZAngleSeq(newJointRotMat);
    newOrientationInParent = Vec3(new_OrientationInPar(1), new_OrientationInPar(2), new_OrientationInPar(3));
    
    % assign new parameters
    if getOpenSimVersion()<4.0
        curDistJoint.setOrientationInParent(newOrientationInParent);
        curDistJoint.setLocationInParent(newLocationInParent)
    else
        curDistJoint.get_frames(0).set_orientation(newOrientationInParent);
        curDistJoint.get_frames(0).set_translation(newLocationInParent);
    end
end

end