%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %

function osimModel = applyTorsionToVTPBoneGeom(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad, torsion_doc_string, OSGeometry_folder)

% assign by default OpenSim 3.1 folder
if nargin<6; OSGeometry_folder = 'C:\OpenSim 3.3\Geometry'; end

disp('--------------------------');
disp(' ADJUSTING VTP GEOMETRIES ');
disp('--------------------------');

% get VTP files for bone of interest
disp(['Geometry folder: ', OSGeometry_folder])
disp(['VTP files attached to ', bone_to_deform,':']);
vtpNameSet = getBodyVTPFileNames(osimModel, bone_to_deform);

% converting the axis in the index used later
[RotMat, axis_ind] = getAxisRotMat(torsionAxis);

for n_vtp = 1:size(vtpNameSet,2)
    
    % current geometry
    curr_vtp = vtpNameSet{n_vtp};
    
    % print vtp file
    disp(['* ', curr_vtp]);

    % vtp files with path
    vtp_file = fullfile(OSGeometry_folder,curr_vtp);
    
    % reads the original vtp file
    disp('   - reading VTP file');
    [ normals, points] = readVTPfile_v2(vtp_file);
    
    % 2021 version
%     [P, C, N] = readVTPfile(vtp_file, 0);
%     boneTriObj = triangulation(C, P(:,1), P(:,2), P(:,3));
%     OBJfile = fullfile(OSGeometry_folder, [curr_vtp(1:end-4), deformed_vtp_suffix,'.obj']);
%     writeOBJfile(boneTriObj, OBJfile);
    
    % Deforms points and normals
    disp('   - applying torsion to points and normals');
    for n = 1:size(points,1)
        % compute torsion matrix
        TorsRotMat = RotMat(torsion_angle_func_rad(points(n,axis_ind)));
        
        % New points and axis
        new_points(n,:) = (TorsRotMat*points(n,:)')';
        new_normals(n,:) = (TorsRotMat*normals(n,:)')';
    end
    
    % writes the deformed geometry
    deformed_vtp_suffix   = ['_Torsion',upper(torsionAxis),torsion_doc_string];
    disp('   - writing deformed VTP file');
    writeDeformedVTPGeometry(vtp_file, new_normals, new_points, deformed_vtp_suffix)
   
end

% assign to model
osimModel =  assignDeformedVTPFileNamesToBody(osimModel, bone_to_deform, deformed_vtp_suffix);

end


function vtpNameSet = getBodyVTPFileNames(aOsimModel, aBodyName)

import org.opensim.modeling.*

% check if body is included in the model
if aOsimModel.getBodySet().getIndex(aBodyName)<0
    error('The specified segment is not included in the OpenSim model')
end

% gets GeometrySet, where the display properties are located
bodyGeometrySet = aOsimModel.getBodySet().get(aBodyName).getDisplayer().getGeometrySet();

% Gets the element of the geometrySet
N_vtp = bodyGeometrySet.getSize();

% Loops and saved the names of the VTP geometry files
for n_vtp = 0:N_vtp-1
    cur_geom = bodyGeometrySet.get(n_vtp);
    vtpNameSet(n_vtp+1) = {char(cur_geom.getGeometryFile())}; %#ok<AGROW>
end

end

% function to read normals and points contained in a vtp file.
% points and normal define the geometry of the bone (assuming that topology 
% doesn't change).
function [normals, points] = readVTPfile_v2(vtp_file)

% open vtp file
fid = fopen(vtp_file);

% check on the file: is it open?
if fid == -1;        error('VTPfile not loaded');    end

% initialization
n_norm = 1;
n_p=1;

while ~feof(fid) % goes though the entire file
    % gets a line
    tline = fgetl(fid);
    % checks if there are three floating nr in a row (can be a normal or a
    % point)
    if ~isempty(sscanf(tline,'%f %f %f\n'))
        % it gets the vector as double
        data = sscanf(tline,'%f %f %f\n');
        
        % it si a normal if norm is close to one.
        % the code assumes that normals are listed before points.
        if (abs(norm(data)-1)<0.000001) && n_p==1
            % stores the normal
            normals(n_norm,:) = data;
            n_norm = n_norm+1;
            % otherwise is a point
        elseif n_p<n_norm
            % stores the point
            points(n_p,:) = data;
            n_p = n_p+1;
        else 
            % if not point or normal than exit for loop, This avoids to go
            % through topology.
            break
        end
    end
end
% close files
fclose all;
end


% this function updates the normals and points of a vtp file with some new
% normals and points given as input
% writes the deformed file in the same folder where the original vtp is
% locates
function writeDeformedVTPGeometry(vtp_file,new_normals,new_points,deformed_vtp_suffix)

% Opens original VTP file
fid = fopen(vtp_file);
[path, name, ~] = fileparts(vtp_file);

% Opens a VTP files to write the deformed geometry
deformed_vtp_file = fullfile(path, [name,deformed_vtp_suffix,'.vtp']);
fidDef = fopen(deformed_vtp_file,'w+');

% Throws exception if there are problems with the files
if fid    == -1;      error('Vtp file not loaded');           end
if fidDef == -1;      error('Vtp deformed file not loaded');  end

% initializations
n_norm = 1;
n_p=1;

% goes though the entire file
while ~feof(fid) 
    % initialization of the writing format
    format = '';
    % gets a line
    tline = fgetl(fid);
    % scans the file until it finds 3 double in a row. They can be a
    % normal, a point or topology.
    if ~isempty(sscanf(tline,'%f %f %f\n'))
        % gets the floating numbers
        data = sscanf(tline,'%f %f %f\n');
        % They are normals if the norm is numerically zero and their index
        % is minor/equal to the first dimension of the given matrix
        if (abs(norm(data)-1)<0.000001) && n_norm<=length(new_normals)
            % substitution of the original values with the deformed one
            tline = new_normals(n_norm,:);
            % appropriate format for the normals
            format = '\t\t\t%-6.6f %-6.6f %-6.6f\r\n';
            n_norm = n_norm+1;
        end
        % if the vector has norm>1 and given points are not finished then
        % treat the vector as a point
        if (n_p<=length(new_points))&& (abs(norm(data)-1)>=0.000001)
            % update the point coordinates
            tline = new_points(n_p,:);
            % same format as before
            format = '\t\t\t%-6.6f %-6.6f %-6.6f\r\n';
            n_p = n_p+1;
        end
        % if not point or normal the vector value just goes through and
        % format is not updated
    end
    if strcmp(format,'')
        % format used to copy the line of the original file as it is.
        format = '%s\r\n';
    end
    % just write the line (updated or not)
    fprintf(fidDef,format,tline);
end
% close files
fclose all;

% informs the user of the new geometry
disp(['   - saved as ''', deformed_vtp_file,  ''' in geometry folder.']);

end

%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function [aOsimModel,newVTPNames] =  assignDeformedVTPFileNamesToBody(aOsimModel, aBodyName, suffix)

import org.opensim.modeling.*

% check if body is included in the model
if aOsimModel.getBodySet().getIndex(aBodyName)<0
    error('The specified segment is not included in the OpenSim model')
end

% gets GeometrySet, where the display properties are located
bodyGeometrySet = aOsimModel.getBodySet().get(aBodyName).getDisplayer().getGeometrySet();

% Gets the element of the geometrySet
N_vtp = bodyGeometrySet.getSize();

% Loops and updates the names of the VTP geometry files
for n_vtp = 0:N_vtp-1
    cur_geom = bodyGeometrySet.get(n_vtp);
    % original name
    origName = char(cur_geom.getGeometryFile());
    % update the vtp file name
    updVTPName = [origName(1:end-4),suffix,'.vtp'];
    % sets new file name for Geometry
    cur_geom.setGeometryFile(updVTPName);
    % stores name
    newVTPNames(n_vtp+1) = {updVTPName};  
    % clear
    clear origName  newName
end

end