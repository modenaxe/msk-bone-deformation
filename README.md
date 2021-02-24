[![DOI](https://zenodo.org/badge/269616182.svg)](https://zenodo.org/badge/latestdoi/269616182)

# Table of contents <!-- omit in toc -->

- [Bone deformation tool](#bone-deformation-tool)
- [Requirements and setup](#requirements-and-setup)
- [How to use the bone deformation tool](#how-to-use-the-bone-deformation-tool)
- [How the bone deformation tool works](#how-the-bone-deformation-tool-works)
- [Examples of use](#examples-of-use)
  - [Which models can I deform with this MATLAB tool?](#which-models-can-i-deform-with-this-matlab-tool)
  - [Femoral anteversion](#femoral-anteversion)
  - [Femoral torsion](#femoral-torsion)
  - [Tibial torsion](#tibial-torsion)
- [Future work](#future-work)

# Bone deformation tool

This repository is used for sharing a MATLAB toolbox that enables researcher in biomechanics to modify their generic musculoskeletal models by applying arbitrary torsional profiles to the long axis of the bone model.

The MATLAB tool works with musculoskeletal models in the format provided for the software for biomechanical analyses [OpenSim](https://opensim.stanford.edu/).

The tool is introduced and described in the following publication, which we invite you to cite if you are using the content of this repository for your research or teaching:

```bibtex
@article{Modenese2021bonedef,
  title={Dependency of Lower Limb Joint Reaction Forces on Femoral Anteversion},
  author={Luca Modenese, Martina Barzan and Christopher P. Carty},
  journal={Gait & Posture},
  volume = {submitted},
  year={2021},
  keywords = {Anteversion, Musculoskeletal modeling, Tibiofemoral contact force, Knee Loading, Femur, Walking}
}
```
The paper is available [as preprint](https://biorxiv.org/cgi/content/short/2021.02.22.432159v1), and all the materials used in that manuscript are available at [this repository](https://github.com/modenaxe/femoral_anteversion_paper).

# Requirements and setup

In order to use the bone deformation tool you will need to:
1. download [OpenSim 3.3](https://simtk.org/projects/opensim). Go to the `Download` page of the provided link and click on `Previous releases`, as shown in [this screenshot](https://github.com/modenaxe/3d-muscles/blob/master/images/get_osim3.3.PNG).
2. have MATLAB installed in your machine. The development of the paper was done using R2020a.
3. set up the OpenSim 3.3 API (Application User Interface) for MATLAB. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).

# How to use the bone deformation tool

In order to run the bone deformation tool you will need to specify:
1. where the OpenSim bone geometries are stored (variable `OpenSim_Geometry_folder`)
2. which segment of the OpenSim model you want to deform (variable `bone_to_deform`)
3. along which axis the torsional profile will be applied(variable `torsionAxis`)
4. the points defining the torsional profile, i.e. the torsion applied to the proximal and distal joint centres (variable `TorsionProfilePointsDeg`)
5. if you want the torsional to be applied just to the bone or also to the joints, i.e. if you want the kinematic model to be altered by the torsion (variable `apply_torsion_to_joints`)
6. where the resulting model will be saved (variable `altered_models_folder`)

# How the bone deformation tool works

The bone deformation tool will execute the following operations:
1. modify the bone geometry described in the OpenSim `vtp` file according to the specified linear torsional profile
2. generate a new bone geometry in `vtp` format
3. adjust all the muscle attachments and virtual markers attached to the bone
4. rotate the joints according to the specified torsional profile if the user decides to do that (see examples below). 
5. generate a new model that includes all the previous modifications.

# Examples of use

## Which models can I deform with this MATLAB tool?

We tested the MATLAB tool with two lower limb models for now: the `gait2392` model distributed with OpenSim and the full-body model published by [Rajagopal et al. (2016)](https://doi.org/10.1109/tbme.2016.2586891). The latter model was used in the publication associated with this repository and to produce the images in this document.

The formulation of the tool is however generic, so nothing prevents you from testing it on other bones and models.

## Femoral anteversion

It is possible to modify the femoral anteversion of a generic model as in the figure below.

If you want, for example, to generate a model with 40 degrees of femoral anteversion, you can apply a 28 degrees of torsion to the generic model, which we have estimated to have a femoral anteversion of 12 degrees.

The typical setting in the main script would then be:

```
%---------------  MAIN SETTINGS -----------
% Model to deform
modelFileName = './test_models/Rajagopal2015.osim';

% where the bone geometries are stored
OSGeometry_folder = './Geometry';

% body to deform
bone_to_deform = 'femur_l';

% axis of deformation
torsionAxis = 'y';

% define the torsion at the joint centre of the specified bone
% TorsionProfilePointsDeg = [ proximalTorsion DistalTorsion ];
TorsionProfilePointsDeg = [ 0  28 ];

% decide if you want to apply torsion to joint as well as other objects.
apply_torsion_to_joints = 'no';
```


![femoral_anteversion](/images/femoral_anteversion_example.png)

## Femoral torsion

For applying a distal femoral torsion it is necessary to specify also that the torsion will be applied to the joints with the setting `apply_torsion_to_joints = 'yes'`.

The typical setting would be:

```
%---------------  MAIN SETTINGS -----------
% Model to deform
modelFileName = './test_models/Rajagopal2015.osim';

% where the bone geometries are stored
OSGeometry_folder = './Geometry';

% body to deform
bone_to_deform = 'femur_l';

% axis of deformation
torsionAxis = 'y';

% define the torsion at the joint centre of the specified bone
% TorsionProfilePointsDeg = [ proximalTorsion DistalTorsion ];
TorsionProfilePointsDeg = [ 0  -30 ];

% decide if you want to apply torsion to joint as well as other objects.
apply_torsion_to_joints = 'yes';
```

![femoral_torsion](/images/femoral_torsion_example.png)

## Tibial torsion

Exactly the same setting can be used for applying a distal tibial torsion, with the only difference being 

```
% body to deform
bone_to_deform = 'tibia_l';
```


![distal_torsion](/images/tibial_torsion_example.png)

# Future work

* Upgrade scripts to openSim 4.x.
