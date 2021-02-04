% read VTP as a VTK file. No differences wrt easier approach from 2013.
function [P, C, N] = readVTPfile(aVTKfile, debugplots)

% no plots by default
if nargin<2;     debugplots = 0;   end

% check on the file: is it open?
if ~isfile(aVTKfile)
    error([aVTKfile, 'does not exist']);
end

% parse the xml VTP structure in a MATLAB structure
F = xml2struct(aVTKfile);
% read the number of points
N_points = str2double(F.VTKFile.PolyData.Piece.Attributes.NumberOfPoints);
% read the number of polygons
N_polys = str2double(F.VTKFile.PolyData.Piece.Attributes.NumberOfPolys);

% get the normals
normals = F.VTKFile.PolyData.Piece.PointData.DataArray.Text;
N = textscan(normals,'%f %f %f\n');
N = [N{1}, N{2}, N{3}];

% read the points
points = F.VTKFile.PolyData.Piece.Points.DataArray.Text;
P = textscan(points,'%f %f %f\n');
P = [P{1}, P{2}, P{3}];
if size(P,1)~=N_points
    error(['readVTP.m Error reading file ', aVTKfile]);
end

% read the connectivity matrix
connectivity = F.VTKFile.PolyData.Piece.Polys.DataArray;
temp_con = connectivity{1};
connectivity = strjust(strtrim(deblank(temp_con.Text)), 'left');

% from OpenSim vtp these files are read as a long row

% C = textscan(connectivity,'%f %f %f\n');
% C = [C{1}, C{2}, C{3}];
C = textscan(connectivity,'%f %f %f %f\n');
C = [C{1}, C{2}, C{3}];
% C = str2num(connectivity);
% readjust the list of values and add one (numbering starts at zero
% otherwise.
C = reshape(C', [3, N_polys])'+1;

% debug plotting
if debugplots
    TR = triangulation(C, P);
    trisurf(TR); axis equal
    title('The VTP file you are trying to read')
end
end