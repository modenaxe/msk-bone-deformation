[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5075982.svg)](https://doi.org/10.5281/zenodo.5075982)
![visitors](https://visitor-badge.glitch.me/badge?page_id=modenaxe.msk_bone_deformation)<!-- omit in toc -->

# Table of contents <!-- omit in toc -->

- [Bone deformation tool](#bone-deformation-tool)
- [Requirements and setup](#requirements-and-setup)
- [How to use the bone deformation tool](#how-to-use-the-bone-deformation-tool)
- [How the bone deformation tool works](#how-the-bone-deformation-tool-works)
- [Which models can I deform with this MATLAB tool?](#which-models-can-i-deform-with-this-matlab-tool)
- [Definition of femoral version and tibial torsion angles](#definition-of-femoral-version-and-tibial-torsion-angles)
  - [Baseline angles for the Rajagopal full body model](#baseline-angles-for-the-rajagopal-full-body-model)
- [Examples of use](#examples-of-use)
  - [Femoral anteversion](#femoral-anteversion)
  - [Femoral torsion](#femoral-torsion)
  - [Tibial torsion](#tibial-torsion)
- [Provided example scripts](#provided-example-scripts)
- [Video summary of the associated publication](#video-summary-of-the-associated-publication)
- [How to contribute](#how-to-contribute)
- [Contributors](#contributors)

# Bone deformation tool

This repository is used for sharing a MATLAB toolbox that enables researcher in biomechanics to modify their generic musculoskeletal models by applying arbitrary torsional profiles to the long axis of the bone model.

The MATLAB tool works with musculoskeletal models in the format provided for the software for biomechanical analyses [OpenSim](https://opensim.stanford.edu/).

The tool is introduced and described in the following publication, which we invite you to cite if you are using the content of this repository for your research or teaching:

```bibtex
@article{Modenese2021bonedef,
  title={Dependency of Lower Limb Joint Reaction Forces on Femoral Version},
  author={Luca Modenese, Martina Barzan and Christopher P. Carty},
  journal={Gait & Posture},
  volume = {88},
  pages = {318-321},
  doi = {https://doi.org/10.1016/j.gaitpost.2021.06.014},
  year={2021},
  keywords = {Femoral version, Femoral anteversion, Musculoskeletal modeling, Tibiofemoral contact force, Knee Loading, Femur, Walking}
}
```
The [paper is open access](https://doi.org/10.1016/j.gaitpost.2021.06.014) and all the materials and scripts used for that manuscript are available at [this repository](https://github.com/modenaxe/femoral-anteversion-paper). 
Please note that version of the tool used in the reproducibility repository is [v0.1](https://github.com/modenaxe/msk-bone-deformation/releases/tag/v0.1), while the latest version is always recommended for new users.

# Requirements and setup

In order to use the bone deformation tool you will need to:
1. download [OpenSim 4.1](https://simtk.org/projects/opensim) or more recent. OpenSim 3.3 is also supported but the examples refer to the latest version.
2. have MATLAB installed in your machine. The development of the paper was done using R2020a.
3. set up the OpenSim API (Application User Interface) for MATLAB. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).

The tool should be able to detect the version of your installed OpenSim API automatically, so you do not have to modify anything related to this toolbox if you are using OpenSim 3.3.

# How to use the bone deformation tool

In order to run the bone deformation tool you will need to specify variable in the example scripts, or in your own scripts:
1. where the OpenSim bone geometries are stored (variable `OpenSim_Geometry_folder`)
2. which segment of the OpenSim model you want to deform (variable `bone_to_deform`)
3. along which axis the torsional profile will be applied(variable `torsionAxis`)
4. the points defining the torsional profile, i.e. the torsion applied to the proximal and distal joint centres (variable `TorsionProfilePointsDeg`)
5. if you want the torsional to be applied just to the bone or also to the joints, i.e. if you want the kinematic model to be altered by the torsion (variable `apply_torsion_to_joints`)
6. where the resulting model will be saved (variable `altered_models_folder`)

# How the bone deformation tool works

The bone deformation tool will execute the following operations:
1. read and modify the bone geometry described in the OpenSim `vtp` file according to the specified rotational profile
2. generate a new bone geometry in `vtp` format and save it in the same folder
3. adjust all the muscle attachments and virtual markers attached to the bone of interest
4. rotate the joints axes according to the specified torsional profile if the user decides to do that (see examples below). This will modify the kinematic model.
5. generate a new OpenSim model that includes all the previous modifications.

# Which models can I deform with this MATLAB tool?

We tested the MATLAB tool with two popular lower limb models: 
* the `gait2392` model distributed with OpenSim 
* the `Rajagopal full-body model` published by [Rajagopal et al. (2016)](https://doi.org/10.1109/tbme.2016.2586891). 
The latter model was used in the publication associated with this repository and to produce the images in this document.

Please consider that the formulation of the tool is however **completely generic** in its managing the OpenSim model components, so nothing prevents you from testing it on other bones and models, including upper limb models.

# Definition of femoral version and tibial torsion angles

The generic OpenSim model are provided with bone geometry for visualization purposes, and it is possible to estimate the femoral version and tibial rotation using their geometry. We have estimated the following angles as in [Strecker et al. (1997)](https://online.boneandjoint.org.uk/doi/abs/10.1302/0301-620X.79B6.0791019)

![alignment-angles](/images/angle-measurements.png)

## Baseline angles for the Rajagopal full body model

For the full-body model by Rajagopal et al. we found:
* femoral version: `12 degrees`
* tibial rotation: `28 degrees`

The reference systems that we constructed for the estimation of these angles are available in the folder [baseline-angles-estimation-Rajagopal](baseline-angles-estimation-Rajagopal) and can be visualized using [NMSBuilder](http://www.nmsbuilder.org/).

**WARNING** the bone geometries provided with the OpenSim models are normally of low quality, not comparable with those obtainable from segmentation of CT scans, for example. Estimation of these rotational angle is therefore challenging.

Knowledge of the bone rotation for the baseline model is essential because the bone deformation prescribed with this deformation tool will be added to the existing bone rotation.

# Examples of use

## Femoral anteversion

It is possible to modify the femoral anteversion of a generic model as in the figure below.

If you want, for example, to generate a model with 40 degrees of femoral anteversion, you can apply a 28 degrees of rotation to the generic model, which we have estimated to have a femoral anteversion of 12 degrees.

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

% define the rotation at the joint centre of the specified bone
% TorsionProfilePointsDeg = [ proximalTorsion DistalTorsion ];
TorsionProfilePointsDeg = [ 0  28 ];

% decide if you want to apply the rotation to joint as well as other objects.
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

The resulting tibial torsion will be 2 degrees.

![distal_torsion](/images/tibial_torsion_example.png)

# Provided example scripts

We have provided example scripts that demonstrate how to modify the geometry of femur and tibia in the gait2392 and Rajagopal models:
* [`Example_deform_distal_femur_gait2392.m`](Example_deform_distal_femur_gait2392.m)
* [`Example_deform_distal_femur_Rajagopal.m`](Example_deform_distal_femur_Rajagopal.m)
* [`Example_deform_distal_tibia_gait2392.m`](Example_deform_distal_tibia_gait2392.m)
* [`Example_deform_distal_tibia_Rajagopal.m`](Example_deform_distal_tibia_Rajagopal.m)

The models resulting from these scripts, together with the bone geometries for visualizing the Rajagopal model, are available in the [`examples'](./examples) folder.

# Video summary of the associated publication

Luca gave a talk at the [26th Congress of the European Society of Biomechanics](https://bit.ly/3yU6EwB) presenting the paper associated with the bone deformation tool. Click on the image below to see the recorded:

[![Alt text](images/ESB2021_youtube_thumbnail.png)](https://www.youtube.com/watch?v=jq2S2tRGsm0)


# How to contribute
We welcome any contribution from the biomechanical and open source community, in any form. Few tips for contributing:

* To report a bug, or anomalous behaviour of the toolbox, please open an issue on this page. Ideally, if you could make the issue reproducile with some data that you can share with us.
* To contributing to the project with new code please use a standard GitHub workflow: a) fork this repository, b) create your own branch, where you make your modifications and improvements, c)  once you are happy with the new feature that you have implemented you can create a pull request. We will review your code and potentially include it in the main repository.
* To propose feature requests, please open an issue [on this page](https://github.com/modenaxe/msk-bone-deformation/issues), label it as feature request using the Labels panel on the right and describe your desired new feature. We will review the proposal regularly but work on them depending on the planned development.

# Contributors
Many thanks to **Axel Koussou** and **Emmanuelle Renoul** from Fondation Ellen Poidatz (St-Fargeau-Ponthierry, France) for helping with the tool upgrade to OpenSim 4.1.
