%-------------------------------------------------------------------------%
%    Copyright (c) 2025 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@unsw.edu.au                                     %
% ----------------------------------------------------------------------- %
function osimModel = applyTorsionToMuscleAttachments(osimModel, aSegmentName, aTorsionAxisString, torsion_angle_func_rad)

import org.opensim.modeling.*

% default: deform viapoints (legacy option)
deformViapoint = 'yes';

disp('------------------------------');
disp(' ADJUSTING MUSCLE ATTACHMENTS ');
disp('------------------------------');

% check if segment is included in the model
if osimModel.getBodySet().getIndex(aSegmentName)<0
    error('The specified segment is not included in the OpenSim model')
end

% converting the axis in the index used later
[RotMat, axis_ind] = getAxisRotMat(aTorsionAxisString);

% extracting muscleset
Muscles = osimModel.getMuscles();
N_mus = Muscles.getSize();
processed_muscles = '';
ntm = 1;

% state now required
state = osimModel.initSystem();

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
        
        % skip the point if viapoints are not be deformed
        if strcmp(deformViapoint,'no') && (n_p~=0 || n_p~=N_p-1)
            continue
        end
        
        % Body attached to each point of the PathPointSet
        attachBodyName = char(currentPathPointSet.get(n_p).getBody().getName());
        
        if strcmp(attachBodyName, aSegmentName)
            
%              disp(['processing ', char(curr_Mus.getName())]);
            
            % keep track 
            if max(strcmp(char(curr_Mus.getName()), processed_muscles))==0
                processed_muscles{ntm} = char(curr_Mus.getName());
                ntm = ntm + 1;
            end
            
            % point coordinates
            % OpenSim 3.3
            if getOpenSimVersion()<4.0 
                musAttachLocVec3 =  currentPathPointSet.get(n_p).getLocation();
            else
                % OpenSim 4.x
                musAttachLocVec3 =  currentPathPointSet.get(n_p).getLocation(state);
            end
            
            curr_pathpoint_class  = char(currentPathPointSet.get(n_p).getConcreteClassName());
            
            if strcmp(curr_pathpoint_class, 'PathPoint') || strcmp(curr_pathpoint_class, 'ConditionalPathPoint')
                
                % convert to Matlab var
                musAttachLocCoords = [musAttachLocVec3.get(0),musAttachLocVec3.get(1),musAttachLocVec3.get(2)];
                
                % compute torsion metric for the attachment point
                TorsRotMat = RotMat(torsion_angle_func_rad(musAttachLocCoords(axis_ind)));
                
                % compute new muscle attachment coordinates
                new_musAttachLocCoords = (TorsRotMat*musAttachLocCoords')';%musCoord * M'
                
                if getOpenSimVersion()<4.0 %OpenSim 3.3
                    currentPathPointSet.get(n_p).setLocationCoord(0,double(new_musAttachLocCoords(1)))
                    currentPathPointSet.get(n_p).setLocationCoord(1,double(new_musAttachLocCoords(2)))
                    currentPathPointSet.get(n_p).setLocationCoord(2,double(new_musAttachLocCoords(3)))
                else %OpenSim 4.x
                    % getPathPoint returns an AbstractPathPointSet. Requires
                    % downcasting
                    eval(['currentPathPoint = ',curr_pathpoint_class,'.safeDownCast(currentPathPointSet.get(n_p));'])
                    % setting the muscle PathPointSet as Vec3
                    new_musAttachLocCoords_v3 = Vec3(new_musAttachLocCoords(1), new_musAttachLocCoords(2), new_musAttachLocCoords(3));
                    currentPathPoint.set_location(new_musAttachLocCoords_v3);
                end
            elseif  strcmp(curr_pathpoint_class, 'MovingPathPoint')
                
                currentPathPoint = MovingPathPoint.safeDownCast(currentPathPointSet.get(n_p));
                %disp('Function on MovingPathPoint not supported. Please extend the bone deformation tool.')
                %continue
                
                % extract the pqthpoints
                px = currentPathPoint.get_x_location();
                py = currentPathPoint.get_y_location();
                pz = currentPathPoint.get_z_location();
                
                % extract functions
                fx = SimmSpline.safeDownCast(px);
                fy = SimmSpline.safeDownCast(py);
                fz = SimmSpline.safeDownCast(pz);
                coord_set = {'x','y','z'};
                
                for nc=1:3
                    cur_coord = coord_set{nc};
                    % extract joint angles (x) from coordinate of interest
                    eval(['Np = f',cur_coord,'.getX.getSize();']);
                    eval(['Xpoints = f',cur_coord,'.getX();']);
                    
                    for np=0:Np-1
                        % curr joint angle
                        cur_angle = Xpoints.get(np);
                        % compute point coordinates at that joint angle
                        Px = fx.calcValue(Vector(1,cur_angle));
                        Py = fy.calcValue(Vector(1,cur_angle));
                        Pz = fz.calcValue(Vector(1,cur_angle));
                        % build a point
                        musAttachLocCoords = [Px, Py, Pz];
                        % compute torsion metric for the attachment point
                        TorsRotMat = RotMat(torsion_angle_func_rad(musAttachLocCoords(axis_ind)));
                        % compute new muscle attachment coordinates
                        new_musAttachLocCoords = (TorsRotMat*musAttachLocCoords')';%musCoord * M'
                        % assign to spline
                        eval(['f',cur_coord,'.setY(np, new_musAttachLocCoords(nc));']);
                    end
                end
            end
        end
    end
end

disp(['Processed ', num2str(ntm-1), ' muscles:'])
print_str = '';
for nd = 1:length(processed_muscles)
   if mod(nd, round((ntm-1)/2))==0
        disp(print_str);
        print_str = '';
   end
    print_str = [print_str, processed_muscles{nd}, '   '];
end
% remaining muscles
print_str = [print_str, processed_muscles{nd}, '   '];
end