function setup_paths()

% Add the neccesary paths

[pathstr, ~, ~] = fileparts(mfilename('fullpath'));

%addpath(genpath('.'));
% Tracker implementation
addpath(genpath('helper_functions'));

addpath(genpath('bin_detector'));
addpath(genpath('camera_init'));
addpath(genpath('camera_loop'));
addpath(genpath('display_function'));
addpath(genpath('people_detector'));
addpath(genpath('tracking'));

addpath(genpath([pathstr '/implementation/']));
addpath('bacf_funs/')

% The feature extraction
addpath(genpath([pathstr '/feature_extraction/']));

% Matconvnet
addpath([pathstr '/external_libs/matconvnet/matlab/mex/']);
addpath([pathstr '/external_libs/matconvnet/matlab']);
addpath([pathstr '/external_libs/matconvnet/matlab/simplenn']);

% PDollar toolbox
addpath(genpath([pathstr '/external_libs/pdollar_toolbox/channels']));

% Mtimesx
addpath([pathstr '/external_libs/mtimesx/']);

% mexResize
addpath([pathstr '/external_libs/mexResize/']);