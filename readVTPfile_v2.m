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