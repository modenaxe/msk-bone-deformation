%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% given a body, return all joints of which that body is parent.
function distalJointSetNames = getDistalJointNames(osimModel, bodyName)

% extract all joints
modelJointSet = osimModel.getJointSet();
N_j = modelJointSet.getSize();

% counter of distal joints
n_d = 1;

for n_j = 0:N_j-1
    
    % get parent body name for each joint
    % OpenSim 3.3
    if getOpenSimVersion()<4.0 
        jointParentName = char(modelJointSet.get(n_j).getParentBody().getName());
    else
        % OpenSim 4.x
        jointParentName = char(modelJointSet.get(n_j).getParentFrame().findBaseFrame().getName());
    end
    
    % when matching with bodyName save name
    if strcmp(jointParentName, bodyName)
        % save it
        distalJointSetNames(n_d) = {char(modelJointSet.get(n_j).getName())};
        n_d = n_d + 1;
    end
end

% display(['Distal joint of ',bodyName, ' is ', char(modelJointSet.get(n_j).getName())]);

end