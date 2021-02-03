% previously Torsion_v3

clear;clc
% import libraries
import org.opensim.modeling.*

%%%%%%%%  MAIN SETTINGS %%%%%%%%%%%%%%%%%%
% Model and its geometry
% ModelFileName = 'GC5.osim';%
ModelFileName = './test_models/gait2392_simbody.osim';
ModelFileName = './test_models/Rajagopal2015_right_leg_only.osim';
OSGeometry_folder = '.\Geometry';% 
% OSGeometry_folder = 'C:\OpenSim 3.3\Geometry';
altered_models_folder = './';
% body to deform and axis of deformation
bone_to_deform = 'femur_r';
% bone_to_deform = 'tibia_r';
torsionAxis = 'y';
anteversion = 50;

TorsionProfilePointsDeg = [ 0  anteversion];
%------------------------------------------

% for anteversion = +7:-7:-28 %wrong one
     % ESB abstract 28%:-7:-7
% for anteversion = 50%:-7:-7

% Degree angles that are linearly interpolated to create the torsion profile.
% Equivalent LengthProfilePoints will complete this setting.


disp(['Anteversion angle: ', num2str(anteversion)])

% suffix used for saving geometries
bone_short = bone_to_deform([1:3,end-1:end]);
deformed_vtp_suffix   = ['_Torsion',upper(torsionAxis),num2str(TorsionProfilePointsDeg(1)),'Deg'];
deformed_model_suffix = [bone_short, 'Ant',num2str(TorsionProfilePointsDeg(1)),'Deg' ];

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
osimModel = applyTorsionToMuscleAttachments(osimModel,...
                                            bone_to_deform,...
                                            torsionAxis,...
                                            torsion_angle_func_rad);

% if there are markers rotate them
osimModel = applyTorsionToMarkers(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad);

% deform the bone geometries of the generic model
deformVTPBoneGeom(OSGeometry_folder,...
                  getBodyVTPFileNames(osimModel, bone_to_deform),...% get VTP geometries
                  torsionAxis,...
                  torsion_angle_func_rad,...
                  deformed_vtp_suffix)  
              
% assign the new VTP files to the model
[osimModel,newNames]= assignDeformedVTPFileNamesToBody(osimModel,...
                                                       bone_to_deform,...
                                                       deformed_vtp_suffix);
% rotate distal joint if required
% osimModel = rotateDistalJointAxes_v2(osimModel,segment,TorsionAxis, JointAxisTorsion);
applyTorsionToJoints(osimModel, bone_to_deform, torsionAxis, torsion_angle_func_rad)

% save output model
[~, name, ext] = fileparts(ModelFileName);
outputModelFile = fullfile(altered_models_folder,[name,'_',deformed_model_suffix, '.osim']);
% osimModel.setName(['Rajagopal2015_',deformed_model_suffix]);
osimModel.print(outputModelFile);
