%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% linear between the two values given, then going to zero in the rest of
% the bone

function torsion_angle = torsionProfile(L, LengthProfilePoints, torsion_points)

torsion_points_rad = torsion_points/180*pi;

tors_grad = diff(torsion_points_rad)/diff(LengthProfilePoints);

% if L>min(LengthProfilePoints) && L<max(LengthProfilePoints)
    torsion_angle =  torsion_points_rad(1) + tors_grad * L;
% else 
%     torsion_angle = 0;
% end

% plot(LengthProfilePoints', torsion_points, 'r-')
% xlabel('Lenght of the bone [m]')
% ylabel('Torsion Angle [deg]')

end



