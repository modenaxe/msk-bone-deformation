function [aRotMat, axis_ind] = getAxisRotMat(aStringAxis)

% uniform the input
stringAxis = lower(aStringAxis);

% get the corresponding rotation matrix as implicit function
switch stringAxis
    case 'x'
        aRotMat = @(a)[1   0    0;
                       0  cos(a) -sin(a);
                       0  sin(a)    cos(a)];
        axis_ind = 1;
    case 'y'
        aRotMat = @(a)[cos(a)       0    sin(a); 
                         0          1    0; 
                        -sin(a)     0    cos(a)];
        axis_ind = 2;
    case 'z'
        aRotMat = @(a)[ cos(a)     -sin(a)  0;
                        sin(a)     cos(a)   0;
                         0           0      1];
        axis_ind = 3;
    otherwise
        error('Please specify a rotation axis as ''x'', ''y'' or ''z''.')
end

    
