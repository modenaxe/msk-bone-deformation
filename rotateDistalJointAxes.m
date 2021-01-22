% ASSUMPTION is that the rotation will always be measured distally!
% finds the distal joints connected to a body
function osimModel = rotateDistalJointAxes(osimModel,segment,aTorsionAxisString, aTorsionAngle)

%%%%%%%%  Settings %%%%%%%%%%%%%%%%%%
% clear;clc
% % initializing
% ModelFileName = 'gait2392_simbody.osim';
% segment = 'femur_r';
% TorsionAxis = 'y';
% TorsionPointsDeg = [0, 100];% degrees
% LengthPoints = [0, 0.42];
% % Import model
% import org.opensim.modeling.*
% osimModel = Model(ModelFileName);
%%%%%%%%%%%%%%%%%%%%5555


import org.opensim.modeling.*

% ASSUMPTION is that the rotation will always be measured distally!
% finds the distal joints connected to a body

% this will be used when the rot matrix will be updated with the axis
aTorsionAxis = getAxisIndex(aTorsionAxisString);


% it gets the jointset
modelJointSet = osimModel.getJointSet();
N_j = modelJointSet.getSize();
n_d = 1;
for n_j = 0:N_j-1
    
    % it gets the parent body name for the joint
    jointParentName = char(modelJointSet.get(n_j).getParentBody().getName());
    
    % if it matches with the body of interest it stores the name of the
    % joint
    if strcmp(jointParentName,segment)
        DistalJointSetNames(n_d) = {char(modelJointSet.get(n_j).getName())};
        display(['Distal joint of ',segment, ' is ', char(modelJointSet.get(n_j).getName())]);
        n_d = n_d + 1;
    end
end


% get the spatial transform for the joints identified at the previous step
for n_d = 1:size( DistalJointSetNames,2);
    
    % joint name for the current iteration
    cur_joint_name = DistalJointSetNames{n_d};
    
    % gets the joint
    bodyJoint = modelJointSet.get(cur_joint_name);
    
    %%%%%%%%%%% PARTS THAT NEEDS IMPROVEMENT %%%%%%%%%%%%
    % update distal segment
    orientation = Vec3;
    bodyJoint.getOrientation(orientation);
    if (orientation.get(0)~=0.0 || orientation.get(1)~= 0.0 || orientation.get(2)~=0.0)
        display('Method works only if child/distal body has orientation 0 0 0 wrt the parent.');
        error('Development needed: build the pose matrix from the orientation angle and multiply with the rotation matrix derived from the given angle. The ricalculate the orientation.');
    end
    new_orientation = Vec3(0);
    new_orientation.set(aTorsionAxis-1, -aTorsionAngle/180*pi);
    bodyJoint.setOrientation(new_orientation);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % downcast to custom joint (necessary to extract SpatialTransform)
    customJ = CustomJoint.safeDownCast(bodyJoint);
    
    % get spatial transform
    jointSpatialTransf = customJ.getSpatialTransform();
    
    % apply desired torsion
    tors = aTorsionAngle/180*pi;
    
    % torsion matrix TO BE UPDATE WITH AXIS
    M = [cos(tors) 0 sin(tors); 0 1 0; -sin(tors) 0 cos(tors)];
    
    % go through the axes of the transform
    for n_axis = 0:5
        
        % get the axis identified by the index
        TransAxis = jointSpatialTransf.getTransformAxis(n_axis);
        
%         % checks
%         jointSpatialTransf.print('SpatialTrans.xml');

        % initialize
        curr_axis_v = Vec3;
        upd_axis_v = Vec3;
        
        % extract the axis values
        TransAxis.getAxis(curr_axis_v);
        curr_axis = [curr_axis_v.get(0),curr_axis_v.get(1),curr_axis_v.get(2)]';
        
        % update the axis with the rotated values
        upd_axis = M*curr_axis;
        upd_axis_v.set(0,upd_axis(1))
        upd_axis_v.set(1,upd_axis(2))
        upd_axis_v.set(2,upd_axis(3))
        
        % if you want to visualize
%         display(['axis transformed from ',num2str(curr_axis(1)),' ',num2str(curr_axis(2)),' ',num2str(curr_axis(3)),...
%             ' to ', num2str(upd_axis(1)),' ', num2str(upd_axis(2)),' ', num2str(upd_axis(3))]);
        
        % update axis
        TransAxis.setAxis(upd_axis_v);
%         TransAxis.print('checkAxis.osim')
    end
    
end
% bodyJoint.print('checkknee.osim')
% osimModel.print('rotatedKnee.osim')

