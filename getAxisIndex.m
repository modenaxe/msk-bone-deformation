% function to transform an axis in its equivalent index
% x = 1, y = 2, z = 3;
function aIndexDir = getAxisIndex(aStringDir)

switch lower(aStringDir) %transforms in lower case
    case 'x'
        aIndexDir = 1;
        error('Matrix not implemented yet')
    case 'y'
        aIndexDir = 2;
        
    case 'z'
        aIndexDir = 3;
        error('Matrix not implemented yet')
    otherwise
        display(['The string ',aStringDir,' is not recognized as axis direction.']);
        error(['Please use ''x'',''y'' or ''z''.']);
end

end
