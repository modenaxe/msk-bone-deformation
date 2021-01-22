% by default it consider the torsion zero at the origin of the segment and 
% the torsion increases along the specified axis
% TO DO: define the possibility of choose a point where the deformation
% starts

% defaults deforms viapoints
function osimModel = deformMuscleAttachments(aOsimModel,aSegmentName, aTorsionAxisString, aTorsionGrad, deformViapoint)

import org.opensim.modeling.*

% TO DO 
% CHECKS ON INPUTS
% AXIS DEFINE AS 'x','y'
% default for viapoints
if nargin == 4
    deformViapoint = 'yes';
end
% initialization
osimModel = aOsimModel;
segment = aSegmentName;
viapoint = deformViapoint;
% converting the axis in the index used later
aTorsionAxis = getAxisIndex(aTorsionAxisString);

% extracting muscleset
Muscles = osimModel.getMuscles();
N_mus = Muscles.getSize();

% loop through the muscles
for n_mus = 0:N_mus-1
    % current muscles
    curr_Mus = Muscles.get(n_mus);
    % extracting the path
    currentPathPointSet = curr_Mus.getGeometryPath().getPathPointSet();
    % number of points
    N_p = currentPathPointSet.getSize();
    % looping through the points of the PathPointSet
    for n_p = 0:N_p-1
        % Body attached to each point of the PathPointSet
        attachBodyName = char(currentPathPointSet.get(n_p).getBody().getName());
        % if attachment is the first of the last of the set then it is an
        % attachment on bone.
        if strcmp(attachBodyName,segment) && (n_p==0 || n_p==N_p-1)
            musLocationVec3 =  currentPathPointSet.get(n_p).getLocation();
            % OpenSim before 3.0 works with the following syntax
            %             musLocation_java = ArrayDouble.getValuesFromVec3(musLocationVec3);
            %             musCoord = [musLocation_java.getitem(0),musLocation_java.getitem(1),musLocation_java.getitem(2)];
            musCoord = [musLocationVec3.get(0),musLocationVec3.get(1),musLocationVec3.get(2)];
            
            % calculating torsion based on the length
            %             tors = interp1(Bonelength,aTorsionGrad_vec,abs(musCoord(2)));
            tors = aTorsionGrad*abs(musCoord(aTorsionAxis));
            % Matrix of torsion around the y axis
            M = [cos(tors) 0 sin(tors); 0 1 0; -sin(tors) 0 cos(tors)];
            % New muscle attachment
            new_Attach = (M*musCoord')';
            % setting the muscle PathPointSet
            currentPathPointSet.get(n_p).setLocationCoord(0,double(new_Attach(1)))
            currentPathPointSet.get(n_p).setLocationCoord(1,double(new_Attach(2)))
            currentPathPointSet.get(n_p).setLocationCoord(2,double(new_Attach(3)))
            % If the user decides not to include viapoints no more points
            % are searched
            if strcmp(viapoint,'no')
                break
            end
        end
        % same code as above but saving the viapoints
        if strcmp(attachBodyName,segment) && (n_p~=0 && n_p~=N_p-1) && strcmp(viapoint,'yes')
            musLocationVec3 =  currentPathPointSet.get(n_p).getLocation();
            musLocation_java = ArrayDouble.getValuesFromVec3(musLocationVec3);
            musCoord = [musLocation_java.getitem(0),musLocation_java.getitem(1),musLocation_java.getitem(2)];
            % Save attachment coordinates in a structure with field names
            %             curr_tors = interp1(Bonelength,aTorsionGrad_vec,musCoord(3));
            %             t = curr_tors;
            tors = aTorsionGrad*abs(musCoord(aTorsionAxis));
            M = [cos(tors) 0 sin(tors); 0 1 0; -sin(tors) 0 cos(tors)];
            new_Attach = (M*musCoord')';
            currentPathPointSet.get(n_p).setLocationCoord(0,new_Attach(1))
            currentPathPointSet.get(n_p).setLocationCoord(1,new_Attach(2))
            currentPathPointSet.get(n_p).setLocationCoord(2,new_Attach(3))
        end
        
    end
end

end