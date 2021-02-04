function [prox_P, dist_P, bone_length, V] = getJointCentresForBone(osimModel, bone_to_deform)

import org.opensim.modeling.*

% body of interest
cur_body = osimModel.getBodySet().get(bone_to_deform);

disp('---------------------');
disp(' COMPUTE BONE LENGTH ');
disp('---------------------');
disp(['Processing body: ', bone_to_deform])

% initialise model
si = osimModel.initSystem();

%% get proximal joint centre 
% body joint extraction
proxJoint = cur_body.getJoint();

% location in child
prox_loc = cur_body.getJoint().get_location;

% transform in MATLAB vectors
prox_P = [prox_loc.get(0), prox_loc.get(1), prox_loc.get(2)];
% NOTE: no need to check for CustomJoint here, as the child is not affected
% by the SpatialTransform, which moves the child wrt the parent.

%% get distal joint(s) centre(s)
% here the body of interest is parent
jointNameSet = getDistalJointNames(osimModel, bone_to_deform);

for nj = 1:length(jointNameSet)
    
    % get current joint
    cur_joint_name = jointNameSet{nj};
    distJoint = osimModel.getJointSet().get(cur_joint_name);
    
    % location in parent
    dist_loc = distJoint.get_location_in_parent;
    
    % offset from the spatial transform (in local body)
    % take into account the spatialTransform
    jointOffset = [0, 0, 0];
    if strcmp(char(distJoint.getConcreteClassName()), 'CustomJoint')
        localJointOffset = computeSpatialTransformTranslations(osimModel, distJoint);
        jointOffsetV3 = Vec3(localJointOffset(1), localJointOffset(2), localJointOffset(3));
        jointOffset = [jointOffsetV3.get(0), jointOffsetV3.get(1), jointOffsetV3.get(2)];
    end
    
    % move to body of interest
%     osimModel.getSimbodyEngine().transformPosition(si, distJoint.getBody(), jointOffsetV3, cur_body, jointOffsetV3);
    
    % sum the contributions
    dist_P = [dist_loc.get(0), dist_loc.get(1), dist_loc.get(2)];
    dist_P(nj,1:3) = dist_P + jointOffset;
    % lengths
    L(nj) = norm(prox_P-dist_P(nj,1:3));
end

%% compute length
% in case of multiple joint centre take the further, so all joints are
% transformed, if needed.
% Example: tibiofemoral and patellofemoral joints.

[bone_length, max_ind] = max(L);

% distal point
dist_P = dist_P(max_ind, :);

% compute axis versor
V = (dist_P-prox_P)/bone_length;

% display output
disp(['Proximal joint name  : ', char(proxJoint.getName())]);
disp(['Proximal joint centre: ', sprintf('%.2f %.2f %.2f', prox_P)]);
disp(['Distal joint name    : ', jointNameSet{max_ind}]);
disp(['Distal joint centre  : ', sprintf('%.2f %.2f %.2f', dist_P)]);
disp(['Total length of bone : ', sprintf('%.2f %.2f %.2f', bone_length), ' m']);

end