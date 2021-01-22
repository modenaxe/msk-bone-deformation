% function that get the centre of a joint named aJointName included in a 
% certain osimModel. The options to get the position of the joint centre
% are:
% refFrame = 'parent', which will give the coordinate in parent
% 'child' will give the coordinate of the joint ref syst in child
% 'ground' will calculate the position of the joint centre taking into
% account the translation possibly introduced by the spatial transform e.g.
% at the knee

function jointCentreCoordMatlab = getJointCentreCoord(osimModel, aJointName, refFrame)

% opens the nominal model
import org.opensim.modeling.*

if ~osimModel.getJointSet.getIndex(aJointName)
    error(['The joint ',aJointName,' is not included in the model'])
end

% gets jointset
jointOfInterest = osimModel.getJointSet().get(aJointName);

%Initializing the value of joint centre placeholder
% for OpenSim versions before 3.1
% JointCoord = ArrayDouble.createVec3([0.0, 0.0, 0.0]);% placeholder
JointCoord = Vec3;

% Gets the coordinates in parent of the joint of interest
switch refFrame
    case 'parent'
        JointCoord = jointOfInterest.getLocationInParent(JointCoord);
        
        %         JointLocalCoord = ArrayDouble.getValuesFromVec3(JointCoord);
    case 'child'
        JointCoord = jointOfInterest.getLocationInChild();
        %         JointLocalCoord = ArrayDouble.getValuesFromVec3(JointCoord);
        
    case 'ground'
        si = osimModel.initSystem();
        
        % get ground body
        ground = osimModel.getGroundBody();
        
        % get the parent body
        parentBody = jointOfInterest.getParentBody();
        
        % get joint coords in parent body
        jointOfInterest.getLocationInParent(JointCoord);
        
        % get the Spatial Transform
        customJ = CustomJoint.safeDownCast(jointOfInterest);
        jointSpatialTransf = customJ.getSpatialTransform();
        t1 = jointSpatialTransf.get_translation1().getValue(si);
        t2 = jointSpatialTransf.get_translation2().getValue(si);
        t3 = jointSpatialTransf.get_translation3().getValue(si);
        JointCoordMat = [JointCoord.get(0), JointCoord.get(1), JointCoord.get(2)]+[t1,t2,t3];
        JointCoord = Vec3(JointCoordMat(1),JointCoordMat(2),JointCoordMat(3));
        
        % transform to ground
        osimModel.getSimbodyEngine().transformPosition(si,parentBody,JointCoord,ground,JointCoord);
        %         JointLocalCoord = ArrayDouble.getValuesFromVec3(JointCoord);
    otherwise
        error('You need to specify if the coordinate of the joint centre are desired in ''ground'', ''parent'' or ''child'' frame.')
end

jointCentreCoordMatlab = [JointCoord.get(0), JointCoord.get(1), JointCoord.get(2)];
