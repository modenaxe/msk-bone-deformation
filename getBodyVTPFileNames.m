function vtpNameSet = getBodyVTPFileNames(aOsimModel,aBodyName)

import org.opensim.modeling.*

% check if body is included in the model
if aOsimModel.getBodySet().getIndex(aBodyName)<0
    error('The specified segment is not included in the OpenSim model')
end

% gets GeometrySet, where the display properties are located
SegGeometrySet = aOsimModel.getBodySet().get(aBodyName).getDisplayer().getGeometrySet();

% Gets the element of the geometrySet
N_vtp = SegGeometrySet.getSize();

% Loops and saved the names of the VTP geometry files
for n_vtp = 0:N_vtp-1
    geom = SegGeometrySet.get(n_vtp);
    vtpNameSet(n_vtp+1) = {char(geom.getGeometryFile())};
end

end