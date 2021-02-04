% previously Torsion_v3

clear;clc
% import libraries
import org.opensim.modeling.*

%---------------  MAIN SETTINGS -----------
% Model and its geometry
% ModelFileName = 'GC5.osim';%
% ModelFileName = './test_models/gait2392_simbody.osim';
% ModelFileName = './test_models/Rajagopal2015_right_leg_only.osim';
modelFileName = './test_models/Rajagopal2015.osim';
OSGeometry_folder = '.\Geometry';% 
% OSGeometry_folder = 'C:\OpenSim 3.3\Geometry';
altered_models_folder = './';
% body to deform and axis of deformation
bone_to_deform = 'femur_r';
bone_to_deform = 'tibia_r';
torsionAxis = 'y';
torsion = -40;

TorsionProfilePointsDeg = [ torsion 0   ];

apply_torsion_to_joints = 'yes';
%-------------------------------------------

% deformed_model_name
% import model
osimModel = Model(modelFileName);

% compute bone length
[Pprox, Pdist, total_L, V] = getJointCentresForBone(osimModel, bone_to_deform);

% define length corresponding to torsion points
LengthProfilePoints = [ Pprox; Pdist];

% compute torsion profile
[torsion_angle_func_rad, torsion_doc_string]= createTorsionProfile(LengthProfilePoints, TorsionProfilePointsDeg, torsionAxis);

% suffix used for saving geometries
bone_short = bone_to_deform([1:3,end-1:end]);
deformed_model_suffix = ['_Tors',upper(bone_short(1)),bone_short(2:end),torsion_doc_string];

% if you want you can apply torsion to joints
if strcmp(apply_torsion_to_joints, 'yes')
    osimModel = applyTorsionToJoints(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);
end

% deforming muscle attachments
osimModel = applyTorsionToMuscleAttachments(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% if there are markers rotate them
osimModel = applyTorsionToMarkers(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% deform the bone geometries of the generic model
osimModel = applyTorsionToVTPBoneGeom(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad, torsion_doc_string, OSGeometry_folder);

% save output model
[~, name,ext] = fileparts(modelFileName);
deformed_model_name = [name, deformed_model_suffix,ext];
output_model_path = fullfile(altered_models_folder, deformed_model_name);
osimModel.setName([char(osimModel.getName()),deformed_model_suffix]);

% save model
saveDeformedModel(osimModel, output_model_path)


