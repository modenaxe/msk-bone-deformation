function saveDeformedModel(osimModel, output_model_path)

disp('-----------------------');
disp(' SAVING DEFORMED MODEL ');
disp('-----------------------');

% update credits
osimModel.setAuthors('Created by the MATLAB deformation tool developed by Luca Modenese (2021) See original model file for related information.')
% print model
osimModel.print(output_model_path);
% inform user
disp(['model saved as ', output_model_path,'.']);
disp('Done.')

end