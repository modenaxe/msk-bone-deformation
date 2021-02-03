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