% previously Torsion_v3

clear;clc
%%%%%%%%  MAIN SETTINGS %%%%%%%%%%%%%%%%%%
% TO DO set up a generic point to initiate the torsion
% positive angle
segment = 'tibia_r';
TorsionAxis = 'y';
% TO DO
% the idea is to have desired torsion at distal joint and then
% calculate the length using getJontCentreCoord
TorsionPointsDeg = [0, 30];% degrees
LengthPoints = [0, 0.42];
JointAxisTorsion = TorsionPointsDeg(2);
% Folder settings
OSGeometry_folder = 'C:\OpenSim 3.1\Geometry';
ModelFileName = 'gait2392_simbody.osim';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % OLD SETUP
% viapoint = 'yes'; % now default: rotate attachments together with body

% torsion gradient
TorsionPoints = TorsionPointsDeg/180*pi;
TorsionGrad = diff(TorsionPoints)/diff(LengthPoints);

% TO DO CHANGE AXIS
deformed_vtp_suffix = ['_TorsionAxis',TorsionAxis,'Deg',num2str(TorsionPointsDeg(2))];

% import libraries
import org.opensim.modeling.*

% import model
osimModel = Model(ModelFileName);

% check if segment is included in the model
if osimModel.getBodySet().getIndex(segment)<0
    error('The specified segment is not included in the OpenSim model')
end

% % get length of the segment
% osimModel.getBodySet().get(segment)

% deforming muscle attachments
osimModel = deformMuscleAttachments(osimModel,segment, TorsionAxis, TorsionGrad);

% Deforming bone geometries
vtpNameSet = getSegVTPFileNames(osimModel,segment);
for n_vtp = 1:size(vtpNameSet,2)
    % current geometry
    curr_vtp = vtpNameSet{n_vtp};
    % vtp files with path
    vtp_file = fullfile(OSGeometry_folder,curr_vtp);
    % creates the deformed bones in the OpenSim geometry folder
    deformVTPBoneGeom(vtp_file, TorsionAxis, TorsionGrad,deformed_vtp_suffix)    
end

% updates the model so that it uses the new geometries
[osimModel,newNames]= setSegDeformedVTPFileNames(osimModel,segment,deformed_vtp_suffix);

% rotate distal joint
osimModel = rotateDistalJointAxes(osimModel,segment,TorsionAxis, JointAxisTorsion);

% sets output model
[path,name,ext] = fileparts(ModelFileName);
OutputModel = fullfile(path,[name,deformed_vtp_suffix,segment,'.osim']);
osimModel.print(OutputModel);
