% previously Torsion_v3

clear;clc
% import libraries
import org.opensim.modeling.*

%%%%%%%%  MAIN SETTINGS %%%%%%%%%%%%%%%%%%
% Model and its geometry
ModelFileName = 'GC5.osim';%'gait2392_simbody.osim';
OSGeometry_folder = '.\Geometry';% 'C:\OpenSim 3.3\Geometry';

% body to deform and axis of deformation
bone_to_deform = 'femur_l';
torsionAxis = 'y';

% the idea is to have desired torsion at distal joint and then
% calculate the length using getJontCentreCoord
% TorsionProfilePointsDeg = [-28, 0];% degrees

% fixing this requires adjustin the distal joint as well
% TorsionProfilePointsDeg = [0, 50];% degrees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for anteversion = +7:-7:-28
    
for anteversion = 28:-7:-7

% Degree angles that are linearly interpolated to create the torsion profile.
% Equivalent LengthProfilePoints will complete this setting.
TorsionProfilePointsDeg = [anteversion, 0];

disp(['Anteversion angle: ', num2str(anteversion)])

% import model
osimModel = Model(ModelFileName);

% get axis indices
[~, axis_ind] = getAxisRotMat(torsionAxis);

% compute bone length
[Pprox, Pdist, V, total_L] = getBoneLength(osimModel, bone_to_deform);

% define length corresponding to torsion points
LengthProfilePoints = [ Pprox(axis_ind), Pdist(axis_ind)];

% compute torsion profile
torsion_angle_func_rad = @(L)torsionProfile(L, LengthProfilePoints, TorsionProfilePointsDeg);

% deforming muscle attachments
osimModel = deformMuscleAttachments(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% suffix used for saving geometries
deformed_vtp_suffix = ['_Torsion',upper(torsionAxis),num2str(TorsionProfilePointsDeg(1)),'Deg'];

% get VTP geometries
vtpNameSet = getSegVTPFileNames(osimModel, bone_to_deform);
% deform them
deformVTPBoneGeom(OSGeometry_folder, vtpNameSet, torsionAxis, torsion_angle_func_rad, deformed_vtp_suffix)  
% assign new geometries to model
[osimModel,newNames]= setSegDeformedVTPFileNames(osimModel,bone_to_deform,deformed_vtp_suffix);

% rotate distal joint if required
% osimModel = rotateDistalJointAxes_v2(osimModel,segment,TorsionAxis, JointAxisTorsion);
% rotateJointRefSyst(osimModel, 'child', torsionAxis, torsion_angle_func_rad(total_L))

% save output model
[path, name, ext] = fileparts(ModelFileName);
antev = ['femAntev',num2str(12+TorsionProfilePointsDeg(1)),'Deg'];
outputModelFile = fullfile(path,[name,'_',antev, '.osim']);
osimModel.setName(['Rajagopal2015_',antev]);
osimModel.print(outputModelFile);
end