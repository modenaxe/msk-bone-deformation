%-------------------------------------------------------------------------%
%    Copyright (c) 2025 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@unsw.edu.au                                     %
% ----------------------------------------------------------------------- %
clear;clc
addpath('./tool_funcs')
% import libraries
import org.opensim.modeling.*

%---------------  MAIN SETTINGS -----------
% Model to deform
% ModelFileName = './test_models/gait2392_simbody.osim';
modelFileName = './examples_Rajagopal2015/Rajagopal2015.osim';

% where the bone geometries are stored
OpenSim_Geometry_folder = './examples_Rajagopal2015/Geometry';

% body to deform
bone_to_deform = 'femur_r';

% axis of deformatio
torsionAxis = 'y';

% define the rotational profile at the joint centres of the bone of interest
% TorsionProfilePointsDeg = [ proximalTorsion DistalTorsion ];
TorsionProfilePointsDeg = [ 40  0 ];

% decide if you want to apply torsion to joint as well as other objects.
% E.g. choose no for investigating the effect of femoral anteversion in a
% leg with straight alignment.
% Choose yes for modelling a CP child with deformation of bone resulting in
% joint rotation, meaning the kinematic model is altered.
apply_torsion_to_joints = 'yes';

% where the deformed models will be saved
altered_models_folder = './examples_Rajagopal2015';
%----------------------------------------------

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
deformed_model_suffix = ['_Tors',upper(bone_short(1)),bone_short(2:end),'_',torsion_doc_string];

% if you want you can apply torsion to joints
if strcmp(apply_torsion_to_joints, 'yes')
    osimModel = applyTorsionToJoints(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);
end

% deforming muscle attachments
osimModel = applyTorsionToMuscleAttachments(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% if there are markers rotate them
osimModel = applyTorsionToMarkers(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% deform the bone geometries of the generic model
osimModel = applyTorsionToVTPBoneGeom(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad, torsion_doc_string, OpenSim_Geometry_folder);

% save output model
if ~isfolder(altered_models_folder); mkdir(altered_models_folder); end
[~, name,ext] = fileparts(modelFileName);
deformed_model_name = [name, deformed_model_suffix,ext];
output_model_path = fullfile(altered_models_folder, deformed_model_name);
osimModel.setName([char(osimModel.getName()),deformed_model_suffix]);

% save model
saveDeformedModel(osimModel, output_model_path);
