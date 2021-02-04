%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %

function SpatialTransformTrans = computeSpatialTransformTranslations(osimModel, aCustomJoint)

import org.opensim.modeling.*

% double check if the joint is effectively a CustomJoint
if strcmp(char(aCustomJoint.getConcreteClassName()), 'CustomJoint')
    
    % initialize
    si = osimModel.initSystem();
    
    % get the Spatial Transform
    customJ = CustomJoint.safeDownCast(aCustomJoint);
    
    % get the translations at state si
    % spatial position of Child in Parent as a function of coordinates.
    jointSpatialTransf = customJ.getSpatialTransform();
    t1 = jointSpatialTransf.get_translation1().getValue(si);
    t2 = jointSpatialTransf.get_translation2().getValue(si);
    t3 = jointSpatialTransf.get_translation3().getValue(si);
    
    % ignoring rotations for now
%     r1 = jointSpatialTransf.get_rotation1().getValue(si);
%     r2 = jointSpatialTransf.get_rotation2().getValue(si);
%     r3 = jointSpatialTransf.get_rotation3().getValue(si);
    
    % export the translation vector
    SpatialTransformTrans = [t1,t2,t3];
    
else
    disp('The provided joint is not a CustomJoint. No SpatialTransform offset.')
    SpatialTransformTrans = [0, 0, 0];
end

