# Bone deformation tool

This repository is used for sharing a MATLAB toolbox that enables researcher in biomechanics to modify their generic musculoskeletal models by applying arbitrary torsion profiles to the long axis of the bone model.

The toolbox works with musculoskeletal models in the format provided for the software for biomechanical analyses [OpenSim](https://opensim.stanford.edu/).

# Requirements and setup

In order to use the bone deformation tool you will need to:
1. download [OpenSim 3.3](https://simtk.org/projects/opensim). Go to the `Download` page of the provided link and click on `Previous releases`, as shown in [this screenshot](https://github.com/modenaxe/3d-muscles/blob/master/images/get_osim3.3.PNG).
2. have MATLAB installed in your machine. The development of the paper was done using R2020a.
3. set up the OpenSim 3.3 API (Application User Interface) for MATLAB. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).

# Examples of use

## femoral anteversion

![femoral_anteversion](/images/femoral_anteversion_example.png)
