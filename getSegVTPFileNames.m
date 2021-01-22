function vtpNameSet = getSegVTPFileNames(aOsimModel,aSegmentName)

import org.opensim.modeling.*

% gets GeometrySet, where the display properties are located
SegGeometrySet = aOsimModel.getBodySet().get(aSegmentName).getDisplayer().getGeometrySet();

% Gets the element of the geometrySet
N_vtp = SegGeometrySet.getSize();

% Loops and saved the names of the VTP geometry files
for n_vtp = 0:N_vtp-1
    geom = SegGeometrySet.get(n_vtp);
    vtpNameSet(n_vtp+1) = {char(geom.getGeometryFile())};
end

end