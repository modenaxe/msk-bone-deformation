function [aOsimModel,newNames] =  setSegDeformedVTPFileNames(aOsimModel,aSegmentName,suffix)

import org.opensim.modeling.*

% gets GeometrySet, where the display properties are located
SegGeometrySet = aOsimModel.getBodySet().get(aSegmentName).getDisplayer().getGeometrySet();

% Gets the element of the geometrySet
N_vtp = SegGeometrySet.getSize();

% Loops and updates the names of the VTP geometry files
for n_vtp = 0:N_vtp-1
    geom = SegGeometrySet.get(n_vtp);
    % original name
    origName = char(geom.getGeometryFile());
    % update the vtp file name
    newName = [origName(1:end-4),suffix,'.vtp'];
    % sets new file name for Geometry
    geom.setGeometryFile(newName);
    % stores name
    newNames(n_vtp+1) = {newName};  
    clear origName  newName
end

end