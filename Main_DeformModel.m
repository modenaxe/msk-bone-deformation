clear;clc

% import libraries
import org.opensim.modeling.*

%---------------  MAIN SETTINGS -----------
% Model to deform
% ModelFileName = './test_models/gait2392_simbody.osim';
modelFileName = './test_models/Rajagopal2015.osim';

% where the bone geometries are stored
% OSGeometry_folder = 'C:\OpenSim 3.3\Geometry';
OSGeometry_folder = './Geometry';

% body to deform
bone_to_deform = 'tibia_r';

% axis of deformatio
torsionAxis = 'y';

% define the torsion at the joint centre of the specified bone
TorsionProfilePointsDeg = [ 40  0 ];

% decide if you want to apply torsion to joint as well as other objects
apply_torsion_to_joints = 'yes';

% where the deformed models will be saved
altered_models_folder = './deformed_models';
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
if ~isfolder(altered_models_folder); mkdir(altered_models_folder); end
[~, name,ext] = fileparts(modelFileName);
deformed_model_name = [name, deformed_model_suffix,ext];
output_model_path = fullfile(altered_models_folder, deformed_model_name);
osimModel.setName([char(osimModel.getName()),deformed_model_suffix]);

% save model
saveDeformedModel(osimModel, output_model_path);
