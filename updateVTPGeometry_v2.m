% this function updates the normals and points of a vtp file with some new
% normals and points given as input

% writes the deformed file in the same folder where the original vtp is
% locates
function updateVTPGeometry_v2(vtp_file,new_normals,new_points,deformed_vtp_suffix)

% Opens original VTP file
fid = fopen(vtp_file);
[path, name, ~] = fileparts(vtp_file);
% Opens a VTP files to write the deformed geometry
fidDef = fopen(fullfile(path, [name,deformed_vtp_suffix,'.vtp']),'w+');
% Throws exception if there are problems with the files
if fid == -1;        error('Vtp file not loaded');    end
if fidDef == -1;      error('Vtp deformed file not loaded');    end
% initializations
n_norm = 1;
n_p=1;

while ~feof(fid) % goes though the entire file
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
end